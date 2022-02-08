// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './UniswapV2Library.sol';
import './interfaces/IUniswapV2Router02.sol';
import './interfaces/IUniswapV2Pair.sol';
import './interfaces/IERC20.sol';
import './interfaces/IUniswapV2Factory.sol';
import './SafeMath.sol';

contract BotCode
{   
    IUniswapV2Factory public uniswapFactory;
    IUniswapV2Router02 public uniRouter;
    IUniswapV2Router02 public sushiRouter;
    IERC20 public weth = IERC20(0xc778417E063141139Fce010982780140Aa0cD5Ab);
    IERC20 public dai = IERC20(0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735);
    uint256 public MAX_INT = 2**256 - 1;

  constructor(address _factory, address _uniRouter, address _sushiRouter)  {
      uniswapFactory = IUniswapV2Factory(_factory);
      uniRouter = IUniswapV2Router02(_uniRouter);
      sushiRouter = IUniswapV2Router02(_sushiRouter);
  }

  function uniswapV2Call(address _sender, uint _amount0, uint _amount1, bytes calldata _data) external {
    // ensure that msg.sender is the correct pair
    address token0 = IUniswapV2Pair(msg.sender).token0(); 
    address token1 = IUniswapV2Pair(msg.sender).token1(); 
    assert(msg.sender == uniswapFactory.getPair(token0, token1)); 
    // at least one fo the token amounts shoudl be zero
    require(_amount0 == 0 || _amount1 == 0);
    // Approve spending token on sushiswap 
    weth.approve(address(sushiRouter),MAX_INT);
    // swap WETH to DAI on sushiswap and send the DAI directly to uniswapPair contract (which is the msg.sender in this case)
    address[] memory path = new address[](2);
    path[0] =  token0;
    path[1] =  token1;
    uint amountReservedForUniswap = UniswapV2Library.getAmountsIn(address(uniswapFactory), _amount0, path)[0];
    uint amountReceived = sushiRouter.swapExactTokensForTokens(amountToken, amountReservedForUniswap, path, msg.sender, 1 days)[1];
    // Profit goes to us
    weth.transfer(_sender, amountReceived - amountReservedForUniswap);
  }
    
}



