// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "../src/RareRouter.sol";
import "../src/utils/DummyToken.sol";

contract RareSwapTest is Test {
    RareRouter public router;
    DummyToken public tokenA;
    DummyToken public tokenB;
    uint256 constant LIQUIDITY_BURN = 10**3;

    function setUp() public {
        router = new RareRouter(address(new RareFactory()));
    }

    function testAddLiquidity18Dec() public {
        tokenA = new DummyToken("Token A", "A", 10**8 * 10**18, 18);
        tokenB = new DummyToken("Token B", "B", 10**10 * 10**18, 18);

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        uint256 amountADesired = 2 * 10**18;
        uint256 amountBDesired = 2 * 10**18;

        tokenA.approve(address(router), 10**32);
        tokenB.approve(address(router), 10**32);

        router.addLiquidity(address(tokenA), address(tokenB),amountADesired, amountBDesired, amountADesired, amountBDesired);
        address createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).totalSupply(), amountADesired);
        assertEq(IERC20(createdPair).balanceOf(address(this)), amountADesired - LIQUIDITY_BURN);

        router.addLiquidity(address(tokenA), address(tokenB), amountADesired, amountBDesired, amountADesired, amountADesired);
        createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).totalSupply(), 2 * amountADesired);
        assertEq(IERC20(createdPair).balanceOf(address(this)), 2 * amountADesired - LIQUIDITY_BURN);
    }

        function testAddLiquidity32Dec() public {
        tokenA = new DummyToken("Token A", "A", (10**8 * 10**32), 32);
        tokenB = new DummyToken("Token B", "B", (10**10 * 10**32), 32);

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        uint256 amountADesired = 2 * 10**32;
        uint256 amountBDesired = 2 * 10**32;
        tokenA.approve(address(router), 10**10 * 10**32);
        tokenB.approve(address(router), 10**10 * 10**32);

        router.addLiquidity(address(tokenA), address(tokenB), amountADesired, amountBDesired, amountADesired, amountBDesired);
        address createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).totalSupply(), amountADesired);
        assertEq(IERC20(createdPair).balanceOf(address(this)), amountADesired - LIQUIDITY_BURN);

        router.addLiquidity(address(tokenA), address(tokenB), amountADesired, amountBDesired, amountADesired, amountBDesired);
        createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).totalSupply(), 2* amountADesired);
        assertEq(IERC20(createdPair).balanceOf(address(this)), 2 * amountADesired - LIQUIDITY_BURN);
    }

    function testAddLiquidityDiffDec() public {
        tokenA = new DummyToken("Token A", "A", (10**8 * 10**18), 18);
        tokenB = new DummyToken("Token B", "B", (10**10 * 10**32), 32);

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        uint256 amountADesired = 9*10**7 * 10**18;
        uint256 amountBDesired = 9*10**9 * 10**32;
        tokenA.approve(address(router), 10**8*10**32);
        tokenB.approve(address(router), 10**10*10**32);

        router.addLiquidity(address(tokenA), address(tokenB), amountADesired, amountBDesired, amountADesired, amountBDesired);
        address createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).totalSupply(), 9*10**8 * 10**25);
        assertEq(IERC20(createdPair).balanceOf(address(this)), 9*10**8 * 10**25 - LIQUIDITY_BURN);

        amountADesired = 10**7 * 10**18;
        amountBDesired = ((10**9)+1_231_312_324) * 10**32; //adding random stuff to see if optimal amountIn is working
        router.addLiquidity(address(tokenA), address(tokenB), amountADesired, amountBDesired, 0, 0);
        createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).totalSupply(), 10**9 * 10**25);
        assertEq(IERC20(createdPair).balanceOf(address(this)), 10**9 * 10**25 - LIQUIDITY_BURN);
    }

    // any product giving a decimal lower than 10^18 would give 0
    function testAddTinyLiq() public {
        tokenA = new DummyToken("Token A", "A", (10**8 * 10**18), 18);
        tokenB = new DummyToken("Token B", "B", (10**10 * 10**32), 32);
        uint256 liquidityBalance = 0;

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        uint256 amountADesired = 10**10;
        uint256 amountBDesired = 10**7;
        tokenA.approve(address(router), 10**8*10**32);
        tokenB.approve(address(router), 10**10*10**32);

        vm.expectRevert("Provided token amounts too small");
        router.addLiquidity(address(tokenA), address(tokenB), amountADesired, amountBDesired, amountADesired, amountBDesired);

        // smallest accepted product balance should be 10e18     
        router.addLiquidity(address(tokenA), address(tokenB), 10**12, 10**20, 0, 0);
        address createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        uint256 totalSupply = IERC20(createdPair).totalSupply();
        liquidityBalance = IERC20(createdPair).balanceOf(address(this));
        assertEq(totalSupply, 10**16);
        assertEq(liquidityBalance, 10**16 - 10**3);

        router.addLiquidity(address(tokenA), address(tokenB), 10**16, 10**30, 0, 0);
        assertEq(factory.allPairsLength(), 1);
        createdPair = factory.pairs(address(tokenA), address(tokenB));
        assertEq(createdPair, address(factory.allPairs(0)));
        totalSupply = IERC20(createdPair).totalSupply();
        liquidityBalance = IERC20(createdPair).balanceOf(address(this));
        assertEq(totalSupply, 10**16 + 10**20);
        assertEq(IERC20(createdPair).balanceOf(address(this)), 10**16 + 10**20 - 10**3);
    }
}