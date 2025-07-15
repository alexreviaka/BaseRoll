# Smart Contracts

Solidity smart contracts for BaseRoll payroll system.

## Contracts

- **PayrollFactory.sol** - Factory for creating payroll contracts
- **Payroll.sol** - Main payroll logic
- **EmployeeRegistry.sol** - Employee management
- **PaymentScheduler.sol** - Scheduling and automation

## Development

```bash
npm install
npx hardhat compile
npx hardhat test
```

## Deployment

```bash
# Base Sepolia
npx hardhat run scripts/deploy.js --network baseSepolia

# Base Mainnet
npx hardhat run scripts/deploy.js --network baseMainnet
```