// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "@forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // Initiate var
    FundMe fundMe;

    // Provide value to var
    function setUp() external {
        DeployFundMe deployedFundMe = new DeployFundMe();
        fundMe = deployedFundMe.run();
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
}