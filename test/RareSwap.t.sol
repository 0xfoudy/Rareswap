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

        router.addLiquidity(address(tokenA), address(tokenB), amountADesired, amountBDesired*2, amountADesired, amountADesired);
        createdPair = factory.pairs(address(tokenA), address(tokenB));

        assertEq(factory.allPairsLength(), 1);
        assertEq(createdPair, address(factory.allPairs(0)));
        assertEq(IERC20(createdPair).totalSupply(), 3 * amountADesired);
        assertEq(IERC20(createdPair).balanceOf(address(this)), 3 * amountADesired - LIQUIDITY_BURN);
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

    function testAddLiqABAndSwapAB() public {
        tokenA = new DummyToken("Token A", "A", 10**10 * 10**18, 18);
        tokenB = new DummyToken("Token B", "B", 10**10 * 10**18, 18);

        address[] memory path1 = new address[](2);
        path1[0] = address(tokenA);
        path1[1] = address(tokenB);

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        uint256 amountADesired = 2 * 10**20;
        uint256 amountBDesired = 2 * 10**20;

        tokenA.approve(address(router), 10**32);
        tokenB.approve(address(router), 10**32);

        router.addLiquidity(address(tokenA), address(tokenB), amountADesired, amountBDesired, amountADesired, amountBDesired);
        RarePair pairAB = RarePair(factory.pairs(address(tokenA), address(tokenB)));
        uint256 reserveAB_A = intoUint256(pairAB.reserveA());
        uint256 reserveAB_B = intoUint256(pairAB.reserveB());  

        // swap A for B
        uint256[] memory amounts = router.swapExactTokensForTokens(100000, 0, path1, address(2), 0);
        assertEq(IERC20(tokenB).balanceOf(address(2)), 99699);
        assertEq(amounts[0], 100000);
        assertEq(amounts[1], 99699);

        // test that reserves are updating properly
        assertEq(intoUint256(pairAB.reserveA()) - reserveAB_A, amounts[0]);
        assertEq(reserveAB_B - intoUint256(pairAB.reserveB()), amounts[1]);

        reserveAB_A = intoUint256(pairAB.reserveA());
        reserveAB_B = intoUint256(pairAB.reserveB());  

        amounts = router.swapExactTokensForTokens(100000000, 0, path1, address(2), 0);
        assertEq(IERC20(tokenB).balanceOf(address(2)), 99799698);
        assertEq(amounts[0], 100000000);
        assertEq(amounts[1], 99699999);

        // test that reserves are updating properly
        assertEq(intoUint256(pairAB.reserveA()) - reserveAB_A, amounts[0]);
        assertEq(reserveAB_B - intoUint256(pairAB.reserveB()), amounts[1]);
    }

    function testAddLiqAB_BC_CD_AndSwapAB_BC_CD() public {
        tokenA = new DummyToken("Token A", "A", 10**10 * 10**18, 18);
        tokenB = new DummyToken("Token B", "B", 10**10 * 10**18, 18);
        DummyToken tokenC = new DummyToken("Token C", "C", 10**10 * 10**18, 18);
        DummyToken tokenD = new DummyToken("Token D", "D", 10**10 * 10**18, 18);

        address[] memory path2 = new address[](4);
        path2[0] = address(tokenA);
        path2[1] = address(tokenB);
        path2[2] = address(tokenC);
        path2[3] = address(tokenD);

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        uint256 amountADesired = 2 * 10**20;
        uint256 amountBDesired = 2 * 10**20;

        tokenA.approve(address(router), 10**32);
        tokenB.approve(address(router), 10**32);
        tokenC.approve(address(router), 10**32);
        tokenD.approve(address(router), 10**32);

        router.addLiquidity(address(tokenA), address(tokenB), amountADesired, amountBDesired, amountADesired, amountBDesired);
        RarePair pairAB = RarePair(factory.pairs(address(tokenA), address(tokenB)));
        uint256 reserveAB_A = intoUint256(pairAB.reserveA());
        uint256 reserveAB_B = intoUint256(pairAB.reserveB());  

        router.addLiquidity(address(tokenB), address(tokenC), amountADesired, amountADesired, 0, 0);
        RarePair pairBC = RarePair(factory.pairs(address(tokenB), address(tokenC)));
        uint256 reserveBC_B = intoUint256(pairAB.reserveA());
        uint256 reserveBC_C = intoUint256(pairAB.reserveB());

        router.addLiquidity(address(tokenC), address(tokenD), amountADesired, amountADesired, 0, 0);
        RarePair pairCD = RarePair(factory.pairs(address(tokenC), address(tokenD)));
        uint256 reserveCD_C = intoUint256(pairAB.reserveA());
        uint256 reserveCD_D = intoUint256(pairAB.reserveB());

        // swap A for B
        uint256[] memory amounts = router.swapExactTokensForTokens(100000000, 0, path2, address(2), 0);
        assertEq(amounts[0], 100000000);
        assertEq(amounts[1], 99699999);
        assertEq(amounts[2], 99400899);
        assertEq(amounts[3], 99102696);
        assertEq(IERC20(tokenB).balanceOf(address(2)), 0);
        assertEq(IERC20(tokenD).balanceOf(address(2)), 99102696);

        // test that reserves are updating properly
        assertEq(intoUint256(pairAB.reserveA()) - reserveAB_A, amounts[0]);
        assertEq(reserveAB_B - intoUint256(pairAB.reserveB()), amounts[1]);
        assertEq(intoUint256(pairBC.reserveA()) - reserveBC_B, amounts[1]);
        assertEq(reserveBC_C - intoUint256(pairBC.reserveB()), amounts[2]);
        assertEq(intoUint256(pairCD.reserveA()) - reserveCD_C, amounts[2]);
        assertEq(reserveCD_D - intoUint256(pairCD.reserveB()), amounts[3]);
    }

        function testAddLiqABAndSwapForExactAB() public {
        tokenA = new DummyToken("Token A", "A", 10**10 * 10**18, 18);
        tokenB = new DummyToken("Token B", "B", 10**10 * 10**18, 18);

        address[] memory path1 = new address[](2);
        path1[0] = address(tokenA);
        path1[1] = address(tokenB);

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        uint256 amountADesired = 2 * 10**20;
        uint256 amountBDesired = 2 * 10**20;

        tokenA.approve(address(router), 10**32);
        tokenB.approve(address(router), 10**32);

        router.addLiquidity(address(tokenA), address(tokenB), amountADesired, amountBDesired, amountADesired, amountBDesired);
        RarePair pairAB = RarePair(factory.pairs(address(tokenA), address(tokenB)));
        uint256 reserveAB_A = intoUint256(pairAB.reserveA());
        uint256 reserveAB_B = intoUint256(pairAB.reserveB());  

        // swap A for B
        uint256[] memory amounts = router.swapTokensForExactTokens(100000, 110000, path1, address(2), 0);
        assertEq(IERC20(tokenB).balanceOf(address(2)), 100000);
        assertEq(amounts[0], 100301);
        assertEq(amounts[1], 100000);

        // test that reserves are updating properly
        assertEq(intoUint256(pairAB.reserveA()) - reserveAB_A, amounts[0]);
        assertEq(reserveAB_B - intoUint256(pairAB.reserveB()), amounts[1]);

        reserveAB_A = intoUint256(pairAB.reserveA());
        reserveAB_B = intoUint256(pairAB.reserveB());  

        amounts = router.swapTokensForExactTokens(100000000, 110000000, path1, address(2), 0);
        assertEq(IERC20(tokenB).balanceOf(address(2)), 100100000);
        assertEq(amounts[0], 100300903);
        assertEq(amounts[1], 100000000);

        // test that reserves are updating properly
        assertEq(intoUint256(pairAB.reserveA()) - reserveAB_A, amounts[0]);
        assertEq(reserveAB_B - intoUint256(pairAB.reserveB()), amounts[1]);
   }

    function testAddLiqAB_BC_CD_AndSwapForExactAB_BC_CD() public {
        tokenA = new DummyToken("Token A", "A", 10**10 * 10**18, 18);
        tokenB = new DummyToken("Token B", "B", 10**10 * 10**18, 18);
        DummyToken tokenC = new DummyToken("Token C", "C", 10**10 * 10**18, 18);
        DummyToken tokenD = new DummyToken("Token D", "D", 10**10 * 10**18, 18);

        address[] memory path2 = new address[](4);
        path2[0] = address(tokenA);
        path2[1] = address(tokenB);
        path2[2] = address(tokenC);
        path2[3] = address(tokenD);

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        uint256 amountADesired = 2 * 10**20;
        uint256 amountBDesired = 2 * 10**20;

        tokenA.approve(address(router), 10**32);
        tokenB.approve(address(router), 10**32);
        tokenC.approve(address(router), 10**32);
        tokenD.approve(address(router), 10**32);

        router.addLiquidity(address(tokenA), address(tokenB), amountADesired, amountBDesired, amountADesired, amountBDesired);
        RarePair pairAB = RarePair(factory.pairs(address(tokenA), address(tokenB)));
        uint256 reserveAB_A = intoUint256(pairAB.reserveA());
        uint256 reserveAB_B = intoUint256(pairAB.reserveB());  

        router.addLiquidity(address(tokenB), address(tokenC), amountADesired, amountADesired, 0, 0);
        RarePair pairBC = RarePair(factory.pairs(address(tokenB), address(tokenC)));
        uint256 reserveBC_B = intoUint256(pairAB.reserveA());
        uint256 reserveBC_C = intoUint256(pairAB.reserveB());

        router.addLiquidity(address(tokenC), address(tokenD), amountADesired, amountADesired, 0, 0);
        RarePair pairCD = RarePair(factory.pairs(address(tokenC), address(tokenD)));
        uint256 reserveCD_C = intoUint256(pairAB.reserveA());
        uint256 reserveCD_D = intoUint256(pairAB.reserveB());

        // swap A for B
        uint256[] memory amounts = router.swapTokensForExactTokens(10**15, 2*10**15, path2, address(2), 0);
        assertEq(amounts[0], 1_009_069_452_852_359);
        assertEq(amounts[1], 1_006_037_183_914_269);
        assertEq(amounts[2], 1_003_014_042_151_455);
        assertEq(amounts[3], 10**15);
        assertEq(IERC20(tokenB).balanceOf(address(2)), 0);
        assertEq(IERC20(tokenD).balanceOf(address(2)), 10**15);

        // test that reserves are updating properly
        assertEq(intoUint256(pairAB.reserveA()) - reserveAB_A, amounts[0]); // reserve A of AB up by amounts[1]
        assertEq(reserveAB_B - intoUint256(pairAB.reserveB()), amounts[1]); // reserve B of AB down by amounts[2]
        assertEq(intoUint256(pairBC.reserveA()) - reserveBC_B, amounts[1]); // reserve B of BC up by amounts[2]
        assertEq(reserveBC_C - intoUint256(pairBC.reserveB()), amounts[2]); // reserve C of BC down by amounts[3]
        assertEq(intoUint256(pairCD.reserveA()) - reserveCD_C, amounts[2]); // reserve C of CD up by amounts[3]
        assertEq(reserveCD_D - intoUint256(pairCD.reserveB()), amounts[3]); // reserve D of CD down by amounts[0]
    }

function testAddLiquidityAndBurn() public {
        tokenA = new DummyToken("Token A", "A", 10**8 * 10**18, 18);
        tokenB = new DummyToken("Token B", "B", 10**10 * 10**18, 18);

        RareFactory factory = router.factory();
        assertEq(factory.allPairsLength(), 0);
        assertEq(factory.pairs(address(tokenA), address(tokenB)), address(0));

        uint256 amountADesired = 10**8 * 10**18;
        uint256 amountBDesired = 10**4 * 10**18;

        tokenA.approve(address(router), 10**32);
        tokenB.approve(address(router), 10**32);

        router.addLiquidity(address(tokenA), address(tokenB),amountADesired, amountBDesired, amountADesired, amountBDesired);
        address createdPair = factory.pairs(address(tokenA), address(tokenB));
        IERC20(createdPair).approve(address(router), 10**32);
        (uint256 amountA, uint256 amountB) = router.removeLiquidity(address(tokenA), address(tokenB), IERC20(createdPair).balanceOf(address(this))/2, 0, 0, address(2), 0);
        assertEq(amountA, (10**8 * 10**18 / 2) - 50_000);
        assertEq(amountB, (10**4 * 10**18 / 2) - 5);
    }
}


