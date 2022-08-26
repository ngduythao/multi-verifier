// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IClaimRewards } from "./interfaces/IClaimRewards.sol";
import { Affiliate } from "./Affiliate.sol";
import { SignatureVerifier } from "./SignatureVerifier.sol";
import { TokenRecover } from "./TokenRecover.sol";

contract ClaimRewards is IClaimRewards, Affiliate, SignatureVerifier, TokenRecover, ReentrancyGuard {
    mapping(bytes32 => bool) private _isClaimed;

    fallback() external payable {}

    constructor() {
        _configAffiliate(0xC8d124633A540d6FeD2fBFacfAc4792B08749413, 300);
    }

    function _getMessageHash(
        address user,
        address[] memory tokens,
        uint256[] memory amounts,
        uint256 deadline
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, tokens, amounts, deadline));
    }

    function claim(
        address[] calldata tokens_,
        uint256[] calldata amounts_,
        uint256 deadline_,
        Signature[] calldata signatures_
    ) external nonReentrant {
        uint256 length = tokens_.length;
        address sender = _msgSender();
        bytes32 submissionId = _getMessageHash(sender, tokens_, amounts_, deadline_);

        if (length != amounts_.length) revert LengthMismatch();
        if (_isClaimed[submissionId]) revert DoubleSpending();

        _submit(submissionId, deadline_, signatures_);
        _isClaimed[submissionId] = true;

        for (uint256 i = 0; i < length; i++) {
            uint256 affiliateAmount = (amounts_[i] * affiliatePercent) / maxPercent;
            __transfer(affiliateAddress, tokens_[i], affiliateAmount);
            __transfer(sender, tokens_[i], amounts_[i] - affiliateAmount);
        }

        emit Claim(sender, submissionId);
    }

    function isClaim(bytes32 submissionId_) external view returns (bool) {
        return _isClaimed[submissionId_];
    }
}
