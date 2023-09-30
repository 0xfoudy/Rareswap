pragma solidity 0.8.21;

import "./RareERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";
import "prb-math/UD60x18.sol";
import "./RareFactory.sol";

/**
 *
 * This implementation serves two purposes
 * Automated market making and keeping track of pool token balances
 *
 */
contract RarePair is RareERC20 {
    address public tokenA;
    address public tokenB;
    UD60x18 public reserveA;
    UD60x18 public reserveB;
    uint256 public constant INIT_BURNED_LP = 1_000;
    address public immutable factory;

    constructor(address tokenA_, address tokenB_) RareERC20() {
        tokenA = tokenA_;
        tokenB = tokenB_;
        factory = msg.sender;
    }


    function mint(address to) external returns (uint256 toMint){
        // dx/dy must be equal to x/y (maybe must check in addliquidity function in router instead of here)
        uint256 balanceA = IERC20(tokenA).balanceOf(address(this));
        uint256 balanceB = IERC20(tokenB).balanceOf(address(this));
        require(balanceA*balanceB >= 10**18, "Provided token amounts too small"); // amountA*amountB would otherwise underflow

        UD60x18 amountA = ud(balanceA); // X+dx
        UD60x18 amountB = ud(balanceB); // X+dy
        
        // L1/L0 = (T+s)/T
        // s = T(L1-L0)/L0
        //L1 total liquidity = sqrt(X+dx * Y+dy)
        UD60x18 totalSupply = ud(totalSupply());
        if(totalSupply == ud(0)){
            toMint = intoUint256(sqrt(amountA*amountB)) - INIT_BURNED_LP; // amountA*amountB needs to be higher than 10^18, would underflow otherwise.
            _mint(address(0), INIT_BURNED_LP);
        }
        else {
            UD60x18 dx = amountA - reserveA;
            UD60x18 dy = amountB - reserveB;
            UD60x18 tdxByX = totalSupply * dx / reserveA;
            UD60x18 tdyByY = totalSupply * dy / reserveB;
            toMint = intoUint256(tdxByX < tdyByY ? tdxByX : tdyByY); // min(Tdx/X, Tdy/y) or simply sqrt(dx*dy)
        }

        reserveA = amountA; // update X
        reserveB = amountB; // update Y

        require(toMint > 0, "Not enough liquidity minted");

        address feeTo = RareFactory(factory).feeTo();

        if(feeTo != address(0)){
            uint256 protocolMintShare = toMint * 5 / 10_000; // 0.05% of the amount to mint
          _mint(feeTo, protocolMintShare); 
          toMint -= protocolMintShare;
        }
        _mint(to, toMint);
    }
}