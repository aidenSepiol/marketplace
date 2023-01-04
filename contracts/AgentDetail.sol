// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// to generate the tokenURI in marketplace for offchain and onchain purposes
library AgentDetail {
    struct Detail {
        //
        uint256 agent_id;
        uint256 is_onchain;
        // Agent Stat
        uint256 damage;
        uint256 hp;
        uint256 evasion;
        uint256 armor;
        uint256 combo;
        uint256 precision;
        uint256 accuracy;
        uint256 counter;
        uint256 reversal;
        uint256 lock;
        uint256 disarm;
        uint256 speed;
        // Agent Skill
        uint256 skill_1;
        uint256 skill_2;
        uint256 skill_3;
        uint256 ultimate;
    }

    // TODO: write encode
    function encode(Detail memory details) internal pure returns (uint256) {
        return 1;
    }

    // TODO: write decode
    function decode(uint256 details)
        internal
        pure
        returns (Detail memory result)
    {
        result.agent_id = 1;
    }
}
