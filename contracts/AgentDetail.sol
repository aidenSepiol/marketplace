// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// to generate the tokenURI in marketplace for offchain and onchain purposes
library AgentDetail {
    struct Detail {
        // base properties
        uint256 tokenId;
        uint256 agentId;
        uint256 isOnchain;
        // extended properties
        uint256 baseRarity;
        uint256 rarity;
        uint256 level;
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
        // uint256 skill_1;
        // uint256 skill_2;
        // uint256 skill_3;
        // uint256 ultimate;
    }

    // TODO: write encode
    function encode(Detail memory detail) internal pure returns (uint256) {
        // 30 bit of uint256 for the id that mean you have < 1073741823 token only, this is the limit
        uint256 value;
        uint256 bitIndex = 30;
        value |= detail.tokenId;
        // 4 bits for agentId because we only have 10 agents MAX < 15
        value |= detail.agentId << bitIndex;
        bitIndex += 4;
        // 1 bit for isOnchain because this is boolean value 1 for true and 0 for false
        value |= detail.isOnchain << bitIndex;
        bitIndex += 1;
        // 3 bits for baseRarity because we have 6 rarity values
        value |= detail.baseRarity << bitIndex;
        bitIndex += 3;
        // 3 bits for baseRarity because we have 6 rarity values
        value |= detail.rarity << bitIndex;
        bitIndex += 3;
        // 9 bits for level, we want limit level at 500 (Max = 511)
        value |= detail.level << bitIndex;
        bitIndex += 9;
        // We limit agent Stat at 10 and 12 bits
        value |= detail.damage << bitIndex;
        bitIndex += 10;
        value |= detail.hp << bitIndex;
        bitIndex += 12;
        value |= detail.evasion << bitIndex;
        bitIndex += 12;
        value |= detail.armor << bitIndex;
        bitIndex += 10;
        value |= detail.combo << bitIndex;
        bitIndex += 10;
        value |= detail.precision << bitIndex;
        bitIndex += 12;
        value |= detail.accuracy << bitIndex;
        bitIndex += 12;
        value |= detail.counter << bitIndex;
        bitIndex += 10;
        value |= detail.reversal << bitIndex;
        bitIndex += 10;
        value |= detail.lock << bitIndex;
        bitIndex += 10;
        value |= detail.disarm << bitIndex;
        bitIndex += 10;
        value |= detail.speed << bitIndex; // 10bits
        // 4+1+3+3+9+10+12+12+10+10+12+12+10+10+10+10+10+30 = 178 bits / 256 bits
        return value;
    }

    // TODO: write decode
    function decode(uint256 detail)
        internal
        pure
        returns (Detail memory result)
    {
        uint256 bitIndex = 0;
        // 30bits tokenId max value = 1073741823
        result.tokenId = (1073741823 << bitIndex) & detail;
        bitIndex += 30;
        // 4bits agentId max value = 15
        result.agentId = (15 << bitIndex) & detail;
        bitIndex += 4;
        // 1bit isOnchain max value = 1
        result.isOnchain = (1 << bitIndex) & detail;
        bitIndex += 1;
        // 3bits baseRarity max value = 7
        result.baseRarity = (7 << bitIndex) & detail;
        bitIndex += 3;
        // 3bits rarity max value = 7
        result.rarity = (7 << bitIndex) & detail;
        bitIndex += 3;
        // 9bits level max value = 511
        result.level = (511 << bitIndex) & detail;
        bitIndex += 9;
        // rest
        result.damage = (1023 << bitIndex) & detail;
        bitIndex += 10;
        result.hp = (4095 << bitIndex) & detail;
        bitIndex += 12;
        result.evasion = (4095 << bitIndex) & detail;
        bitIndex += 12;
        result.armor = (1023 << bitIndex) & detail;
        bitIndex += 10;
        result.combo = (1023 << bitIndex) & detail;
        bitIndex += 10;
        result.precision = (4095 << bitIndex) & detail;
        bitIndex += 12;
        result.accuracy = (4095 << bitIndex) & detail;
        bitIndex += 12;
        result.counter = (1023 << bitIndex) & detail;
        bitIndex += 10;
        result.reversal = (1023 << bitIndex) & detail;
        bitIndex += 10;
        result.lock = (1023 << bitIndex) & detail;
        bitIndex += 10;
        result.disarm = (1023 << bitIndex) & detail;
        bitIndex += 10;
        result.speed = (1023 << bitIndex) & detail;

        return result;
    }
}
