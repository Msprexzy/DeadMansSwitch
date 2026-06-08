# Dead Man's Switch

A Solidity smart contract that automatically transfers ETH to a 
beneficiary if the owner stops checking in.

## How It Works
1. Owner deploys contract with a beneficiary address
2. Owner deposits ETH into the contract
3. Owner calls checkIn() regularly to reset the 7-day timer
4. If owner stops checking in for 7 days, beneficiary can call withdraw()
5. All ETH is transferred to the beneficiary automatically

## Contract Functions
- deposit() - Owner deposits ETH
- checkIn() - Owner resets the timer
- withdraw() - Beneficiary claims ETH after timeout
- getBalance() - Check contract balance
- timeRemaining() - Check time left before trigger

## Deployment
- Network: Sepolia Testnet
- Contract Address: 0xB81C2B778b1A5b673F0AB5cf1b10fC6d44Eb9ad0
- Etherscan: https://sepolia.etherscan.io/address/0xb81c2b778b1a5b673f0ab5cf1b10fc6d44eb9ad0

## Built With
- Solidity ^0.8.20
- Foundry
- Sepolia Testnet
