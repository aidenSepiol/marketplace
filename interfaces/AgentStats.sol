// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AgentStats {
    struct StatsRange {
        uint256 min;
        uint256 max;
    }

    struct Stats {
        StatsRange damage;
        StatsRange hp;
        StatsRange evasion;
        StatsRange armor;
        StatsRange combo;
        StatsRange precision;
        StatsRange accuracy;
        StatsRange counter;
        StatsRange reversal;
        StatsRange lock;
        StatsRange disarm;
        StatsRange speed;
    }

    // function getStats(uint256 rarity) external view returns (Stats memory);
}
