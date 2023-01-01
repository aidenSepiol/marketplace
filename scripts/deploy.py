from brownie import accounts, config, HelloWorld
import os


def deploy_contract():
    # account_deploy = accounts.add(config['wallets']['from_key'])
    account_deploy = accounts[0]
    print(f"{account_deploy}")
    c_hello_world = HelloWorld.deploy({"from": account_deploy})
    print(c_hello_world)
    result = c_hello_world.retrieve({"from": account_deploy})
    print(result)
    return
    # ganache account
    for i in range(10):
        account_address = accounts[i]
        print(f"{i}. {account_address}")
    # imported accounts
    account_name = 'brave-test'
    account_address = accounts.load(account_name)
    print(f"{account_name}. {account_address}")
    return


def main():
    deploy_contract()
    print("Deploy successfully!")
