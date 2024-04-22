import logging
import os
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Any

from langchain_text_splitters import RecursiveCharacterTextSplitter
from snowflake.snowpark import Session
import weaviate

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

app = FastAPI()


# connect to weaviate
client = weaviate.Client(url="http://weaviate:8080")

# payload types
SingleEntry = tuple[int, str]


# payload format to match Snowflake request format
class Payload(BaseModel):
    data: List[SingleEntry]


load_dotenv()


# Function to create a Snowpark session using environment variables for Snowflake configuration
def create_snowpark_session():
    connection_parameters = {
        "account": os.getenv("SNOW_ACCOUNT"),
        "user": os.getenv("SNOW_USER"),
        "password": os.getenv("SNOW_PASSWORD"),
        "role": os.getenv("SNOW_ROLE"),
        "warehouse": os.getenv("SNOW_WAREHOUSE"),
        "database": os.getenv("SNOW_DATABASE"),
        "schema": os.getenv("SNOW_SCHEMA"),
    }
    session = Session.builder.configs(connection_parameters).create()
    return session


session = create_snowpark_session()


def extract_category_supplier(path):
    # Extract the filename from the full path
    filename = path.split("/")[-1]

    # Split the filename into category and supplier parts
    parts = filename.split("__")

    # Extract and clean the category part
    category = parts[0].strip()

    # Extract the supplier part and remove the file extension, then strip spaces
    supplier = parts[1].split(".txt")[0].strip()

    return category, supplier


def read_sf_file(file_path):
    """read in file from Snowflake stage"""
    with session.file.get_stream(f"@files/contracts/{file_path}") as file:
        f = file.read()
    return f.decode("utf-8")


def load_with_metadata(file_path):
    """
    loads the file and splits it into lanchain documents with metadata
    metadata will be key for filtering documents
    """
    file = read_sf_file(file_path)

    # apply text splitter
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=1024, chunk_overlap=200)

    docs = text_splitter.create_documents([file])

    # extract the category and supplier
    category, supplier = extract_category_supplier(file_path)

    for doc in docs:
        doc.metadata = {"source": file_path, "category": category, "supplier": supplier}
    return docs


def check_existing_metadata(supplier):
    """checks to see if supplier is in metadata of weaviate collection"""
    search_results = retrieve_vectors("contract test", supplier)
    # if the length is 0 then return true representing supplier is already there
    if len(search_results["data"]["Get"]["ProcureContracts"]) == 0:
        return False
    else:
        return True
    

def batch_load(batch_data: List[SingleEntry]):
    """loads data into snowflake from received payload"""
    response_list = []
    for entry in batch_data:
        row_nbr, file_path = entry  # Unpack the tuple
        print(row_nbr, file_path)

        try:
            # first check if supplier is already there
            supplier = extract_category_supplier(file_path)[1]
            if (
                check_existing_metadata(supplier) == False
            ):  # false if supplier was not found so start ingesting

                # load the docs with metadata
                docs = load_with_metadata(file_path)

                for (
                    doc
                ) in docs:  # loop through each doc and tag the weaviate components
                    contract_data = {
                        "text": doc.page_content,
                        "category": doc.metadata["category"],
                        "supplier": doc.metadata["supplier"],
                    }

                    # write to weaviate
                    client.data_object.create(
                        data_object=contract_data, class_name="ProcureContracts"
                    )
                message = "success"

            else:
                message = "contract already loaded"

        except:
            logging.error(f"Error loading file: {file_path}")
            message = "failure"
            continue

        # append the result with row number and the concatenated text
        response_list.append([row_nbr, message])
    
    return response_list


# Function to retrieve vectors from Weaviate
def retrieve_vectors(
    query: str, supplier: str, collection_name="ProcureContracts"
) -> dict:
    """ retrieve chunks from Weaviate while filtering by supplier"""
    try:
        response = (
            client.query.get(collection_name, ["text", "category", "supplier"])
            .with_near_text({"concepts": [query]})
            .with_limit(2)
            .with_additional(["distance"])
            .with_where(
                {"path": ["supplier"], "operator": "Equal", "valueText": supplier}
            )
            .do()
        )
    except Exception as e:
        logging.error(f"Error retrieving vectors: {e}")
        response = {
            "data": {"Get": {"ProcureContracts": []}}
        }  # Return empty response in case of error
    return response


# Function to concatenate texts
def concatenate_texts(data: dict) -> str:
    """ concatenates the texts from the retrieved data for easier downstream processing """
    texts = []
    contracts = data.get("data", {}).get("Get", {}).get("ProcureContracts", [])
    for contract in contracts:
        texts.append(contract.get("text", ""))
    return "\n\n".join(texts)


# Function to process batch data requests
def batch_request(batch_data: List[SingleEntry]):
    """retrieve chunks in batch for multiple queries and suppliers"""
    response_list = []
    for entry in batch_data:
        row_nbr, combined = entry  # Unpack the tuple
        query, supplier = combined.split(
            " | "
        )  # Split the combined string into query and supplier
        # Retrieve data based on the query and supplier
        retrieved_data = retrieve_vectors(query, supplier)
        # Concatenate texts from the retrieved data
        text = concatenate_texts(retrieved_data)

        # Append the result with row number and the concatenated text
        response_list.append([row_nbr, text])

    return response_list


# FastAPI endpoints


@app.post("/load")
def load_batch_context(payload: Payload):
    """end point for sending file path to be loaded into vector database"""

    try:
        load_results = batch_load(payload.data)
        return {"data": load_results}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/retrieve")
def retrieve_batch_context(payload: Payload):
    """end point for retrieving vector context from weaviate and serves back to the client"""

    try:
        response_data = batch_request(payload.data)
        return {"data": response_data}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
