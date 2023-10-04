pragma solidity 0.8.21;

import "./RareFactory.sol";

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

    /** 
     * returns the amount one would require to put in order to get specified amountOut
     * first element of amounts is amountOut 
     * */ 
    function getAmountsIn(uint256 amountOut, address[] memory path) public view returns (uint256[] memory amounts) {
        amounts = new uint256[](path.length);
        amounts[path.length - 1] = amountOut;
        for(uint256 i = path.length - 1; i > 0; --i) {
            (uint256 reserveIn, uint256 reserveOut) = factory.getReserves(path[i], path[i-1]);
            amounts[i-1] = _getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
    
    // dx = Xdy / (Y-dy)
    function _getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountIn) {
        require(reserveOut > 0 && reserveIn > 0, "Not enough tokens in reserve");
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        return (numerator / denominator) + 1; // + 1 to round up and make sure user provides a little bit more
    }

    /**
     * returns the amount one would receive for putting in amountIn
     * first element of amounts is amountIn 
     * */
    function getAmountsOut(uint256 amountIn, address[] memory path) public view returns (uint256[] memory amounts) {
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for(uint256 i = 0; i < path.length - 1; ++i) {
            (uint256 reserveIn, uint256 reserveOut) = factory.getReserves(path[i], path[i+1]);
            amounts[i+1] = _getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // dy = Ydx / (X+dx)
    function _getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut) {
        require(reserveOut > 0 && reserveIn > 0, "Not enough tokens in reserve");
        uint256 amountInAfterFee = amountIn * 997;
        uint256 numerator = reserveOut * amountInAfterFee;
        uint256 denominator = reserveIn * 1000 + amountInAfterFee; // doing (reserveIn + amountIn) * 1000 would calculate for amountIn before fees
        return numerator / denominator;
    }

    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts) {
        address oldTo = to;

        amounts = getAmountsOut(amountIn, path);
        uint256 length = path.length - 1;
        require(amounts[length] >= amountOutMin, "Insufficient amountOutMin");
        for(uint256 i = 0; i < length; ++i) {
            RarePair pair = RarePair(factory.pairs(path[i], path[i+1]));

            SafeERC20.safeTransferFrom(IERC20(path[i]), msg.sender, address(pair), amounts[i]);

            if(i < length - 1) to = msg.sender;
            else to = oldTo;

            if(path[i] == pair.tokenA()) {
                pair.swap(0, amounts[i+1], to, "");
            }
            else {
                pair.swap(amounts[i+1], 0, to, "");
            }
        }
    }

    function swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts) {
        address oldTo = to;
        
        amounts = getAmountsIn(amountOut, path);
        uint256 length = path.length - 1;
        require(amounts[length] <= amountInMax, "Insufficient amountOutMin");
        for(uint256 i = 0; i < length; ++i) {
            RarePair pair = RarePair(factory.pairs(path[i], path[i+1]));
            SafeERC20.safeTransferFrom(IERC20(path[i]), msg.sender, address(pair), amounts[i]);

            if(i < length - 1) to = msg.sender;
            else to = oldTo;

            if(path[i] == pair.tokenA()) {
                pair.swap(0, amounts[i+1], to, "");
            }
            else {
                pair.swap(amounts[i+1], 0, to, "");
            }
        }
    }
}