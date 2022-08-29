// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IClaimRewards } from "./interfaces/IClaimRewards.sol";
import { Affiliate } from "./Affiliate.sol";
import { SignatureVerifier } from "./SignatureVerifier.sol";
import { TokenRecover } from "./TokenRecover.sol";

contract ClaimRewards is IClaimRewards, Affiliate, SignatureVerifier, TokenRecover, ReentrancyGuard {
    mapping(bytes32 => bool) private _hasClaimed;

    receive() external payable {}

    constructor() {
        _configAffiliate(0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6, 300); // 3%
    }

    function claim(
        address[] calldata tokens_,
        uint256[] calldata amounts_,
        uint256 deadline_,
        Signature[] calldata signatures_
    ) external nonReentrant {
        uint256 length = tokens_.length;
        address sender = _msgSender();
        bytes32 submissionId = keccak256(abi.encodePacked(sender, tokens_, amounts_, deadline_));

        if (length != amounts_.length) revert LengthMismatch();
        if (_hasClaimed[submissionId]) revert DoubleSpending();

        _hasClaimed[submissionId] = true;
        _submit(submissionId, deadline_, signatures_);

        for (uint256 i = 0; i < length; ) {
            uint256 affiliateAmount = (amounts_[i] * _affiliatePercent) / _maxPercent;
            __transfer(_affiliateAddress, tokens_[i], affiliateAmount);
            __transfer(sender, tokens_[i], amounts_[i] - affiliateAmount);
            unchecked {
                ++i;
            }
        }

        emit Claim(sender, submissionId);
    }

    function hasClaim(bytes32 submissionId_) external view returns (bool) {
        return _hasClaimed[submissionId_];
    }
}
