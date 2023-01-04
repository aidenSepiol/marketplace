// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/AgentStats.sol";
import "./SaturnBoxDetail.sol";
import "./Utils.sol";
import "../interfaces/IAgentRepo.sol";

// to init all Agent
contract AgentRepo is AccessControl, IAgentRepo {
    using SaturnBoxDetail for SaturnBoxDetail.BoxDetail;

    uint256 private countQuantityAgents;
    // function initialize public {
    //     //setup role
    // }

    // array agent for random choose
    AgentStats[] public agentStats;
    uint256[] private AgentWeights;

    function initializeAgent(
        address[] memory contractAddress,
        uint256[] memory agentWeights
    ) external {
        delete agentStats;
        countQuantityAgents = 0;
        for (uint256 i = 0; i < contractAddress.length; i++) {
            agentStats.push(AgentStats(contractAddress[i]));
            AgentWeights.push(agentWeights[i]);
            countQuantityAgents += 1;
        }
    }

    // for contract SaturnBox request
    function getRandomAgentId(uint256 seed)
        external
        view
        returns (uint256, uint256)
    {
        uint256 agentId;
        (seed, agentId) = Utils.randomByWeights(seed, AgentWeights);
        return (seed, agentId);
    }

    // for contract SaturnMarketPlace request to get URI  input(agentName, rarity, seed) returns(uint256 URI)
    // function createRandomToken() external
}
