# BaseRoll

**On-chain payroll management protocol for Base**

BaseRoll is a decentralized, upgradeable payroll protocol built on Base blockchain. It enables organizations to manage employee records, track salaries, and execute automated USDC payments on-chain with full transparency and auditability.

## What is BaseRoll?

BaseRoll provides companies and DAOs with a trustless, blockchain-native solution for payroll management. Instead of relying on traditional payroll providers, organizations can:

- Register their company on Base with full ownership
- Onboard employees with wallet addresses and salary definitions
- Track employment records immutably on-chain
- Automate recurring payments using smart contracts
- Maintain complete transparency and audit trails

All data lives on Base blockchain, making it censorship-resistant, globally accessible, and verifiable by anyone.

## Key Features

- **Organization Management** - Register and manage your company on-chain with role-based access control
- **Employee Registry** - Onboard employees with wallet addresses, base salary, and employment metadata
- **Immutable Records** - All employee data and salary changes recorded permanently on Base
- **Upgradeable Architecture** - UUPS proxy pattern allows protocol improvements without disruption
- **Gas Optimized** - Custom errors and efficient storage patterns minimize transaction costs
- **Event-Driven** - Rich event emissions for off-chain indexing and analytics

## Use Cases

### For Startups & Small Businesses
Run payroll fully on-chain without intermediaries. Pay employees in USDC on Base with low fees and instant settlement.

### For DAOs & Protocol Teams
Manage contributor compensation transparently. Every payment is publicly verifiable and immutably recorded.

### For Global Teams
Eliminate currency conversion and bank delays. Pay international employees directly to their wallets, anywhere in the world.

### For Crypto-Native Companies
Build payroll into your existing Base infrastructure. No need for traditional banking rails or payroll providers.

## How It Works

### 1. Register Your Organization
Connect your wallet and register your company on Base. The smart contract assigns you as the organization owner with full admin rights.

### 2. Add Employees
Onboard team members by entering their Base wallet addresses and annual salaries. Each employee gets a unique on-chain record.

### 3. Manage Payroll
View all employees, update salaries, or deactivate former team members. All changes are tracked on-chain with event logs.

### 4. Execute Payments
When it's time to pay, the protocol calculates amounts and prepares transactions. Payments execute directly from your organization's wallet to employee wallets.

## Smart Contracts

**BaseRoll V1** is deployed on:
- **Base Mainnet**: Coming soon
- **Base Sepolia**: Coming soon

Contract architecture:
- **UUPS Proxy Pattern** - Upgradeable without changing addresses
- **Access Control** - Role-based permissions (ADMIN_ROLE, ORG_OWNER_ROLE)
- **Storage Gaps** - 50-slot gap reserved for future upgrades
- **Gas Optimized** - Custom errors instead of string reverts

## Protocol Status

BaseRoll V1 implements core organization and employee management functionality. Future versions will add:
- Payroll run scheduling and batch processing
- Base Pay integration for USDC payments
- Bonus and adjustment system
- Multi-token support
- Analytics and reporting

## Security

BaseRoll uses OpenZeppelin's audited upgradeable contracts and follows Solidity best practices. All code is open source and verifiable on Basescan.

For security concerns, please open an issue on GitHub.

## License

MIT © 2025 BaseRoll

---

Built on Base 🔵
