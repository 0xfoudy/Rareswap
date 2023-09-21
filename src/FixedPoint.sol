// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "./utils/ABDKMath64x64.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Decimal18ERC20 is ERC20{
    constructor(string memory name_, string memory symbol_, uint256 totalSupply_) ERC20(name_, symbol_){
        _mint(msg.sender, totalSupply_);
    }

        function decimals() public view override returns (uint8) {
        return 18;
    }
}

contract Decimal32ERC20 is ERC20{
    constructor(string memory name_, string memory symbol_, uint256 totalSupply_) ERC20(name_, symbol_){
        _mint(msg.sender, totalSupply_);
    }

        function decimals() public view override returns (uint8) {
        return 32;
    }
}
