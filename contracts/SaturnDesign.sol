// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SaturnBoxDetail.sol";

//DELETED
contract SaturnDesign {
    using SaturnBoxDetail for SaturnBoxDetail.BoxDetail;

    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
