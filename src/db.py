import pandas as pd
from sqlalchemy import create_engine, text

DATABASE_URL = "postgresql+psycopg://localhost/olist"


def get_engine():
    engine = create_engine(DATABASE_URL)
    return engine


def run_query(sql):
    engine = get_engine()
    with engine.connect() as conn:
        df = pd.read_sql(text(sql), conn)
    return df


def run_sql_file(path):
    with open(path) as f:
        sql = f.read()
    df = run_query(sql)
    return df
