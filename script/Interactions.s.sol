// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/TouristIdRegistry.sol";

contract InteractTouristIDRegistryV2 is Script {
    // replace with deployed address
    address constant CONTRACT_ADDRESS = 0x0000000000000000000000000000000000000000;

    function run() external {
        vm.startBroadcast();

        TouristIdRegistry registry = TouristIdRegistry(CONTRACT_ADDRESS);

        // Example: assign ISSUER_ROLE to your wallet
        bytes32 ISSUER_ROLE = keccak256("ISSUER_ROLE");
        registry.grantRole(ISSUER_ROLE, msg.sender);

        // Example: issue a tourist ID
        registry.issueTouristID(
            0x1111111111111111111111111111111111111111, // tourist address
            keccak256(abi.encodePacked("kyc-data")),
            "QmKycCid123",
            keccak256(abi.encodePacked("trip-data")),
            "QmTripCid123",
            keccak256(abi.encodePacked("emergency-data")),
            "QmEmergencyCid123",
            block.timestamp + 7 days
        );

        console.log("Issued tourist ID");

        vm.stopBroadcast();
    }
}
