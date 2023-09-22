pragma solidity 0.8.21;

import "./RareERC20.sol";
import "forge-std/console.sol";
import "prb-math/UD60x18.sol";

/**
 *
 * This implementation serves two purposes
 * Automated market making and keeping track of pool token balances
 *
 */
contract RarePair is RareERC20 {
    address public tokenA;
    address public tokenB;
    UD60x18 public reservesA;
    UD60x18 public reservesB;

    constructor(address tokenA_, address tokenB_) RareERC20() {
        tokenA = tokenA_;
        tokenB = tokenB_;
    }

    /*
        function 'normalizes' the balance by dividing by the ud of decimals of each (10**18 is equivalent to 1 in UD60x18 so
        so diving by ud(10**32) is like dividing by 10**14
        note that ud also divides by 10**18.
    */
    function mint(address to) external returns (uint256 liquidity){
        // dividing or multiplying by decimals 10e18 would make no difference because 10**18 is equivalent to 1 in UD60x18

        UD60x18 balanceA = ud(IERC20(tokenA).balanceOf(address(this)))/ud(10**ERC20(tokenA).decimals()); 
        UD60x18 balanceB = ud(IERC20(tokenB).balanceOf(address(this)))/ud(10**ERC20(tokenB).decimals());
        
        reservesA = balanceA - reservesA;
        reservesB = balanceB - reservesB;

        liquidity = intoUint256(sqrt(reservesA * reservesB));

        require(liquidity > 0, "not enough liquidity minted");

        _mint(to, liquidity);
    }
}