// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAgentRepo {
    function getRandomAgentId(uint256 seed)
        external
        view
        returns (uint256, uint256);

    // function createRandomToken(
    //     uint256 seed,
    //     uint256 id,
    //     uint256 rarity,
    //     uint256 boxType
    // ) external returns (uint256 nextSeed);
}
