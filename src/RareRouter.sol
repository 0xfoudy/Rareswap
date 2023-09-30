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
    We first get the optimal amountA using amountBDesired, if it's less than amountAMin, we get the optimal amountB for amountADesired
    */
    function addLiquidity(address tokenA_, address tokenB_, uint256 amountADesired_, uint256 amountBDesired_, uint256 amountAMin_, uint256 amountBMin_) public returns (uint256 amountA, uint256 amountB, uint256 liquidity){
        address pair = factory.pairs(tokenA_, tokenB_);
        if(pair == address(0)){
            pair = factory.createPair(tokenA_, tokenB_);
            amountA = amountADesired_;
            amountB = amountBDesired_;
        }
        else {
            (uint256 reserveA, uint256 reserveB) = factory.getReserves(tokenA_, tokenB_);

            amountA = handleAddLiqAmountIn(amountBDesired_, reserveB, reserveA);
            if(amountA <= amountADesired_) {
                require(amountA >= amountAMin_, "Insufficient minimum input A");
                amountB = amountBDesired_;
            }
            else {
                amountB = handleAddLiqAmountIn(amountADesired_, reserveA, reserveB);
                require(amountB <= amountBDesired_, "Insufficient maximum input B");
                require(amountB >= amountBMin_, "Insufficient minimum input B");
                amountA = amountADesired_;
            }
            }
        SafeERC20.safeTransferFrom(IERC20(tokenA_), msg.sender, pair, amountA);
        SafeERC20.safeTransferFrom(IERC20(tokenB_), msg.sender, pair, amountB);
        
        liquidity = RarePair(pair).mint(msg.sender);
    }

    // dx/X = dy/Y => dy = Ydx/X
    function handleAddLiqAmountIn(uint256 amountAIn, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB) {
        amountB = (reserveB * amountAIn) / reserveA;
    }

    function removeLiquidity() public{

    }

    // returns the amount one would require to put in order to get specified amountOut
    function getAmountsIn(uint256 amountOut, address[] memory path) public view returns (uint256[] memory amounts) {
        for(uint256 i = 0; i < path.length - 1; ++i) {
            (uint256 reserveIn, uint256 reserveOut) = factory.getReserves(path[0], path[1]);
            amounts[i] = _getAmountIn(amountOut, reserveIn, reserveOut);
        }
    }

    function _getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountIn) {
        require(reserveOut > 0 && reserveIn > 0, "Not enough tokens in reserve");
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        return numerator / denominator + 1; // + 1 to round up and make sure user provides a little bit more
    }

    // returns the amount one would receive for putting in amountIn
    function getAmountsOut(uint256 amountIn, address[] memory path) public view returns (uint256[] memory amounts) {
        for(uint256 i = 0; i < path.length - 1; ++i) {
            (uint256 reserveIn, uint256 reserveOut) = factory.getReserves(path[0], path[1]);
            amounts[i] = _getAmountIn(amountIn, reserveIn, reserveOut);
        } 
    }

    function _getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut) {
        require(reserveOut > 0 && reserveIn > 0, "Not enough tokens in reserve");
        uint256 amountInAfterFee = amountIn * 997;
        uint256 numerator = reserveOut * amountInAfterFee;
        uint256 denominator = reserveIn * 1000 + amountInAfterFee; // doing (reserveIn + amountIn) * 1000 would calculate for amountIn before fees
        return numerator / denominator;
    }

    function swapExactTokenForAmount(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts) {

    }

    function swapTokenForExactAmount(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts) {
        
    }
}