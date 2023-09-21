// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "../src/FixedPoint.sol";
import "forge-std/console.sol";

contract FixedPointTest is Test {
    Decimal18ERC20 public dec18;
    Decimal32ERC20 public dec32;

    // supply of 18, decimals 18.
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000_000_000_000_000_000_000_000_000_000;

    function setUp() public {
        dec18 = new Decimal18ERC20('dec18', '18dec', TOTAL_SUPPLY);
        dec32 = new Decimal32ERC20('dec32', '32dec', TOTAL_SUPPLY);
    }

    function test_hanldeERC20Supply() public {
        int128 supply18 = ABDKMath64x64.fromUInt(dec18.totalSupply()/(10 ** dec18.decimals()));
        int128 supply32 = ABDKMath64x64.fromUInt(dec32.totalSupply()/(10 ** dec32.decimals()));
        console.logInt(supply18);
        console.logInt(supply32);
        
        uint256 supply18ToFrontEnd = ABDKMath64x64.toUInt(supply18);
        uint256 supply32ToFrontEnd = ABDKMath64x64.toUInt(supply32);
        console.log(supply18ToFrontEnd);
        console.log(supply32ToFrontEnd);
    }

    function test_handleERC20Balances() public {
        dec18.transfer(address(10), 125_000_000_000_000_000);
        dec32.transfer(address(10), 125_000_000_000_000_000);

        
    }

    function test_displayFP() public {
        int128 one = ABDKMath64x64.fromUInt(1);
        int128 two = ABDKMath64x64.fromUInt(2);
        console.log(ABDKMath64x64.toUInt(one));
        console.log(ABDKMath64x64.toUInt(two));

        int128 halfFromI = ABDKMath64x64.div(one, two);
        int128 halfFromU = ABDKMath64x64.divu(1, 2);
        assertEq(halfFromI, halfFromU);
    }
}
