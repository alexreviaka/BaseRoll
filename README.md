# BaseRoll

Decentralized payroll system built on Base blockchain.

## Overview

BaseRoll enables companies to automate salary payments to employees using blockchain technology. Built on Base for low-cost, fast transactions.

## Features

- Company registration and management
- Employee onboarding with wallet addresses
- Automated recurring payments
- Multi-token support (ETH, USDC, custom ERC-20)
- Payment history and analytics
- Base Pay integration
- Upgradeable contracts via proxy pattern

## Smart Contracts

- **Payroll.sol** - Main payroll logic with employee management
- **EmployeeRegistry.sol** - Employee information and metadata
- **PaymentScheduler.sol** - Automated payment scheduling
- **PayrollFactory.sol** - Factory for creating payroll instances
- **IBasePay.sol** - Interface for Base Pay integration

## Tech Stack

- **Smart Contracts**: Solidity 0.8.20, Hardhat, OpenZeppelin
- **Backend**: FastAPI, Web3.py
- **Frontend**: React, ethers.js
- **Database**: MongoDB
- **Blockchain**: Base (Sepolia & Mainnet)

## Installation

```bash
# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test
```

## Deployment

```bash
# Base Sepolia
npx hardhat run scripts/deploy.js --network baseSepolia

# Base Mainnet
npx hardhat run scripts/deploy.js --network baseMainnet
```

## License

MIT
