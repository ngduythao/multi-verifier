// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./OraclesManager.sol";
import "./interfaces/ISignatureVerifier.sol";

/// @dev It's used to verify that a transfer is signed by oracles.
contract SignatureVerifier is OraclesManager, ISignatureVerifier {
    using ECDSA for bytes32;

    mapping(address => uint256) private _currentSignedTime;

    function _getSigner(
        bytes32 messageHash_,
        uint256 deadline_,
        Signature memory signature_
    ) private view returns (address) {
        if (block.timestamp > deadline_) revert ExpiredSignature();
        if (_currentSignedTime[_msgSender()] >= deadline_) revert ReplaySignature();
        return messageHash_.toEthSignedMessageHash().recover(signature_.v, signature_.r, signature_.s);
    }

    function _setCurrentSignedTime(uint256 timestamp) internal {
        _currentSignedTime[_msgSender()] = timestamp;
    }

    /* ========== FUNCTIONS ========== */

    /// @dev Check confirmation (validate signatures) for the transfer request.
    /// @param deadline_ signature expiry time
    /// @param submissionId_ Submission identifier.
    /// @param signatures_ the ith signature on submission
    function _submit(
        bytes32 submissionId_,
        uint256 deadline_,
        Signature[] memory signatures_
    ) internal {
        uint8 needConfirmations = _threshHold;
        uint256 length = signatures_.length;

        if (length < needConfirmations) revert NotEnoughOracles();

        address[] memory oracles = new address[](needConfirmations);

        for (uint256 i = 0; i < length; ) {
            address signer = _getSigner(submissionId_, deadline_, signatures_[i]);
            if (!_isValidOracle(signer)) revert NotValidOracle();

            if (oracles[i] != address(0)) revert DuplicateSignatures();

            oracles[i] = signer;
            unchecked {
                ++i;
            }
        }

        _setCurrentSignedTime(deadline_);

        // emit SubmissionConfirmed(submissionId_, oracles);
    }
}
