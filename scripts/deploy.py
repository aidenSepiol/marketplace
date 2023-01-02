from brownie import accounts, config, HelloWorld, SaturnMarketPlace
from scripts.helper import get_account


def deploy_contract():
    account = get_account()
    contract = SaturnMarketPlace.deploy({"from": account})
    print(f"Contract deployed to {contract.address}")
    return


def main():
    deploy_contract()
    print("Deploy successfully!")
