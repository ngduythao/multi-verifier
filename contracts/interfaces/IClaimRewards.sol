// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IClaimRewards {
    /* ========== ERRORS ========== */
    error LengthMismatch();
    error DoubleSpending();

    /* ========== EVENTS ========== */
    /// @dev Emitted once the submission is confirmed by min required amount of oracles.
    event Claim(address user, bytes32 submissionId);
}
