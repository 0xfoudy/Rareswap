pragma solidity 0.8.21;

import "./RarePair.sol";

contract RareFactory {

    mapping(address => mapping(address => address)) public pairs;
    address[] public allPairs;

    constructor() {

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

    function allPairsLength() public view returns (uint256){
        return allPairs.length; 
    }

}