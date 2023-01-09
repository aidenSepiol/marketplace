from brownie import Wei, ABreach, ABrimStone, ACypher, AJett, AOmen, APhoenix, ARaze, ASage, ASova, AViper, AgentRepo, SaturnBox, SaturnMarketPlace

from scripts.helper import get_account
from web3 import Web3
import json


def deploy_contract():
    account = get_account()

    # Deploy the contract AgentRepo
    address_agent_repo = AgentRepo.deploy({"from": account})
    # Deploy the contract of Agent (10 agents)
    address_agent_breach = ABreach.deploy(address_agent_repo.address, {"from": account})
    address_agent_brimstone = ABrimStone.deploy(address_agent_repo.address, {"from": account})
    address_agent_cypher = ACypher.deploy(address_agent_repo.address, {"from": account})
    address_agent_jett = AJett.deploy(address_agent_repo.address, {"from": account})
    address_agent_omen = AOmen.deploy(address_agent_repo.address, {"from": account})
    address_agent_phoenix = APhoenix.deploy(address_agent_repo.address, {"from": account})
    address_agent_raze = ARaze.deploy(address_agent_repo.address, {"from": account})
    address_agent_sage = ASage.deploy(address_agent_repo.address, {"from": account})
    address_agent_sova = ASova.deploy(address_agent_repo.address, {"from": account})
    address_agent_viper = AViper.deploy(address_agent_repo.address, {"from": account})
    # Deploy the contract SaturnBox
    address_saturn_box = SaturnBox.deploy({"from": account})
    # Deploy the contract SaturnMarketPlace
    address_saturn_mkp = SaturnMarketPlace.deploy(address_saturn_box.address, {"from": account})

    # For AgentRepo
    list_agent_address = [
        address_agent_breach.address,
        address_agent_brimstone.address,
        address_agent_cypher.address,
        address_agent_jett.address,
        address_agent_omen.address,
        address_agent_phoenix.address,
        address_agent_raze.address,
        address_agent_sage.address,
        address_agent_sova.address,
        address_agent_viper.address
    ]
    list_agent_weights = [1] * len(list_agent_address)
    list_agent_imgs = [
        "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/centaur.jpg",
        "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/cyclops.jpg",
        "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/demon.jpg",
        "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/gargoyle.jpg",
        "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/griffin.jpg",
        "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/manticore.jpg",
        "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/minotaur.jpg",
        "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/satyr.jpg",
        "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/succubus.jpg",
        "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/werewolf.jpg"
    ]
    list_agent_names = ["Centaur", "Cyclops", "Demon", "Gargoyle", "Griffin", "Manticore", "Minotaur", "Satyr", "Succubus", "Werewolf"]
    address_agent_repo.initializeAgent(list_agent_address, list_agent_weights, list_agent_imgs, list_agent_names, {"from": account})
    address_agent_repo.setupRoleSaturnBox(address_saturn_box.address, {"from": account})
    address_agent_repo.setupRoleSaturnMKP(address_saturn_mkp.address, {"from": account})

    # For SaturnBox
    address_saturn_box.initializeContract(address_agent_repo.address, address_saturn_mkp.address, {"from": account})
    address_saturn_box.updateBoxURI(1, "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/smallBox.jpg", {"from": account})
    address_saturn_box.updateBoxURI(2, "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/bigBox.jpg", {"from": account})
    address_saturn_box.updateBoxURI(3, "https://gateway.pinata.cloud/ipfs/QmQJarrWrT9qNVWHkBGHJnDPD7LcxXVJsAePJogamuqpv4/megaBox.jpg", {"from": account})

    # For SaturnMarketPlace
    address_saturn_mkp.initializeContract(address_agent_repo.address, {"from": account})

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


def test_get_price(contracts_dict):
    account_2 = get_account(index=2)
    result = contracts_dict["address_saturn_mkp"].getWithdrawPrice({"from": account_2})
    print(f"getWithdrawPrice: {result}")


def test_buy_a_box(contracts_dict):
    import time
    account_2 = get_account(index=2)
    contracts_dict["address_saturn_box"].purchaseBox(1, {"from": account_2, "value": 2000000000000})
    contracts_dict["address_saturn_box"].purchaseBox(2, {"from": account_2, "value": 2000000000000})
    time.sleep(3)
    my_box = contracts_dict["address_saturn_box"].getMyBox({"from": account_2})
    print(my_box)

    account_3 = get_account(index=3)
    contracts_dict["address_saturn_box"].purchaseBox(1, {"from": account_3, "value": 2000000000000})
    contracts_dict["address_saturn_box"].purchaseBox(2, {"from": account_3, "value": 2000000000000})
    time.sleep(3)
    my_box = contracts_dict["address_saturn_box"].getMyBox({"from": account_3})
    print(my_box)


def test_buy_and_open_a_box(contracts_dict):
    import time
    # buy a box
    print("Buying a box........")
    account_2 = get_account(index=2)
    contracts_dict["address_saturn_box"].purchaseBox(1, {"from": account_2, "value": 20000000000000})
    contracts_dict["address_saturn_box"].purchaseBox(3, {"from": account_2, "value": 40000000000000})
    contracts_dict["address_saturn_box"].purchaseBox(2, {"from": account_2, "value": 30000000000000})
    contracts_dict["address_saturn_box"].purchaseBox(1, {"from": account_2, "value": 20000000000000})
    contracts_dict["address_saturn_box"].purchaseBox(2, {"from": account_2, "value": 30000000000000})
    contracts_dict["address_saturn_box"].purchaseBox(3, {"from": account_2, "value": 40000000000000})
    contracts_dict["address_saturn_box"].purchaseBox(3, {"from": account_2, "value": 40000000000000})
    contracts_dict["address_saturn_box"].purchaseBox(2, {"from": account_2, "value": 30000000000000})
    contracts_dict["address_saturn_box"].purchaseBox(1, {"from": account_2, "value": 20000000000000})
    contracts_dict["address_saturn_box"].purchaseBox(2, {"from": account_2, "value": 30000000000000})
    my_box = contracts_dict["address_saturn_box"].getMyBox({"from": account_2})
    print(f"Bought successfully: {my_box}")

    # before unbox
    before = contracts_dict["address_saturn_mkp"].getMyItems({"from": account_2})
    print(f"Inventory before openBox: {before}")

    # open my box

    print("Opening my first box........")
    # first_box = my_box[0][0]
    # box_id = first_box[0]
    contracts_dict["address_saturn_box"].openBox(my_box[0][0], {"from": account_2, "value": 2000000000000})
    contracts_dict["address_saturn_box"].openBox(my_box[1][0], {"from": account_2, "value": 2000000000000})
    contracts_dict["address_saturn_box"].openBox(my_box[2][0], {"from": account_2, "value": 2000000000000})
    my_box = contracts_dict["address_saturn_box"].getMyBox({"from": account_2})
    print(f"Opened my first box successfully, my box left: {my_box}")

    # after unbox
    after = contracts_dict["address_saturn_mkp"].getMyItems({"from": account_2})
    print(f"Inventory after openBox: {after}")


def test_buy_and_open_a_box_then_offchain_onchain(contracts_dict):
    test_buy_and_open_a_box(contracts_dict)
    print("Listing my first NFT to marketplace........")
    account_2 = get_account(index=2)
    contracts_dict["address_saturn_mkp"].offChain(1, {"from": account_2, "value": 2000000000000})
    account_admin = get_account()
    contracts_dict["address_saturn_mkp"].onChain(1, 10483722334555312965401533399195745946207778397749250, {"from": account_admin})
    result = contracts_dict["address_saturn_mkp"].isOnChain(1, {"from": account_2})
    print(f"onchain : {result}")


def test_buy_and_open_a_box_then_list_to_marketplace(contracts_dict):
    test_buy_and_open_a_box(contracts_dict)
    print("Listing my first NFT to marketplace........")
    account_2 = get_account(index=2)
    my_item = contracts_dict["address_saturn_mkp"].getMyItems({"from": account_2})
    tokenId = my_item[0][1]
    # option test on chain require
    # contracts_dict["address_saturn_mkp"].offChain(tokenId, {"from": account_2, "value": 25000000000})
    # list
    contracts_dict["address_saturn_mkp"].sellNFT(tokenId, 25000000000, {"from": account_2, "value": 2000000000000})
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


def test_get_catalog(contracts_dict):
    account_2 = get_account(index=2)
    catalog = contracts_dict["address_saturn_box"].getCatalog({"from": account_2})
    print(f"Catalog {catalog}")


def main():
    resp = deploy_contract()
    addresses = {}
    for key, value in resp.items():
        addresses.update({key: value.address})
    print(f"Addresses {addresses}")
    with open("contract.json", "w") as f:
        f.write(json.dumps(addresses))
    print("Deploy successfully!")
    saturn_box_a = resp["address_saturn_box"].address
    print(f"SaturnBox address: {saturn_box_a}")
    saturn_mkp_a = resp["address_saturn_mkp"].address
    print(f"SaturnMarketplace address: {saturn_mkp_a}")

    print(f'export const addressSaturnBox = "{saturn_box_a}";')
    print(f'export const addressSaturnMKP = "{saturn_mkp_a}";')

    # test_get_price(resp)
    # test_get_catalog(resp)
    # test_buy_a_box(resp)
    # test_buy_and_open_a_box_then_offchain_onchain(resp)
    # test_buy_and_open_a_box(resp)
    # test_buy_and_open_a_box_then_list_to_marketplace_and_other_buy_it(resp)
