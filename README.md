# TouristIDRegistry

I built a blockchain backend for issuing digital tourist IDs. I deployed the smart contract on the Sepolia Testnet at this address:

0xE2594b45Ba9c144058aF5c197b52C699C1Bc593F

The ABI JSON file is at:

out/TouristIDRegistryV2.sol/TouristIDRegistryV2.json

This file contains all the functions of the contract. The frontend uses it to talk to the smart contract. My contract stores only hashes and IPFS CIDs, not the full data. The actual data like KYC, trip plan, and emergency contacts is stored on IPFS. Example CIDs:

KYC JSON: QmKycCID123
Trip JSON: QmTripCID456
Emergency JSON: QmEmergencyCID789

These CIDs can be used to fetch the actual JSON files from IPFS.

To fetch data from the contract and IPFS in the frontend, first install ethers.js by running:

npm install ethers

csharp
Copy code

Then use this JavaScript code to connect to the contract and get data:

```javascript
import { ethers } from "ethers";
import ABI from "./TouristIDRegistryV2.json"; // path to ABI JSON

// connect to MetaMask
const provider = new ethers.providers.Web3Provider(window.ethereum);
await provider.send("eth_requestAccounts", []); // ask user to connect wallet
const signer = provider.getSigner();

// connect to the deployed contract
const contract = new ethers.Contract(
  "0xE2594b45Ba9c144058aF5c197b52C699C1Bc593F",
  ABI.abi,
  signer
);

// replace with the tourist address you want to fetch
const touristAddress = "0x..."; 
const info = await contract.getTouristInfo(touristAddress);

console.log(info); 
// info contains: [kycHash, kycCID, tripHash, tripCID, emergencyHash, emergencyCID, validUntil, exists]

// fetch the real JSON files from IPFS using the CIDs
const kycCID = info[1];
const tripCID = info[3];
const emergencyCID = info[5];

const kycData = await fetch(`https://ipfs.io/ipfs/${kycCID}`).then(res => res.json());
const tripData = await fetch(`https://ipfs.io/ipfs/${tripCID}`).then(res => res.json());
const emergencyData = await fetch(`https://ipfs.io/ipfs/${emergencyCID}`).then(res => res.json());

console.log(kycData, tripData, emergencyData);
```
##Folder Structure
/src       → smart contract code (TouristIDRegistryV2.sol)
/script    → deployment and interaction scripts
/test      → unit tests
/offchain  → IPFS upload script (Node.js uploader)
/out       → ABI JSON files
foundry.toml
README.md  → this file

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
