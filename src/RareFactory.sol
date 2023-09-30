pragma solidity 0.8.21;

import "./RarePair.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract RareFactory is Ownable {

    mapping(address => mapping(address => address)) public pairs;
    address[] public allPairs;
    address public feeTo;

    constructor() Ownable(){

    }

    /*
    creates the new pair, adds it to the array of pairs (to keep count of total pairs)
    maps the tokens to the pair address (both ways) 
    */
    function createPair(address tokenA_, address tokenB_) public returns (address pair) {
        pair = address(new RarePair(tokenA_, tokenB_));
        allPairs.push(pair);
        pairs[tokenA_][tokenB_] = pair;
        pairs[tokenB_][tokenA_] = pair;
    }

    function allPairsLength() public view returns (uint256) {
        return allPairs.length; 
    }

    function getReserves(address tokenA_, address tokenB_) public view returns (uint256, uint256) {
        RarePair pair = RarePair(pairs[tokenA_][tokenB_]);
        require(address(pair) != address(0), "Pair doesn't exit");
        if(pair.tokenA() == tokenA_){ // making sure that tokenA passed is the same as the one in the pair and not the otherway around
            return (intoUint256(pair.reserveA()), intoUint256(pair.reserveB()));
        }
        return (intoUint256(pair.reserveB()), intoUint256(pair.reserveA()));
    }

    function setFeeTo(address feeTo_) public onlyOwner {
        feeTo = feeTo_;
    }
}