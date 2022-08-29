// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenRecover is Ownable {
    event TokenRecovery(address indexed token, uint256 amount);
    using SafeERC20 for IERC20;

    function recoverToken(address token_, uint256 amount_) external onlyOwner {
        __transfer(_msgSender(), token_, amount_);
        emit TokenRecovery(token_, amount_);
    }

    function __transfer(
        address account_,
        address token_,
        uint256 amount_
    ) internal {
        if (token_ == address(0)) {
            (bool success, ) = payable(account_).call{ value: amount_ }(new bytes(0));
            require(success, "TRANSFER_FAILED");
        } else {
            IERC20(token_).safeTransfer(account_, amount_);
        }
    }
}
