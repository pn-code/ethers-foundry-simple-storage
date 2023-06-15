// The .s.sol is a foundry convention
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Here is the convention for deploying contracts using foundry

import {Script} from "../lib/forge-std/src/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        vm.startBroadcast();
        SimpleStorage simpleStorage = new SimpleStorage();
        vm.stopBroadcast();
        return simpleStorage;
    }
}