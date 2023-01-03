from solcx import compile_standard

with open("contracts/SaturnMarketPlace.sol", "r") as f:
    sol_file = f.read()
    print(sol_file)


# compile
compile_input = {
    "language": "Solidity",
    "sources": {
        "SaturnMarketPlace.sol": {
            "keccak256": "",
            "urls": []
        }
    },
    "settings": {},
    "evmVersion": "byzantium",
    "viaIR": True,
    "debug": {},
    "metadata": {},
    "libraries": {},
    "outputSelection": {},
    "modelChecker": {}
}
compile_sol = compile_standard()
