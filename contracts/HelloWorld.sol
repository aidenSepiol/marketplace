// SPDX-License-Identifier: None
pragma solidity ^0.8.2;

contract HelloWorld {
    string hello_solidity = "hello_solidity";

    function retrieve() external view returns (string memory) {
        return hello_solidity;
    }
}
