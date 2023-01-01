from brownie import accounts, config, HelloWorld


def test_retrieve():
    # arrange
    account_deploy = accounts.add(config['wallets']['from_key'])
    # act
    c_hello_world = HelloWorld.deploy({"from": account_deploy})
    result = c_hello_world.retrieve({"from": account_deploy})
    # assert
    expect = 'hello_solidity'
    assert result == expect
