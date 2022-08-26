// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IOraclesManager {
    /* ========== ERRORS ========== */

    error OracleAlreadyExist();
    error OracleNotFound();
    error LowThreshold();

    /* ========== EVENTS ========== */
    /// @dev Emitted when an oracles is added
    event AddOracles(address[] oracles);

    /// @dev Emitted when an oracles is removed
    event RemoveOracles(address[] oracles);

    /* ========== FUNCTIONS ========== */
    /// @param oracles_ Oracles' addresses.
    function addOracles(address[] calldata oracles_) external;

    /// @param oracles_ Oracles' addresses.
    function removeOracles(address[] calldata oracles_) external;

    /// @param threshold_ Sets the minimum numbers of oracles for confirming a valid request
    function setThreshhold(uint8 threshold_) external;

    /**
     * @notice Returns if an oracle is valid
     * @param oracle of the oracle
     */
    function isValidOracle(address oracle) external view returns (bool);

    /**
     * @notice View number of the oracles
     */
    function viewCountOracles() external view returns (uint256);

    /**
     * @notice See the list of oracles in the system
     * @param cursor cursor (should start at 0 for first request)
     * @param size size of the response (e.g., 50)
     */
    function viewOracles(uint256 cursor, uint256 size) external view returns (address[] memory, uint256);
}
