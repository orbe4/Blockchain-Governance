/* contracts/Swap.sol */

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

contract SimpleSwap {
   //משמש לניתוב ההחלפות לשיטות החוזה הרלוונטיות בפרוטוקול
    ISwapRouter public immutable swapRouter;
    //משתנים קבועים עבור אסימונים ERC20 אותם נחליף
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    //שכבת התשלום של הבריכה שבה אנחנו רוצים להשתמש כדי להחליף
    uint24 public constant feeTier = 3000;

		constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }
    //The function takes in one parameter, the amount of WETH we want to swap denominated
    function swapWETHForDAI(uint amountIn) external returns (uint256 amountOut) {
    // Transfer the specified amount of WETH9 to this contract.
    TransferHelper.safeTransferFrom(WETH9, msg.sender, address(this), amountIn);

		// Approve the router to spend WETH9.
    TransferHelper.safeApprove(WETH9, address(swapRouter), amountIn);
    ISwapRouter.ExactInputSingleParams memory params =
      ISwapRouter.ExactInputSingleParams({
          tokenIn: WETH9,
          tokenOut: DAI,
          fee: feeTier,
          recipient: msg.sender,
          deadline: block.timestamp,
          amountIn: amountIn,
          amountOutMinimum: 0,
          sqrtPriceLimitX96: 0
      });
  // The call to `exactInputSingle` executes the swap.
  amountOut = swapRouter.exactInputSingle(params);
  return amountOut;
    }
}