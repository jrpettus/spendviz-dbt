FROM jupyter/base-notebook:python-3.11

# Install the dependencies from the requirements.txt file
RUN pip install requests snowflake-snowpark-python[pandas]
#weaviate-client
RUN pip install --pre -U "weaviate-client==3.26"
#upgrade to v4 client for weaviate
#RUN pip install --pre -U "weaviate-client==4.*"
RUN pip install ollama==0.1.5
RUN pip install langchain==0.1.12
RUN pip install langchain-community==0.0.29
RUN pip install crewai==0.22.4
RUN pip install plotly==5.20.0
RUN pip install altair
#RUN pip install pandas=2.2.1


# Set the working directory
WORKDIR /workspace/

# Expose Jupyter Notebook port
EXPOSE 8888

# Copy the notebooks directory to the container's /app directory
RUN mkdir /workspace/.local /workspace/.cache && chmod 777 -R /workspace

#COPY --chmod=777 Copy_Products_to_Weaviate.ipynb TestWeaviate.ipynb Create_Product_Descriptions.ipynb ./

# Run Jupyter Notebook on container startup
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]