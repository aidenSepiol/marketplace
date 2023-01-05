// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISaturnMarketPlace {
    function mint(
        address owner,
        uint256 agentId,
        uint256 rarity,
        uint256 seed
    ) external;
}
