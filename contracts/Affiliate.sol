// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Affiliate is Ownable {
    /* ========== ERRORS ========== */
    error InvalidParams();

    /* ========== EVENTS ========== */
    /// @dev Emitted once an administrator config beneficiary and affiliate percentage
    event ConfigAffiliate(address beneficiary, uint256 percent);

    /* ========== STATE ========== */
    address internal _affiliateAddress;
    uint256 internal _affiliatePercent;
    uint256 internal _maxPercent = 10_000; // 10000 = 100% => 100 = 1%

    /* ========== FUNCTIONS ========== */
    /// @param beneficiary_ Affiliate beneficiary
    /// @param percent_ Affiliate percentage
    function configAffiliate(address beneficiary_, uint256 percent_) external onlyOwner {
        if (percent_ > _maxPercent) revert InvalidParams();
        _configAffiliate(beneficiary_, percent_);
    }

    function _configAffiliate(address beneficiary_, uint256 percent_) internal {
        _affiliateAddress = beneficiary_;
        _affiliatePercent = percent_;
        emit ConfigAffiliate(beneficiary_, percent_);
    }

    /// @dev Setting floating point precision
    function setMaxPercent(uint256 percent_) external onlyOwner {
        if (percent_ < 1_000) revert InvalidParams();
        _maxPercent = percent_;
    }

    /* ========== VIEWS ========== */
    function maxPercent() external view returns (uint256) {
        return _maxPercent;
    }

    function getAffiliate() external view returns (address, uint256) {
        return (_affiliateAddress, _affiliatePercent);
    }
}
