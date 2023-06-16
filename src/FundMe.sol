// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { PriceConverter } from "./PriceConverter.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Advanced Solidity Tips
// 1. If you assign a var once and it never changes, use constant
// constants should be full caps with underscore for spaces
// 2. A var set once outside of their declaration should use immutable
// An immutable var should be named with i_ preceding it
// 3. Write error & use if statement instead of require()
// 4. When naming errors, put contract name followed by double underscore then error name

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    
    // Array of funders
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    // Address of contract's owner
    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;

    // Function that is immediately called when contract is deployed
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {     
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Didn't send enough ETH.");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    // For Loop Implementation
    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        } 

        // Reset the array
        funders = new address[](0);

        // Withdraw the funds (call is the best practice way of sending eth)
        // msg.sender = type address
        // payable(msg.sender) = type payable address

        // transfer vs. send vs. call

        // payable(msg.sender).transfer(address(this).balance);

        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed.");

        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed.");
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Must be owner!");
        if (msg.sender == i_owner) {
            revert FundMe__NotOwner();
        }
        // _; is a placeholder for the code; it can be placed before or after
        _;
    }

    // What happens if people send ETH without the fund function?

    // receive()
    receive() external payable {
        fund();
    }

    // fallback()
    fallback() external payable {
        fund();
    }
}