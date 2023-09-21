pragma solidity 0.8.21;

import "./utils/ABDKMath64x64.sol";
import "./RareERC20.sol";
import "forge-std/console.sol";

/**
 *
 * This implementation serves two purposes
 * Automated market making and keeping track of pool token balances
 *
 */
contract RarePair is RareERC20 {
    address public tokenA;
    address public tokenB;
    int128 public reservesA;
    int128 public reservesB;

    constructor(address tokenA_, address tokenB_) RareERC20() {
        tokenA = tokenA_;
        tokenB = tokenB_;
    }

    /*
        supposed to mint tokens based on the 
    */
    function mint(address to) external returns (uint256 liquidity){
        int128 balanceA = ABDKMath64x64.div(ABDKMath64x64.fromUInt(IERC20(tokenA).balanceOf(address(this))), ABDKMath64x64.fromUInt(10**ERC20(tokenA).decimals()));
        int128 balanceB = ABDKMath64x64.div(ABDKMath64x64.fromUInt(IERC20(tokenB).balanceOf(address(this))), ABDKMath64x64.fromUInt(10**ERC20(tokenB).decimals()));
        reservesA = ABDKMath64x64.sub(balanceA, reservesA);
        reservesB = ABDKMath64x64.sub(balanceB, reservesB);

        liquidity = ABDKMath64x64.toUInt(ABDKMath64x64.sqrt(ABDKMath64x64.mul(reservesA, reservesB)));
        _mint(to, liquidity);
    }
  
}