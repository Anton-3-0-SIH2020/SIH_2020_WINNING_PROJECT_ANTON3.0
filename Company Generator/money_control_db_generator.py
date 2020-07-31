import requests
import json
import re
from bs4 import BeautifulSoup as soup
from configparser import ConfigParser
import psycopg2

configure = ConfigParser()
configure.read("secret.ini")

DATABASE = configure.get("POSTGRES", "DATABASE")
USER = configure.get("POSTGRES", "USER")
PASSWORD = configure.get("POSTGRES", "PASSWORD")
HOST = configure.get("POSTGRES", "HOST")
PORT = configure.get("POSTGRES", "PORT")


def money_control_get_company_names():
    connection = psycopg2.connect(
        user=USER, password=PASSWORD, host=HOST, port=PORT, database=DATABASE,
    )
    cursor = connection.cursor()
    data = []
    res = requests.get('https://www.moneycontrol.com/india/stockpricequote/',
                       headers={'User-Agent': 'Mozilla/5.0'})
    res.raise_for_status()
    page_soup = soup(res.content)
    links = page_soup.find_all('a', {'class': 'bl_12'})
    for link in links[1:]:
        data.append({
            'name': link.string,
            'link': link['href'],
            'bse': money_control_get_company_bse(link['href'])
        })
        print(money_control_get_company_bse(link['href']))
        print(link.string)
        print()
        # Adding data to db
        add_data_to_db = "INSERT INTO companies VALUES (%s,%s,%s)"
        cursor.execute(add_data_to_db, ('MC', money_control_get_company_bse(
            link['href']), link.string))
        connection.commit()
    cursor.close()
    connection.close()

    print('Completed Scraping')


def money_control_get_company_bse(link):
    res = requests.get(link, headers={'User-Agent': 'Mozilla/5.0'})
    res.raise_for_status()
    page_soup = soup(res.content, features='lxml')
    bse = page_soup.find_all(
        'ctag', {'class': 'mob-hide'})[0].find_all('span')[0].string
    return bse


# Initializing the db
def mc_company_to_db():
    connection = psycopg2.connect(
        user=USER, password=PASSWORD, host=HOST, port=PORT, database=DATABASE,
    )
    cursor = connection.cursor()
    create_table = "CREATE TABLE IF NOT EXISTS companies (exchange text,code text,company text)"
    cursor.execute(create_table)
    connection.commit()
    money_control_get_company_names()
    cursor.close()
    connection.close()