// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SaturnBoxDetail {
    struct BoxDetail {
        uint256 id;
        // uint256 index; // index of id in user token array
        uint256 price; // price box
        uint256 box_type; // 1 -> 3: agent box.
        bool is_opened; // 0: still not open, 1: opened
        address owner_by; // Owner token before on chain for marketplace.
    }
}
