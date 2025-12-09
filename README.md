# BaseRoll

**On-chain payroll management protocol for Base**

BaseRoll is a decentralized, upgradeable payroll protocol built on Base blockchain. It enables organizations to manage employees, compensation profiles, payroll cycles, and execute automated payments on-chain with full transparency and auditability.

## What is BaseRoll?

BaseRoll provides companies and DAOs with a trustless, blockchain-native solution for payroll management. Instead of relying on traditional payroll providers, organizations can:

- Register their company on Base with full ownership
- Onboard employees with multiple payout addresses and percentage splits
- Define time-bound compensation profiles with base salary, bonuses, and token allocations
- Create and execute payroll cycles (weekly, biweekly, monthly)
- Track all employment and payment records immutably on-chain
- Maintain complete transparency and audit trails

All data lives on Base blockchain, making it censorship-resistant, globally accessible, and verifiable by anyone.

## Key Features

### BaseRoll V2 (Current)
- **Enhanced Employee Management** - Multiple payout addresses per employee with percentage-based splits (basis points)
- **Compensation Profiles** - Time-bound compensation with effective dates, supporting base salary, bonuses, and token allocations
- **Payroll Cycles** - Full cycle management (PENDING → EXECUTED → FINALIZED) with support for weekly, biweekly, and monthly periods
- **Mid-Cycle Changes** - Handle employee status changes and salary updates mid-cycle with automatic compensation calculation
- **Organization Management** - Register and manage your company on-chain with role-based access control
- **Immutable Records** - All employee data and compensation changes recorded permanently on Base
- **Upgradeable Architecture** - UUPS proxy pattern allows protocol improvements without disruption
- **Gas Optimized** - Custom errors and efficient storage patterns minimize transaction costs
- **Event-Driven** - Rich event emissions for off-chain indexing and analytics

## Use Cases

### For Startups & Small Businesses
Run payroll fully on-chain without intermediaries. Pay employees in multiple tokens with flexible payout address splits.

### For DAOs & Protocol Teams
Manage contributor compensation transparently. Support for bonus payments, token allocations, and multiple payment destinations.

### For Global Teams
Eliminate currency conversion and bank delays. Pay international employees directly to multiple wallets, anywhere in the world.

### For Crypto-Native Companies
Build payroll into your existing Base infrastructure with support for mid-cycle adjustments and time-bound compensation changes.

## How It Works

### 1. Register Your Organization
Connect your wallet and register your company on Base. The smart contract assigns you as the organization owner with full admin rights.

### 2. Add Employees
Onboard team members with their wallet addresses, optional multiple payout addresses with percentage splits, and employment metadata.

### 3. Create Compensation Profiles
Define time-bound compensation profiles for each employee with base salary, bonuses, and token allocations. Profiles automatically handle transitions.

### 4. Create Payroll Cycles
Set up payroll cycles (weekly, biweekly, monthly) for your organization. The protocol tracks cycle status through PENDING → EXECUTED → FINALIZED states.

### 5. Execute Payments
When it's time to pay, the protocol calculates amounts based on active compensation profiles and executes payments to employee payout addresses with configured splits.

## Smart Contracts

**BaseRoll V2** is deployed on:
- **Base Mainnet**: [`0xE71322835734aeC852C91093AfF3A13219D84514`](https://basescan.org/address/0xE71322835734aeC852C91093AfF3A13219D84514) (Proxy)
- **Base Sepolia**: [`0x04C9C05e377f56e0ff85f5A1500f5948FC70f0Db`](https://sepolia.basescan.org/address/0x04C9C05e377f56e0ff85f5A1500f5948FC70f0Db) (Proxy)

Contract architecture:
- **UUPS Proxy Pattern** - Upgradeable without changing addresses
- **Access Control** - Role-based permissions (ADMIN_ROLE, ORG_OWNER_ROLE)
- **Storage Gaps** - Reserved slots for future upgrades
- **Gas Optimized** - Custom errors, unchecked increments, SafeERC20
- **ReentrancyGuard** - Protection against reentrancy attacks on payment functions

## Development

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation
```bash
git clone https://github.com/alexreviaka/BaseRoll.git
cd BaseRoll
forge install
```

### Testing
```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test
forge test --match-test testCreateEmployee
```

### Building
```bash
forge build --sizes
```

### Deployment
See [deployment scripts](./script/) for V1 and V2 deployment options.

## Protocol Status

BaseRoll V2 implements:
- ✅ Enhanced employee data model with multiple payout addresses
- ✅ Time-bound compensation profiles
- ✅ Full payroll cycle management
- ✅ Mid-cycle change handling
- ✅ Comprehensive test coverage (34 tests)

Future enhancements:
- Base Pay integration for automated USDC payments
- Ethereum Attestation Service (EAS) integration
- Subgraph for off-chain indexing
- Advanced reporting and analytics

See [PAYROLL_MODEL.md](./docs/PAYROLL_MODEL.md) for detailed specification.

## Security

BaseRoll uses OpenZeppelin's audited upgradeable contracts (v4.9.6) and follows Solidity best practices:
- ReentrancyGuard on payment functions
- SafeERC20 for token transfers
- Custom errors for gas efficiency
- Comprehensive event logging
- Role-based access control

All code is open source and verified on Basescan.

For security concerns, please open an issue on GitHub.

## License

MIT © 2025 BaseRoll

---

Built on Base 🔵
