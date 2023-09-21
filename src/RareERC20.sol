pragma solidity 0.8.21;
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract RareERC20 is ERC20{
    string constant private _SYMBOL = "RAREPAIR";
    string constant private _NAME = "RARE PAIR";

    constructor() ERC20(_NAME, _SYMBOL) {
    }
}