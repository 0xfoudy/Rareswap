// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "../src/RareRouter.sol";
import "../src/utils/DummyToken.sol";

contract RareSwapTest is Test {
    RareRouter public router;
    DummyToken public tokenA;
    DummyToken public tokenB;

    function setUp() public {
        router = new RareRouter(address(new RareFactory()));
        tokenA = new DummyToken("Token A", "A", 10**32);
        tokenB = new DummyToken("Token B", "B", 10**32);
    }

    function testAddLiquidity() public {
        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        tokenA.approve(address(router), 10**19);
        tokenB.approve(address(router), 10**19);

        router.addLiquidity(address(tokenA), address(tokenB), 2*10**18, 2*10**18, 10*10**18, 10*10**18);
        address createdPair = factory.pairs(address(tokenA), address(tokenB));
        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).balanceOf(address(this)), 2);

        router.addLiquidity(address(tokenA), address(tokenB), 2*10**18, 2*10**18, 10*10**18, 10*10**18);
        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).balanceOf(address(this)), 4);
    }
}
