// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IClaimRewards } from "./interfaces/IClaimRewards.sol";
import { Affiliate } from "./Affiliate.sol";
import { SignatureVerifier } from "./SignatureVerifier.sol";
import { TokenRecover } from "./TokenRecover.sol";

contract ClaimRewards is IClaimRewards, Affiliate, SignatureVerifier, TokenRecover, ReentrancyGuard {
    using Address for address;

    mapping(bytes32 => bool) private _hasClaimed;

    receive() external payable {}

    constructor() {
        _configAffiliate(0x3e27432006d0Cd254B6CE77E4ff3e7B85C414863, 300); // 3%
    }

    function claim(
        bytes32 claimId_,
        address[] calldata tokens_,
        uint256[] calldata amounts_,
        uint256 deadline_,
        Signature[] calldata signatures_
    ) external nonReentrant {
        uint256 length = tokens_.length;
        address sender = _msgSender();
        bytes32 submissionId = keccak256(abi.encodePacked(claimId_, sender, tokens_, amounts_, deadline_));

        if (sender != tx.origin || sender.isContract()) revert OnlyEOA();
        if (length != amounts_.length) revert LengthMismatch();
        if (_hasClaimed[claimId_]) revert DoubleSpending();

        _hasClaimed[claimId_] = true;
        _submit(submissionId, deadline_, signatures_);

        for (uint256 i = 0; i < length; ) {
            uint256 affiliateAmount = (amounts_[i] * _affiliatePercent) / _maxPercent;
            __transfer(_affiliateAddress, tokens_[i], affiliateAmount);
            __transfer(sender, tokens_[i], amounts_[i] - affiliateAmount);
            unchecked {
                ++i;
            }
        }

        emit Claim(sender, claimId_);
    }

    function hasClaim(bytes32 claimId_) external view returns (bool) {
        return _hasClaimed[claimId_];
    }
}
