from brownie import ABreach, ABrimStone, ACypher, AJett, AOmen, APhoenix, ARaze, ASage, ASova, AViper, AgentRepo, SaturnBox, SaturnMarketPlace

from scripts.helper import get_account
from web3 import Web3


def deploy_contract():
    account = get_account()

    # Deploy the contract AgentRepo
    address_agent_repo = AgentRepo.deploy({"from": account})
    # Deploy the contract of Agent (10 agents)
    address_agent_breach = ABreach.deploy(address_agent_repo, {"from": account})
    address_agent_brimstone = ABrimStone.deploy(address_agent_repo, {"from": account})
    address_agent_cypher = ACypher.deploy(address_agent_repo, {"from": account})
    address_agent_jett = AJett.deploy(address_agent_repo, {"from": account})
    address_agent_omen = AOmen.deploy(address_agent_repo, {"from": account})
    address_agent_phoenix = APhoenix.deploy(address_agent_repo, {"from": account})
    address_agent_raze = ARaze.deploy(address_agent_repo, {"from": account})
    address_agent_sage = ASage.deploy(address_agent_repo, {"from": account})
    address_agent_sova = ASova.deploy(address_agent_repo, {"from": account})
    address_agent_viper = AViper.deploy(address_agent_repo, {"from": account})
    # Deploy the contract SaturnBox
    address_saturn_box = SaturnBox.deploy({"from": account})
    # Deploy the contract SaturnMarketPlace
    address_saturn_mkp = SaturnMarketPlace.deploy(address_saturn_box, {"from": account})

    # For AgentRepo
    list_agent_address = [
        address_agent_breach,
        address_agent_brimstone,
        address_agent_cypher,
        address_agent_jett,
        address_agent_omen,
        address_agent_phoenix,
        address_agent_raze,
        address_agent_sage,
        address_agent_sova,
        address_agent_viper
    ]
    list_agent_weights = [1] * len(list_agent_address)
    address_agent_repo.initializeAgent(list_agent_address, list_agent_weights, {"from": account})
    address_agent_repo.setupRoleSaturnBox(address_saturn_box, {"from": account})
    address_agent_repo.setupRoleSaturnMKP(address_saturn_mkp, {"from": account})

    # For SaturnBox
    address_saturn_box.initializeContract(address_agent_repo, address_saturn_mkp, {"from": account})

    # For SaturnMarketPlace
    address_saturn_mkp.initializeContract(address_agent_repo, {"from": account})

    response_data = {
        "address_agent_repo": address_agent_repo,
        "address_agent_breach": address_agent_breach,
        "address_agent_brimstone": address_agent_brimstone,
        "address_agent_cypher": address_agent_cypher,
        "address_agent_jett": address_agent_jett,
        "address_agent_omen": address_agent_omen,
        "address_agent_phoenix": address_agent_phoenix,
        "address_agent_raze": address_agent_raze,
        "address_agent_sage": address_agent_sage,
        "address_agent_sova": address_agent_sova,
        "address_agent_viper": address_agent_viper,
        "address_saturn_box": address_saturn_box,
        "address_saturn_mkp": address_saturn_mkp
    }
    return response_data


def test_buy_a_box(contracts_dict):
    import time
    account_2 = get_account(index=2)
    contracts_dict["address_saturn_box"].purchaseBox(1, {"from": account_2, "value": 100000000})
    contracts_dict["address_saturn_box"].purchaseBox(2, {"from": account_2, "value": 100000000})
    time.sleep(3)
    my_box = contracts_dict["address_saturn_box"].getMyBox({"from": account_2})
    print(my_box)

    account_3 = get_account(index=3)
    contracts_dict["address_saturn_box"].purchaseBox(1, {"from": account_3, "value": 100000000})
    contracts_dict["address_saturn_box"].purchaseBox(2, {"from": account_3, "value": 100000000})
    time.sleep(3)
    my_box = contracts_dict["address_saturn_box"].getMyBox({"from": account_3})
    print(my_box)


def test_buy_and_open_a_box(contracts_dict):
    import time
    # buy a box
    print("Buying a box........")
    account_2 = get_account(index=2)
    contracts_dict["address_saturn_box"].purchaseBox(1, {"from": account_2, "value": 100000000})
    contracts_dict["address_saturn_box"].purchaseBox(3, {"from": account_2, "value": 100000000})
    contracts_dict["address_saturn_box"].purchaseBox(2, {"from": account_2, "value": 100000000})
    contracts_dict["address_saturn_box"].purchaseBox(1, {"from": account_2, "value": 100000000})
    contracts_dict["address_saturn_box"].purchaseBox(2, {"from": account_2, "value": 100000000})
    contracts_dict["address_saturn_box"].purchaseBox(3, {"from": account_2, "value": 100000000})
    my_box = contracts_dict["address_saturn_box"].getMyBox({"from": account_2})
    print(f"Bought successfully: {my_box}")

    # before unbox
    before = contracts_dict["address_saturn_mkp"].getMyItems({"from": account_2})
    print(f"Inventory before openBox: {before}")

    # open my box

    print("Opening my first box........")
    first_box = my_box[0]
    box_id = first_box[0]
    contracts_dict["address_saturn_box"].openBox(box_id, {"from": account_2, "value": 25000000000})
    my_box = contracts_dict["address_saturn_box"].getMyBox({"from": account_2})
    print(f"Opened my first box successfully, my box left: {my_box}")

    # after unbox
    after = contracts_dict["address_saturn_mkp"].getMyItems({"from": account_2})
    print(f"Inventory after openBox: {after}")


def test_buy_and_open_a_box_then_list_to_marketplace(contracts_dict):
    test_buy_and_open_a_box(contracts_dict)
    print("Listing my first NFT to marketplace........")
    account_2 = get_account(index=2)
    my_item = contracts_dict["address_saturn_mkp"].getMyItems({"from": account_2})
    tokenId = my_item[0][1]
    # option test on chain require
    # contracts_dict["address_saturn_mkp"].offChain(tokenId, {"from": account_2, "value": 25000000000})
    # list
    contracts_dict["address_saturn_mkp"].sellNFT(tokenId, 25000000000, {"from": account_2, "value": 25000000000})
    print("Listed my first NFT to marketplace successfully!!")

    # my nft
    my_item = contracts_dict["address_saturn_mkp"].getMyItems({"from": account_2})
    print(f"Inventory after List: {my_item}")
    my_list_item = contracts_dict["address_saturn_mkp"].getMyListedItems({"from": account_2})
    print(f"My listed items: {my_list_item}")
    return my_list_item[0][1], my_list_item[0][4]


def test_buy_and_open_a_box_then_list_to_marketplace_and_other_buy_it(contracts_dict):
    token_id, price = test_buy_and_open_a_box_then_list_to_marketplace(contracts_dict)

    account_3 = get_account(index=3)
    print(f"Inventory {account_3} before Buy: ")
    my_item = contracts_dict["address_saturn_mkp"].getMyItems({"from": account_3})
    print(my_item)

    print(f"Address {account_3} is buying token {token_id} with price {price} wei......")
    contracts_dict["address_saturn_mkp"].purchaseNFT(token_id, {"from": account_3, "value": price})
    print("Buy successfully")

    print(f"Inventory {account_3} after Buy: ")
    my_item = contracts_dict["address_saturn_mkp"].getMyItems({"from": account_3})
    print(my_item)


def main():
    resp = deploy_contract()
    print("Deploy successfully!")
    print(resp)
    test_buy_and_open_a_box_then_list_to_marketplace_and_other_buy_it(resp)
