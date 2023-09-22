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
    }

    function testAddLiquidity18Dec() public {
        tokenA = new DummyToken("Token A", "A", 10**8 * 10**18, 18);
        tokenB = new DummyToken("Token B", "B", 10**10 * 10**18, 18);

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        tokenA.approve(address(router), 10**32);
        tokenB.approve(address(router), 10**32);

        router.addLiquidity(address(tokenA), address(tokenB), 2 * 10**18, 2 * 10**18, 10**18, 10**18);
        address createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).balanceOf(address(this)), 2 * 10**18);

        router.addLiquidity(address(tokenA), address(tokenB), 2 * 10**18, 2 * 10**18, 10**18, 10**18);
        createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).balanceOf(address(this)), 4 * 10**18);
    }

        function testAddLiquidity32Dec() public {
        tokenA = new DummyToken("Token A", "A", (10**8 * 10**32), 32);
        tokenB = new DummyToken("Token B", "B", (10**10 * 10**32), 32);

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        tokenA.approve(address(router), 10**10 * 10**32);
        tokenB.approve(address(router), 10**10 * 10**32);

        router.addLiquidity(address(tokenA), address(tokenB), 2 * 10**32, 2 * 10**32, 10**30, 10**30);
        address createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).balanceOf(address(this)), 2 * 10**18);

        router.addLiquidity(address(tokenA), address(tokenB), 2 * 10**32, 2 * 10**32, 10**30, 10**30);
        createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).balanceOf(address(this)), 4 * 10**18);
    }

    function testAddLiquidityDiffDec() public {
        tokenA = new DummyToken("Token A", "A", (10**8 * 10**18), 18);
        tokenB = new DummyToken("Token B", "B", (10**10 * 10**32), 32);

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        tokenA.approve(address(router), 10**8*10**32);
        tokenB.approve(address(router), 10**10*10**32);

        router.addLiquidity(address(tokenA), address(tokenB), 9*10**7 * 10**18, 9*10**9 * 10**32, 9*10**7 * 10**18, 9*10**9 * 10**32);
        address createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).balanceOf(address(this)), 9*10**8 * 10**18);

        router.addLiquidity(address(tokenA), address(tokenB), 10**7 * 10**18, 10**9 * 10**32, 10**7 * 10**18, 10**9 * 10**32);
        createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).balanceOf(address(this)), 10**9 * 10**18);
    }

    // any product giving a decimal lower than 10^18 would give 0
    function testAddTinyLiq() public {
        tokenA = new DummyToken("Token A", "A", (10**8 * 10**18), 18);
        tokenB = new DummyToken("Token B", "B", (10**10 * 10**32), 32);
        uint256 liquidityBalance = 0;

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        tokenA.approve(address(router), 10**8*10**32);
        tokenB.approve(address(router), 10**10*10**32);

        vm.expectRevert("not enough liquidity minted");
        router.addLiquidity(address(tokenA), address(tokenB), 10**10, 10**7, 10**4, 10**10);

        // smallest accepted product balance should be 10e18 (10e-18 after rounding)
        router.addLiquidity(address(tokenA), address(tokenB), 10**12, 10**20, 10**4, 10**10);
        address createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        liquidityBalance = IERC20(createdPair).balanceOf(address(this));
        assertEq(liquidityBalance, 10**9);

        router.addLiquidity(address(tokenA), address(tokenB), 10**16, 10**30, 10**16, 10**30);
        assertEq(factory.allPairsLength(), 1);
        createdPair = factory.pairs(address(tokenA), address(tokenB));
        assertEq(createdPair, address(factory.allPairs(0)));
        liquidityBalance = IERC20(createdPair).balanceOf(address(this));
        assertEq(IERC20(createdPair).balanceOf(address(this)), 10**16 + 10**9);
    /*     1_000_000_000     
10_000_004_999_998_750
*/
    }
}