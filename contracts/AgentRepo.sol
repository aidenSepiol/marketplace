// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/AgentStats.sol";
// import "./SaturnBoxDetail.sol";
import "./Utils.sol";
import "./AgentDetail.sol";
import "../interfaces/IAgentRepo.sol";
import "./Utils.sol";

// to init all Agent
contract AgentRepo is AccessControl, IAgentRepo {
    // using SaturnBoxDetail for SaturnBoxDetail.BoxDetail;
    using AgentDetail for AgentDetail.Detail;

    // this is admin, the ones who deploy this contract, we use this to recognize him when some call a function that only admin can call
    address payable admin;

    uint256 private countQuantityAgents;

    // array agent for random choose
    AgentStats[] public agentStats;
    uint256[] private AgentWeights;
    string[] private imgAgents;

    // AccessControl
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DESIGNER_ROLE = keccak256("DESIGNER_ROLE");
    bytes32 public constant SATURNBOX_ROLE = keccak256("SATURNBOX_ROLE");
    bytes32 public constant SATURNMKP_ROLE = keccak256("SATURNMKP_ROLE");
    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender) == true, "Required role");
        _;
    }

    constructor() {
        admin = payable(msg.sender);
        _setupRole(ADMIN_ROLE, admin);
    }

    function setupRoleSaturnBox(address account) external onlyRole(ADMIN_ROLE) {
        _setupRole(SATURNBOX_ROLE, account);
    }

    function setupRoleSaturnMKP(address account) external onlyRole(ADMIN_ROLE) {
        _setupRole(SATURNMKP_ROLE, account);
    }

    function initializeAgent(
        address[] memory _contractAddress,
        uint256[] memory _agentWeights,
        string[] memory _imgAgents
    ) external onlyRole(ADMIN_ROLE) {
        delete agentStats;
        delete AgentWeights;
        delete imgAgents;
        countQuantityAgents = 0;
        for (uint256 i = 0; i < _contractAddress.length; i++) {
            agentStats.push(AgentStats(_contractAddress[i]));
            AgentWeights.push(_agentWeights[i]);
            imgAgents.push(_imgAgents[i]);
            countQuantityAgents += 1;
        }
    }

    function getAgentImg(uint256 agentId)
        external
        view
        onlyRole(SATURNMKP_ROLE)
        returns (string memory)
    {
        return imgAgents[agentId];
    }

    // for contract SaturnBox request
    function getRandomAgentId(uint256 seed)
        external
        view
        onlyRole(SATURNBOX_ROLE)
        returns (uint256, uint256)
    {
        uint256 agentId;
        (seed, agentId) = Utils.randomByWeights(seed, AgentWeights);
        return (seed, agentId);
    }

    // for contract SaturnMarketPlace request to get URI  input(agentName, rarity, seed) returns(uint256 URI)
    function createRandomToken(
        uint256 tokenId,
        uint256 agentId,
        uint256 rarity,
        uint256 seed
    ) external view onlyRole(SATURNMKP_ROLE) returns (uint256, uint256) {
        // only SaturnMarketPlace allowed
        AgentDetail.Detail memory ADetail;

        ADetail.tokenId = tokenId;
        ADetail.agentId = agentId;
        ADetail.isOnchain = 1;
        ADetail.baseRarity = rarity;
        ADetail.rarity = rarity;
        ADetail.level = 1;

        AgentStats.Stats memory stats = agentStats[agentId].getStats(rarity);

        (seed, ADetail.damage) = Utils.randomRangeInclusive(
            seed,
            stats.damage.min,
            stats.damage.max
        );
        (seed, ADetail.hp) = Utils.randomRangeInclusive(
            seed,
            stats.hp.min,
            stats.hp.max
        );
        (seed, ADetail.evasion) = Utils.randomRangeInclusive(
            seed,
            stats.evasion.min,
            stats.evasion.max
        );
        (seed, ADetail.armor) = Utils.randomRangeInclusive(
            seed,
            stats.armor.min,
            stats.armor.max
        );
        (seed, ADetail.combo) = Utils.randomRangeInclusive(
            seed,
            stats.combo.min,
            stats.combo.max
        );
        (seed, ADetail.precision) = Utils.randomRangeInclusive(
            seed,
            stats.precision.min,
            stats.precision.max
        );
        (seed, ADetail.accuracy) = Utils.randomRangeInclusive(
            seed,
            stats.accuracy.min,
            stats.accuracy.max
        );
        (seed, ADetail.counter) = Utils.randomRangeInclusive(
            seed,
            stats.counter.min,
            stats.counter.max
        );
        (seed, ADetail.reversal) = Utils.randomRangeInclusive(
            seed,
            stats.reversal.min,
            stats.reversal.max
        );
        (seed, ADetail.lock) = Utils.randomRangeInclusive(
            seed,
            stats.lock.min,
            stats.lock.max
        );
        (seed, ADetail.disarm) = Utils.randomRangeInclusive(
            seed,
            stats.disarm.min,
            stats.disarm.max
        );
        (seed, ADetail.speed) = Utils.randomRangeInclusive(
            seed,
            stats.speed.min,
            stats.speed.max
        );

        uint256 tokenURI = ADetail.encode();
        return (seed, tokenURI);
    }
}
