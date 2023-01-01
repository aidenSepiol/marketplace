from brownie import accounts, config, HelloWorld
import os


def read_value():
    c_hello_world = HelloWorld[-1]
    result = c_hello_world.retrieve()
    print(result)
    return


def main():
    read_value()
