from brownie import accounts, config, network


def get_account(index=None):
    if index and isinstance(index, int):
        return accounts[index]
    if network.show_active() == 'development':
        return accounts[0]
    else:
        return accounts.add(config['wallets']['from_key'])
