// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract UniswapExample {
    address owner;
    address public factory;

    modifier onlyOwner(address sender) {
        require(sender == owner, "UniswapExample: Not owner");
        _;
    }

    constructor(address factory_) {
        owner = msg.sender;
        factory = factory_;
    }

    function pairInfo(address tokenA, address tokenB)
        internal
        view
        returns (
            uint256 reserveA,
            uint256 reserveB,
            uint256 totalSupply
        )
    {
        IUniswapV2Pair pair = IUniswapV2Pair(
            UniswapV2Library.pairFor(factory, tokenA, tokenB)
        );
        totalSupply = pair.totalSupply();
        (uint256 reserves0, uint256 reserves1, ) = pair.getReserves();
        (reserveA, reserveB) = tokenA == pair.token0()
            ? (reserves0, reserves1)
            : (reserves1, reserves0);
    }

    // Implement {IUniswapV2Callee}, to see https://github.com/Uniswap/v2-core/blob/HEAD/contracts/interfaces/IUniswapV2Callee.sol
    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external onlyOwner(sender) {
        address token0 = IUniswapV2Pair(msg.sender).token0(); // fetch the address of token0
        address token1 = IUniswapV2Pair(msg.sender).token1(); // fetch the address of token1
        assert(
            msg.sender == IUniswapV2Factory(factory).getPair(token0, token1)
        ); // ensure that msg.sender is a V2 pair
        // rest of the function goes here!
    }
}
