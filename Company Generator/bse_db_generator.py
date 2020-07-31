import json
from configparser import ConfigParser
import psycopg2

configure = ConfigParser()
configure.read("secret.ini")

DATABASE = configure.get("POSTGRES", "DATABASE")
USER = configure.get("POSTGRES", "USER")
PASSWORD = configure.get("POSTGRES", "PASSWORD")
HOST = configure.get("POSTGRES", "HOST")
PORT = configure.get("POSTGRES", "PORT")


def bse_company_to_db():
    with open('./stk.json') as f:
        data = json.load(f)

    connection = psycopg2.connect(
        user=USER, password=PASSWORD, host=HOST, port=PORT, database=DATABASE,
    )
    cursor = connection.cursor()
    create_table = "CREATE TABLE IF NOT EXISTS companies (exchange text,code text,company text)"
    cursor.execute(create_table)
    connection.commit()
    add_data_to_db = "INSERT INTO companies VALUES (%s,%s,%s)"

    for (i, j) in data.items():
        cursor.execute(add_data_to_db, ('BSE', i, j))
    connection.commit()
    cursor.close()
    connection.close()