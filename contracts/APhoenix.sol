// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/AgentStats.sol";
import "./AgentDetail.sol";

contract APhoenix is AccessControl, AgentStats {
    // using AgentDetail for AgentDetail.Detail;

    mapping(uint256 => Stats) private agentRarityStats;

    function initialize() public {
        // common
        agentRarityStats[0] = Stats(
            StatsRange(36, 40),
            StatsRange(131, 218),
            StatsRange(14, 15),
            StatsRange(6, 7),
            StatsRange(12, 13),
            StatsRange(133, 139),
            StatsRange(133, 139),
            StatsRange(14, 15),
            StatsRange(14, 15),
            StatsRange(14, 15),
            StatsRange(19, 20),
            StatsRange(26, 27)
        );
        // rare
        agentRarityStats[1] = Stats(
            StatsRange(41, 46),
            StatsRange(219, 306),
            StatsRange(16, 16),
            StatsRange(8, 8),
            StatsRange(14, 14),
            StatsRange(140, 148),
            StatsRange(140, 148),
            StatsRange(16, 16),
            StatsRange(16, 16),
            StatsRange(16, 16),
            StatsRange(21, 21),
            StatsRange(28, 28)
        );
        // elite;
        agentRarityStats[2] = Stats(
            StatsRange(47, 56),
            StatsRange(307, 336),
            StatsRange(17, 19),
            StatsRange(9, 11),
            StatsRange(15, 17),
            StatsRange(149, 163),
            StatsRange(149, 163),
            StatsRange(17, 19),
            StatsRange(17, 19),
            StatsRange(17, 19),
            StatsRange(22, 24),
            StatsRange(29, 31)
        );
        // epic;
        agentRarityStats[3] = Stats(
            StatsRange(57, 70),
            StatsRange(337, 378),
            StatsRange(20, 22),
            StatsRange(12, 14),
            StatsRange(18, 20),
            StatsRange(164, 184),
            StatsRange(164, 184),
            StatsRange(20, 22),
            StatsRange(20, 22),
            StatsRange(20, 22),
            StatsRange(25, 27),
            StatsRange(32, 34)
        );
        // legendary;
        agentRarityStats[4] = Stats(
            StatsRange(73, 94),
            StatsRange(389, 450),
            StatsRange(23, 28),
            StatsRange(15, 20),
            StatsRange(21, 26),
            StatsRange(186, 220),
            StatsRange(186, 220),
            StatsRange(23, 28),
            StatsRange(23, 28),
            StatsRange(23, 28),
            StatsRange(28, 33),
            StatsRange(35, 40)
        );

        // mythical;
        agentRarityStats[5] = Stats(
            StatsRange(97, 142),
            StatsRange(461, 594),
            StatsRange(29, 40),
            StatsRange(21, 32),
            StatsRange(27, 38),
            StatsRange(222, 292),
            StatsRange(222, 292),
            StatsRange(29, 40),
            StatsRange(29, 40),
            StatsRange(29, 40),
            StatsRange(34, 45),
            StatsRange(41, 52)
        );
    }

    function getStats(uint256 rarity) external view returns (Stats memory) {
        // Get stats base
        return agentRarityStats[rarity];
    }
}
