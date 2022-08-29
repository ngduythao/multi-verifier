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
        _oracleAddresses.add(0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6);
        _oracleAddresses.add(0xf1684DaCa9FE469189A3202ae2dE25E80dcB90a1);
        _oracleAddresses.add(0x14F791eb0bd5060a4C954D6719fE4e94859Eb614);
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

    function removeOracles(address[] calldata oracles_) external onlyOwner {
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

    function isValidOracle(address oracle) external view override returns (bool) {
        return _isValidOracle(oracle);
    }

    function viewCountOracles() external view override returns (uint256) {
        return _oracleAddresses.length();
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

    function _isValidOracle(address oracle) internal view returns (bool) {
        return _oracleAddresses.contains(oracle);
    }

    function _indexOf(address oracle) internal view returns (uint256) {
        return _oracleAddresses.indexOf(oracle);
    }
}
