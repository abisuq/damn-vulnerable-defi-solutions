// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NewClimberVault is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 public constant WITHDRAWAL_LIMIT = 1 ether;
    uint256 public constant WAITING_PERIOD = 15 days;

    uint256 private _lastWithdrawalTimestamp;
    address private _sweeper;



    function initialize() external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function sweepFunds(address tokenAddress) external {
        IERC20(tokenAddress).transfer(
            msg.sender,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}
