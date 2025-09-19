// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/TouristIdRegistry.sol";

contract DeployTouristIDRegistryV2 is Script {
    function run() external {
        vm.startBroadcast();

        // deploy contract with msg.sender as admin
        TouristIdRegistry registry = new TouristIdRegistry(msg.sender);

        console.log("TouristIDRegistryV2 deployed at:", address(registry));

        vm.stopBroadcast();
    }
}
