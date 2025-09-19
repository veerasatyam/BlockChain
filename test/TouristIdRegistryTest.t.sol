// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {TouristIdRegistry} from "../src/TouristIdRegistry.sol";

contract TouristIDRegistryV2Test is Test {
    TouristIdRegistry registry;

    address admin = address(1);
    address issuer = address(2);
    address tourist1 = address(3);
    address tourist2 = address(4);

    bytes32 ISSUER_ROLE;

    function setUp() public {
        vm.startPrank(admin);
        registry = new TouristIdRegistry(admin);

        ISSUER_ROLE = keccak256("ISSUER_ROLE");
        registry.grantRole(ISSUER_ROLE, issuer);
        vm.stopPrank();
    }

    function testIssueTouristID() public {
        vm.prank(issuer);

        registry.issueTouristID(
            tourist1,
            keccak256("kyc1"),
            "QmKycCID1",
            keccak256("trip1"),
            "QmTripCID1",
            keccak256("emergency1"),
            "QmEmergencyCID1",
            block.timestamp + 1 days
        );

        (, string memory kycCID,, string memory tripCID,, string memory emergencyCID, uint256 validUntil, bool exists) =
            registry.getTouristInfo(tourist1);

        assertTrue(exists);
        assertEq(kycCID, "QmKycCID1");
        assertEq(tripCID, "QmTripCID1");
        assertEq(emergencyCID, "QmEmergencyCID1");
        assertGt(validUntil, block.timestamp);
        assertTrue(registry.isValidID(tourist1));
    }

    function testRevokeTouristID() public {
        vm.startPrank(issuer);

        registry.issueTouristID(
            tourist1,
            keccak256("kyc1"),
            "QmKycCID1",
            keccak256("trip1"),
            "QmTripCID1",
            keccak256("emergency1"),
            "QmEmergencyCID1",
            block.timestamp + 1 days
        );

        registry.revokeTouristID(tourist1);
        vm.stopPrank();

        (,,,,,,, bool exists) = registry.getTouristInfo(tourist1);
        assertFalse(exists);
        assertFalse(registry.isValidID(tourist1));
    }

    function testOnlyIssuerCanIssue() public {
        vm.prank(tourist1);
        vm.expectRevert();
        registry.issueTouristID(
            tourist2,
            keccak256("kyc2"),
            "QmKycCID2",
            keccak256("trip2"),
            "QmTripCID2",
            keccak256("emergency2"),
            "QmEmergencyCID2",
            block.timestamp + 1 days
        );
    }

    function testLogLocation() public {
        vm.prank(issuer);
        registry.issueTouristID(
            tourist1,
            keccak256("kyc1"),
            "QmKycCID1",
            keccak256("trip1"),
            "QmTripCID1",
            keccak256("emergency1"),
            "QmEmergencyCID1",
            block.timestamp + 1 days
        );

        vm.prank(tourist1);
        registry.logLocation(tourist1, keccak256("location1"));
        vm.prank(issuer);
        registry.logLocation(tourist1, keccak256("location2"));

        assertEq(registry.locationCount(tourist1), 2);
        assertEq(registry.getLocationAt(tourist1, 0), keccak256("location1"));
        assertEq(registry.getLocationAt(tourist1, 1), keccak256("location2"));
    }

    function testLogLocationZeroHashFails() public {
        vm.prank(tourist1);
        vm.expectRevert("zero hash");
        registry.logLocation(tourist1, bytes32(0));
    }

    function testRaisePanic() public {
        vm.prank(tourist1);
        registry.raisePanic(tourist1, keccak256("panic1"));
        // just ensure no revert; event emitted automatically
    }

    function testRaisePanicZeroHashFails() public {
        vm.prank(tourist1);
        vm.expectRevert("zero hash");
        registry.raisePanic(tourist1, bytes32(0));
    }

    function testIDExpires() public {
        vm.prank(issuer);
        registry.issueTouristID(
            tourist1,
            keccak256("kyc1"),
            "QmKycCID1",
            keccak256("trip1"),
            "QmTripCID1",
            keccak256("emergency1"),
            "QmEmergencyCID1",
            block.timestamp + 1
        );

        vm.warp(block.timestamp + 2);
        assertFalse(registry.isValidID(tourist1));
    }
}
