import { ethers } from "ethers";
import TouristIDRegistryV2 from "../out/TouristIDRegistryV2.sol/TouristIDRegistryV2.json";

// Replace this with your deployed contract address
const CONTRACT_ADDRESS = "0xYourDeployedContractAddress";

async function getContract() {
  if (!window.ethereum) throw new Error("MetaMask not found");

  const provider = new ethers.BrowserProvider(window.ethereum);
  const signer = await provider.getSigner();

  return new ethers.Contract(CONTRACT_ADDRESS, TouristIDRegistryV2.abi, signer);
}

/* ========== CORE FUNCTIONS ========== */

export async function issueTouristID(
  tourist,
  kycHash, kycCID,
  tripHash, tripCID,
  emergencyHash, emergencyCID,
  validUntil
) {
  const contract = await getContract();
  const tx = await contract.issueTouristID(
    tourist,
    kycHash, kycCID,
    tripHash, tripCID,
    emergencyHash, emergencyCID,
    validUntil
  );
  await tx.wait();
  return tx.hash;
}

export async function revokeTouristID(tourist) {
  const contract = await getContract();
  const tx = await contract.revokeTouristID(tourist);
  await tx.wait();
  return tx.hash;
}

export async function getTouristInfo(tourist) {
  const contract = await getContract();
  const info = await contract.getTouristInfo(tourist);
  return {
    kycHash: info[0],
    kycCID: info[1],
    tripHash: info[2],
    tripCID: info[3],
    emergencyHash: info[4],
    emergencyCID: info[5],
    validUntil: Number(info[6]),
    exists: info[7],
  };
}

export async function isValidID(tourist) {
  const contract = await getContract();
  return await contract.isValidID(tourist);
}

/* ========== LOCATION & PANIC ========== */

export async function logLocation(tourist, locationHash) {
  const contract = await getContract();
  const tx = await contract.logLocation(tourist, locationHash);
  await tx.wait();
  return tx.hash;
}

export async function raisePanic(tourist, panicHash) {
  const contract = await getContract();
  const tx = await contract.raisePanic(tourist, panicHash);
  await tx.wait();
  return tx.hash;
}

export async function getLocationAt(tourist, index) {
  const contract = await getContract();
  return await contract.getLocationAt(tourist, index);
}

export async function locationCount(tourist) {
  const contract = await getContract();
  return Number(await contract.locationCount(tourist));
}
