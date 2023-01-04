// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SaturnBoxDetail {
    struct BoxDetail {
        uint256 _id;
        uint256 _targetBLock; // index of id in user token array
        uint256 _price; // price box
        uint256 _box_type; // 1 -> 3: agent box.
        bool _is_opened; // 0: still not open, 1: opened
        address _owner_by; // Owner token before on chain for marketplace.
    }
}
