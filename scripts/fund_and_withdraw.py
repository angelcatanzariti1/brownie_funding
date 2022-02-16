from brownie import FundMyProject
from scripts.helpful_scripts import get_account

def fund():
    fund_me = FundMyProject[-1]
    account = get_account()