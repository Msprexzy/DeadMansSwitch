// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeadMansSwitch} from "../src/DeadMansSwitch.sol";

contract DeadMansSwitchTest is Test {
    DeadMansSwitch dms;
    address owner = address(1);
    address payable beneficiary = payable(address(2));

    function setUp() public {
        vm.prank(owner);
        dms = new DeadMansSwitch(beneficiary);
    }

    function test_OwnerCanCheckIn() public {
        vm.prank(owner);
        dms.checkIn();
        assertEq(dms.lastCheckIn(), block.timestamp);
    }

    function test_OwnerCanDeposit() public {
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        dms.deposit{value: 1 ether}();
        assertEq(dms.getBalance(), 1 ether);
    }

    function test_WithdrawFailsIfOwnerActive() public {
        vm.prank(beneficiary);
        vm.expectRevert(DeadMansSwitch.OwnerStillActive.selector);
        dms.withdraw();
    }

    function test_WithdrawSucceedsAfterPeriod() public {
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        dms.deposit{value: 1 ether}();
        vm.warp(block.timestamp + 8 days);
        vm.prank(beneficiary);
        dms.withdraw();
        assertEq(beneficiary.balance, 1 ether);
    }

    function test_StrangerCannotCheckIn() public {
        vm.prank(address(3));
        vm.expectRevert(DeadMansSwitch.NotOwner.selector);
        dms.checkIn();
    }
}
