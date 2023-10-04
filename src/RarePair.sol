pragma solidity 0.8.21;

import "./RareERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC3156FlashLender.sol";
import "forge-std/console.sol";
import "prb-math/UD60x18.sol";
import "./RareFactory.sol";

/**
 *
 * This implementation serves two purposes
 * Automated market making and keeping track of pool token balances
 *
 */
contract RarePair is RareERC20, IERC3156FlashLender {
    address public tokenA;
    address public tokenB;
    UD60x18 public reserveA;
    UD60x18 public reserveB;
    uint256 public constant INIT_BURNED_LP = 1_000;
    address public immutable factory;

    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    mapping(address => bool) public supportedTokens;

    constructor(address tokenA_, address tokenB_) RareERC20() {
        tokenA = tokenA_;
        tokenB = tokenB_;
        factory = msg.sender;
        supportedTokens[tokenA_] = true;
        supportedTokens[tokenB_] = true;
    }

    function mint(address to) external returns (uint256 toMint) {
        uint256 balanceA = IERC20(tokenA).balanceOf(address(this)); // X + dx
        uint256 balanceB = IERC20(tokenB).balanceOf(address(this)); // Y + dy
        require(
            balanceA * balanceB >= 10 ** 18,
            "Provided token amounts too small"
        ); // amountA*amountB needs to be higher than 10^18, would underflow otherwise in UD form.

        require(
            balanceA * balanceB <= 10 ** 72,
            "Provided token amounts too large"
        ); // amountA*amountB needs to be lower than 10^72, would overflow otherwise in UD form.

        UD60x18 amountA = ud(balanceA); // dx
        UD60x18 amountB = ud(balanceB); // dy

        UD60x18 totalSupply = ud(totalSupply());
        if (totalSupply == ud(0)) {
            toMint = intoUint256(sqrt(amountA * amountB)) - INIT_BURNED_LP;
            _mint(address(0), INIT_BURNED_LP);
        } else {
            UD60x18 dx = amountA - reserveA;
            UD60x18 dy = amountB - reserveB;
            UD60x18 tdxByX = (totalSupply * dx) / reserveA;
            UD60x18 tdyByY = (totalSupply * dy) / reserveB;
            toMint = intoUint256(tdxByX < tdyByY ? tdxByX : tdyByY); // min(Tdx/X, Tdy/y) or simply sqrt(dx*dy)
        }

        require(toMint > 0, "Not enough liquidity minted");

        address feeTo = RareFactory(factory).feeTo();

        if (feeTo != address(0)) {
            uint256 protocolMintShare = (toMint * 5) / 10_000; // 0.05% of the amount to mint
            toMint -= protocolMintShare;
            _mint(feeTo, protocolMintShare);
        }
        _mint(to, toMint);

        _updateReserves();
    }

    function burn(
        address to
    ) external returns (uint256 amountA, uint256 amountB) {
        UD60x18 liquidity = ud(balanceOf(address(this)));
        amountA = intoUint256((reserveA * liquidity) / ud(totalSupply()));
        amountB = intoUint256((reserveB * liquidity) / ud(totalSupply()));
        _burn(address(this), intoUint256(liquidity));
        SafeERC20.safeTransfer(IERC20(tokenA), to, amountA);
        SafeERC20.safeTransfer(IERC20(tokenB), to, amountB);

        _updateReserves();
    }

    // data must be 0 for regular swap, call uniswapV2Call otherwise (for flashswaps)
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to
    ) external {
        if (amount1Out == 0) {
            SafeERC20.safeTransfer(IERC20(tokenA), to, amount0Out);
        }
        else {
            require(amount0Out == 0);
            SafeERC20.safeTransfer(IERC20(tokenB), to, amount1Out);
        }
        _updateReserves();
    }

    function _updateReserves() internal {
        reserveA = ud(IERC20(tokenA).balanceOf(address(this)));
        reserveB = ud(IERC20(tokenB).balanceOf(address(this)));
    }

    function maxFlashLoan(
        address token
    ) external view override returns (uint256) {
        return supportedTokens[token] ? RareERC20(token).balanceOf(address(this)) : 0;
    }

    function flashFee(
        address token,
        uint256 amount
    ) external view override returns (uint256) {
        require(supportedTokens[token], "Unsupported token");
        return _flashFee(amount);
    }

    function _flashFee(uint256 amount) internal pure returns (uint256) {
        return (amount * 3 / 1000) + 1;
    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool) {
        require(supportedTokens[token], "Unsupported token");
        uint256 fee = _flashFee(amount);

        SafeERC20.safeTransfer(IERC20(token), address(receiver), amount);

        _updateReserves(); // updating in case of reentrancy on onFlashLoan

        require(receiver.onFlashLoan(msg.sender, token, amount, fee, data) == CALLBACK_SUCCESS, "FlashLender: Callback failed");
        
        SafeERC20.safeTransferFrom(IERC20(token), address(receiver), address(this), amount + fee);

        _updateReserves();
        return true;
    }
}