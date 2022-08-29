// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface ISignatureVerifier {
    /* ========== STRUCT ========== */
    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /* ========== ERRORS ========== */
    error NotEnoughOracles();
    error InvalidOracle();
    error ExpiredSignature();
    error ReplaySignature();
    error DuplicateSignatures();

    /* ========== EVENTS ========== */

    /// @dev Emitted once the submission is confirmed by min required amount of oracles.
    event SubmissionConfirmed(bytes32 submissionId, address[] oracles);
}
