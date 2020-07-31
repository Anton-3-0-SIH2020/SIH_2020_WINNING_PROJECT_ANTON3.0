from bse_db_generator import bse_company_to_db
from nse_db_generator import nse_company_to_db
from money_control_db_generator import mc_company_to_db

def app(event=None, context=None):
    mc_company_to_db()
    bse_company_to_db()
    nse_company_to_db()