// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAgentRepo {
    function getRandomAgentId(uint256 seed)
        external
        view
        returns (uint256, uint256);

    function createRandomToken(
        uint256 tokenId,
        uint256 agentId,
        uint256 rarity,
        uint256 seed
    ) external view returns (uint256 nextSeed, uint256 tokenURI);

    function getAgentImg(uint256 agentId)
        external
        view
        returns (string memory agentImg);
}
