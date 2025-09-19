// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract TouristIdRegistry is AccessControl, Pausable {
    error TouristIdRegistry__InvalidTourist();
    error TouristIdRegistry__ExpiryMustBeInFuture();
    error TouristIdRegistry__NoId();
    error TouristIdRegistry__ZeroHash();
    error TouristIdRegistry__NotPermitted();
    error TouristIdRegistry__Invalid();

    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    struct TouristID {
        bytes32 kycHash;
        string kycCID;
        bytes32 tripHash;
        string tripCID;
        bytes32 emergencyHash;
        string emergencyCID;
        uint256 validUntil;
        bool exists;
    }

    mapping(address => TouristID) private registry;
    mapping(address => bytes32[]) private locationLogs;

    event TouristIDIssued(address indexed tourist, uint256 validUntil, address indexed issuer);
    event TouristIDRevoked(address indexed tourist, address indexed issuer);
    event LocationLogged(address indexed tourist, bytes32 locationHash, uint256 timestamp, address indexed caller);
    event PanicRaised(address indexed tourist, bytes32 panicHash, uint256 timestamp, address indexed caller);

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function issueTouristID(
        address tourist,
        bytes32 kycHash,
        string calldata kycCID,
        bytes32 tripHash,
        string calldata tripCID,
        bytes32 emergencyHash,
        string calldata emergencyCID,
        uint256 validUntil
    ) external whenNotPaused onlyRole(ISSUER_ROLE) {
        if (tourist == address(0)) {
            revert TouristIdRegistry__InvalidTourist();
        }
        if (validUntil < block.timestamp) {
            revert TouristIdRegistry__ExpiryMustBeInFuture();
        }

        registry[tourist] = TouristID({
            kycHash: kycHash,
            kycCID: kycCID,
            tripHash: tripHash,
            tripCID: tripCID,
            emergencyHash: emergencyHash,
            emergencyCID: emergencyCID,
            validUntil: validUntil,
            exists: true
        });

        emit TouristIDIssued(tourist, validUntil, msg.sender);
    }

    function revokeTouristID(address tourist) external whenNotPaused onlyRole(ISSUER_ROLE) {
        if (!registry[tourist].exists) {
            revert TouristIdRegistry__NoId();
        }
        delete registry[tourist];
        emit TouristIDRevoked(tourist, msg.sender);
    }

    function getTouristInfo(address tourist)
        external
        view
        returns (bytes32, string memory, bytes32, string memory, bytes32, string memory, uint256, bool)
    {
        TouristID storage t = registry[tourist];
        return (t.kycHash, t.kycCID, t.tripHash, t.tripCID, t.emergencyHash, t.emergencyCID, t.validUntil, t.exists);
    }

    function isValidID(address tourist) external view returns (bool) {
        TouristID storage t = registry[tourist];
        return t.exists && block.timestamp <= t.validUntil;
    }

    function logLocation(address tourist, bytes32 locationHash) external whenNotPaused {
        if (locationHash == bytes32(0)) {
            revert TouristIdRegistry__ZeroHash();
        }
        if (msg.sender != tourist || !hasRole(ISSUER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert TouristIdRegistry__NotPermitted();
        }
        locationLogs[tourist].push(locationHash);
        emit LocationLogged(tourist, locationHash, block.timestamp, msg.sender);
    }

    function raisePanic(address tourist, bytes32 panicHash) external whenNotPaused {
        if (panicHash == bytes32(0)) {
            revert TouristIdRegistry__ZeroHash();
        }
        if (msg.sender != tourist || !hasRole(ISSUER_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert TouristIdRegistry__NotPermitted();
        }
        emit PanicRaised(tourist, panicHash, block.timestamp, msg.sender);
    }

    function locationCount(address tourist) external view returns (uint256) {
        return locationLogs[tourist].length;
    }

    function getLocationAt(address tourist, uint256 index) external view returns (bytes32) {
        if (index > locationLogs[tourist].length) {
            revert TouristIdRegistry__Invalid();
        }
        require(index < locationLogs[tourist].length, "index OOB");
        return locationLogs[tourist][index];
    }
}
