// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Affiliate is Ownable {
    event ConfigAffiliate(address user, uint256 percent);

    address public affiliateAddress;
    uint256 public affiliatePercent;
    uint256 public maxPercent = 10000;

    function configAffiliate(address account, uint256 percent) external onlyOwner {
        require(percent <= maxPercent, "Claim: Invalid percent");
        _configAffiliate(account, percent);
    }

    function _configAffiliate(address account, uint256 percent) internal {
        affiliateAddress = account;
        affiliatePercent = percent;
        emit ConfigAffiliate(account, percent);
    }

    function setMaxPercent(uint256 percent) external onlyOwner {
        require(percent >= 1000, "Claim: Invalid percent");
        maxPercent = percent;
    }
}
