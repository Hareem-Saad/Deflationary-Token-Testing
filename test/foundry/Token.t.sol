// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../contracts/Token.sol";

contract TokenTest is Test {
    
    Deflationary public token;
    address owner = address(1);
    address user1 = address(2);
    address user2 = address(3);
    address zero = address(0x0);

    function setUp() public {
        vm.deal(user1, 20 ether);
        vm.deal(user2, 20 ether);
        vm.prank(owner);
        token = new Deflationary("Puppy", "PUP", 1, 1000000);
    }

    //tests for burning in transfer functions
    //checks for changes in user accounts aand total supply
    function testTransfer() public {
        vm.prank(owner);
        token.transfer(user1, 100);

        assertEq(token.balanceOf(user1), 99);
    }

    function testTransferFuzz(uint amount) public {
        vm.assume(amount < 1000000 * 10 * 18);

        uint totalSupplyBefore = token.totalSupply();

        vm.prank(owner);
        token.transfer(user1, amount);

        assertEq(token.balanceOf(user1), amount - token.calculateBurnRate(amount));

        uint totalSupplyAfter = token.totalSupply();
        assertEq(totalSupplyBefore - token.calculateBurnRate(amount), totalSupplyAfter);
    }

    function testSpendAllowance() public {
        vm.prank(owner);
        token.approve(user1, 10000);

        vm.prank(user1);
        token.transferFrom(owner, user2, 100);

        assertEq(token.balanceOf(user2), 100 - token.calculateBurnRate(100));
    }

    function testSpendAllowance(uint amount) public {
        vm.assume(amount <= 10000);

        vm.prank(owner);
        token.approve(user1, 10000);

        vm.prank(user1);
        token.transferFrom(owner, user2, amount);

        assertEq(token.balanceOf(user2), amount - token.calculateBurnRate(amount));
    }

    function testCannotSpendAllowance(uint amount) public {
        vm.assume(amount > 0 && amount <= 10000);

        vm.prank(user1);
        vm.expectRevert(bytes("ERC20: insufficient allowance"));
        token.transferFrom(owner, user2, amount);

        assertEq(token.balanceOf(user2), 0);
    }

    function testNoBurning(uint amount) public {
        vm.assume(amount > 0 && amount <= 10000);

        uint totalSupplyBefore = token.totalSupply();

        vm.prank(owner);
        token.approve(user1, 10000);

        uint totalSupplyAfter = token.totalSupply();
        assertEq(totalSupplyBefore, totalSupplyAfter);
    }
}
