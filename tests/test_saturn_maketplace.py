from brownie import accounts, config, SaturnMarketPlace
from scripts.helper import get_account
from web3 import Web3


def test_update_listing_price():
    # arrange
    account_deploy = get_account()
    # act
    contract = SaturnMarketPlace.deploy({"from": account_deploy})
    new_listing_price = 0.00025
    result = contract.updateListingPrice(Web3.toWei(new_listing_price, 'ether'))
    result.wait(1)
    new_price = contract.listingPrice()
    # assert
    expect = Web3.toWei(new_listing_price, 'ether')
    assert new_price == expect
