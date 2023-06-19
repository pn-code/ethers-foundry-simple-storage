// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "@forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // Initiate var
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    // Provide value to var
    function setUp() external {
        DeployFundMe deployedFundMe = new DeployFundMe();
        fundMe = deployedFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    // Check minimum USD
    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // Checks to see if sender is the owner
    function testOwnerIsSender() public {
        // Because we asked FundMeTest to deploy FundMe contract, FundMe is the owner
        // So address(this) should be the owner's address
        // But if tested with vm.startBroadcast deploy script, then owner is msg.sender
        assertEq(fundMe.i_owner(), msg.sender);
    }

    // Checks price feed version
    function testPriceFeedVersionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }

    // Checks to see if fund fails/reverts if not enough ETH
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // next line should revert
        fundMe.fund();
    }

    // Fund should work when funded
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    // Fund function should add funder to arrays of funders
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(USER, funder);
    }
}
