pragma solidity 0.8.21;
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DummyToken is ERC20{
    uint8 private immutable _DECIMALS;
    constructor(string memory name_, string memory symbol_, uint256 totalSupply_, uint8 decimals_) ERC20(name_, symbol_) {
        _DECIMALS = decimals_;
        _mint(msg.sender, totalSupply_);
    }

    function decimals() public view virtual override returns (uint8) {
        return _DECIMALS;
    }
}