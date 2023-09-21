pragma solidity 0.8.21;

import "./RareFactory.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract RareRouter {
    RareFactory public immutable factory;

    constructor(address factory_) {
        factory = RareFactory(factory_);
    }

    /*
    User must allow amountADesired and amountBDesired
    If pair doesn't exist, create new pair with desired amounts
    If pair already exists, add assets at ideal ratio, respecting existing reserves in pair
    AmountAMin AmountBMin represent the slippage, must be smaller than AmountADesired and AmountBDesired respectively.
    */
    function addLiquidity(address tokenA_, address tokenB_, uint256 amountADesired_, uint256 amountBDesired_, uint256 amountAMin_, uint256 amountBMin_) public returns (uint256 amountA, uint256 amountB, uint256 liquidity){
        address pair = factory.pairs(tokenA_, tokenB_);
        if(pair == address(0)){
            pair = factory.createPair(tokenA_, tokenB_);
        }
        //TODO: handle amountmin 
        SafeERC20.safeTransferFrom(IERC20(tokenA_), msg.sender, pair, amountADesired_);
        SafeERC20.safeTransferFrom(IERC20(tokenB_), msg.sender, pair, amountBDesired_);
        
        RarePair(pair).mint(msg.sender);
    }

    function removeLiquidity() public{

    }

    function getAmountIn() public{

    }

    function getAmountOut() public{

    }

    function swapExactTokenForAmount() public{

    }

    function swapTokenForExactAmount() public{

    }
}