// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { EnumerableSet } from "./libraries/EnumerableSet.sol";
import { IOraclesManager } from "./interfaces/IOraclesManager.sol";

/// @dev The base contract for oracles management. Allows adding/removing oracles,
/// managing the minimal number oracles for the confirmations.
contract OraclesManager is Ownable, IOraclesManager {
    using EnumerableSet for EnumerableSet.AddressSet;
    /* ========== STATE VARIABLES ========== */

    uint8 internal _threshHold;
    EnumerableSet.AddressSet private _oracleAddresses;

    /**
     * @notice Constructor
     */
    constructor() {
        _oracleAddresses.add(0x8A7dee5370e2BB2F4105932f69E8B7946f532988);
        _oracleAddresses.add(0x7f247AcFb53b348373843aF3aC6D003c0641bd21);
        _oracleAddresses.add(0x3b2C170F06D6Efe0903B405C07637dDEDA264CE3);
        _threshHold = 3;
    }

    /* ========== ADMIN ========== */

    function setThreshhold(uint8 threshold_) external override onlyOwner {
        if (threshold_ < 1) revert LowThreshold();
        _threshHold = threshold_;
    }

    function addOracles(address[] calldata oracles_) external override onlyOwner {
        uint256 length = oracles_.length;

        for (uint256 i = 0; i < length; ) {
            if (_oracleAddresses.contains(oracles_[i])) revert OracleAlreadyExist();
            _oracleAddresses.add(oracles_[i]);

            unchecked {
                ++i;
            }
        }
        emit AddOracles(oracles_);
    }

    function removeOracles(address[] calldata oracles_) external override onlyOwner {
        uint256 length = oracles_.length;
        for (uint256 i = 0; i < length; i++) {
            if (!_oracleAddresses.contains(oracles_[i])) revert OracleNotFound();
            _oracleAddresses.remove(oracles_[i]);
            unchecked {
                ++i;
            }
        }
        emit RemoveOracles(oracles_);
    }

    /* ========== VIEW ========== */

    function threshHold() external view returns (uint8) {
        return _threshHold;
    }

    function isValidOracle(address oracle) external view override returns (bool) {
        return _isValidOracle(oracle);
    }

    function viewCountOracles() external view override returns (uint256) {
        return _viewCountOracles();
    }

    function viewOracles(uint256 cursor, uint256 size) external view override returns (address[] memory, uint256) {
        uint256 length = size;

        if (length > _oracleAddresses.length() - cursor) {
            length = _oracleAddresses.length() - cursor;
        }

        address[] memory oracleAddresses = new address[](length);

        for (uint256 i = 0; i < length; ) {
            oracleAddresses[i] = _oracleAddresses.at(cursor + i);
            unchecked {
                ++i;
            }
        }

        return (oracleAddresses, cursor + length);
    }

    function _viewCountOracles() internal view returns (uint256) {
        return _oracleAddresses.length();
    }

    function _isValidOracle(address oracle) internal view returns (bool) {
        return _oracleAddresses.contains(oracle);
    }

    function _indexOf(address oracle) internal view returns (uint256) {
        return _oracleAddresses.indexOf(oracle);
    }
}
