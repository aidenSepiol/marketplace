from brownie import ABreach, ABrimStone, ACypher, AJett, AOmen, APhoenix, ARaze, ASage, ASova, AViper, AgentRepo, SaturnBox, SaturnMarketPlace

from scripts.helper import get_account


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


def test(contracts_dict):
    pass


def main():
    resp = deploy_contract()
    print("Deploy successfully!")
    print(resp)
    test(resp)
