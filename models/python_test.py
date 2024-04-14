import pandas as pd

def model(dbt, session):
    dbt.config(
        materialized = "table",
        python_version="3.11",   
        packages = ["numpy", "pandas"] #, "weaviate-client==3.26"]
    )

    session.custom_package_usage_config = {"enabled": True}
    session.add_packages(["weaviate-client"])

    df = pd.DataFrame({'a':[1,2]})

    return df

