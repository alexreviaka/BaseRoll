# BaseRoll Payroll Data Model

## Overview

BaseRoll V2 implements a production-ready, flexible payroll system for Base L2 that supports complex compensation structures, multiple payout destinations, and dynamic employee management across payroll cycles.

## Core Data Structures

### 1. Organization

Organizations are the top-level entities that manage payroll operations.

```solidity
struct Organization {
    uint256 id;
    address owner;
    string name;
    string metadata;         // JSON metadata for additional org info
    uint256 createdAt;
    bool active;
}
```

**Key Features:**
- One organization per owner address
- Owner receives `ORG_OWNER_ROLE` for authorization
- Metadata field supports extensible org configuration

### 2. Employee

Employees represent team members or contractors eligible for payroll.

```solidity
struct Employee {
    uint256 id;
    uint256 orgId;
    address primaryWallet;
    address[] payoutAddresses;
    uint256[] payoutPercentages;  // Basis points (10000 = 100%)
    EmployeeMetadata metadata;
    EmployeeStatus status;
    uint256 addedAt;
    uint256 updatedAt;
}

enum EmployeeStatus {
    ACTIVE,      // Eligible for payroll
    INACTIVE,    // Temporarily suspended
    TERMINATED   // Permanently removed
}
```

**Key Features:**
- **Multiple payout addresses**: Split compensation across wallets (e.g., 70% primary, 30% savings)
- **Flexible metadata**: Role, department, jurisdiction codes for compliance
- **Status lifecycle**: Active → Inactive → Terminated (or reactivated)
- **Primary wallet**: Default address when no split payout configured

**Employee Metadata:**
```solidity
struct EmployeeMetadata {
    string role;                 // "Engineer", "Designer", etc.
    string department;           // "Engineering", "Marketing"
    string jurisdictionCode;     // "US", "EU", for future compliance hooks
    string customData;           // JSON for extensible data
}
```

### 3. Compensation Profile

Compensation profiles define how much employees are paid per cycle, with support for base, bonus, and token components.

```solidity
struct CompensationProfile {
    uint256 id;
    uint256 employeeId;
    CompensationComponent compensation;
    uint256 effectiveFrom;
    uint256 effectiveUntil;      // 0 = active indefinitely
    bool active;
    uint256 createdAt;
}

struct CompensationComponent {
    uint256 baseAmount;          // Base salary per cycle
    uint256 bonusAmount;         // Bonus/commission per cycle
    address tokenAddress;        // For future token payments
    uint256 tokenAmount;         // Amount of tokens
    uint256 vestingDuration;     // For future vesting support
    uint256 vestingCliff;        // Cliff period for vesting
}
```

**Key Features:**
- **Time-bound profiles**: Each profile has effective dates
- **Historical tracking**: Old profiles preserved with `effectiveUntil` set
- **Salary changes**: Creating new profile auto-terminates active profile
- **Flexible compensation**: Base + bonus + optional token components

**Lifecycle:**
1. Create compensation profile with `effectiveFrom` timestamp
2. Profile remains active until new profile created
3. New profile sets `effectiveUntil` on old profile
4. Cycle creation snapshots active compensation at cycle start time

### 4. Payroll Cycle

Payroll cycles represent discrete payroll periods (weekly, biweekly, monthly).

```solidity
struct PayrollCycle {
    uint256 id;
    uint256 orgId;
    PayrollPeriod period;
    uint256 startTime;
    uint256 endTime;
    CycleStatus status;
    uint256 totalAmount;
    uint256 executedAt;
    uint256 finalizedAt;
    address paymentToken;        // ERC20 token for payments
}

enum PayrollPeriod {
    WEEKLY,
    BIWEEKLY,
    MONTHLY
}

enum CycleStatus {
    PENDING,     // Created, not yet executed
    EXECUTED,    // Payments processed
    FINALIZED    // Cycle closed, no further changes
}
```

**Cycle Employees:**
```solidity
struct PayrollCycleEmployee {
    uint256 employeeId;
    uint256 baseAmount;
    uint256 bonusAmount;
    uint256 totalAmount;
    bool paid;
}
```

**Key Features:**
- **Snapshot at creation**: Cycle captures current active employees and compensation
- **Immutable composition**: Employee list fixed at cycle creation
- **Status progression**: PENDING → EXECUTED → FINALIZED
- **Flexible payment tokens**: Any ERC20 (USDC, USDT, etc.)

## State Transitions and Business Rules

### Employee Lifecycle

```
          register
            ↓
          ACTIVE
            ↓
   ┌────────┼────────┐
   ↓        ↓        ↓
INACTIVE  ACTIVE  TERMINATED
   ↓
ACTIVE (reactivate)
```

**Rules:**
- Only ACTIVE employees included in new cycles
- Changing status mid-cycle doesn't affect existing cycles
- Employees can be reactivated from INACTIVE
- TERMINATED is typically permanent (but can be changed by org owner)

### Compensation Profile Lifecycle

```
Profile A (active)
     ↓
Create Profile B with effectiveFrom = T
     ↓
Profile A: effectiveUntil = T, active = false
Profile B: effectiveFrom = T, active = true
```

**Rules:**
- Only one active profile per employee at any time
- Creating new profile auto-terminates previous active profile
- Historical profiles preserved for audit trail
- Cycles snapshot compensation at cycle start time

### Payroll Cycle Lifecycle

```
createPayrollCycle()
     ↓
  PENDING
     ↓
executePayrollCycle()
     ↓
  EXECUTED
     ↓
finalizePayrollCycle()
     ↓
  FINALIZED
```

**Rules:**
- Cycle creation snapshots current active employees and their compensation
- Only employees with active compensation profiles included
- Execution transfers funds to employee wallets (or split across payout addresses)
- Finalization marks cycle complete, enables analytics/reporting
- Cannot execute already-executed cycles
- Cannot finalize non-executed cycles

## Dynamic Scenario Handling

### Mid-Cycle Employee Changes

**Scenario:** Employee added or deactivated between cycle creation and execution

**Behavior:**
- Cycle composition fixed at creation time
- New employees only appear in next cycle
- Deactivated employees still paid in current cycle
- This ensures predictable payroll amounts

**Example:**
```
Day 1: Create cycle for Month 1 (includes Alice, Bob)
Day 5: Add Charlie as employee
Day 10: Deactivate Alice
Day 30: Execute cycle → Only Alice and Bob paid (Charlie not included)
Day 31: Create cycle for Month 2 (includes Bob, Charlie)
```

### Salary Updates Between Cycles

**Scenario:** Employee receives raise effective next cycle

**Behavior:**
- Create new compensation profile with `effectiveFrom` = next cycle start
- Current cycle uses old compensation
- Next cycle uses new compensation

**Example:**
```solidity
// Alice currently earns 5000 per month
createCompensationProfile(aliceId, {baseAmount: 5000}, currentTime);

// Raise effective next month
createCompensationProfile(aliceId, {baseAmount: 6000}, nextMonthStart);

// Current month cycle: Alice gets 5000
// Next month cycle: Alice gets 6000
```

### Handling Inactive Employees

**Scenario:** Employee on leave or temporarily suspended

**Behavior:**
- Set employee status to INACTIVE
- Employee excluded from new cycle creation
- Can reactivate later, will be included in subsequent cycles

**Example:**
```solidity
// Alice goes on leave
setEmployeeStatus(aliceId, EmployeeStatus.INACTIVE);

// Create cycle → Alice not included

// Alice returns
setEmployeeStatus(aliceId, EmployeeStatus.ACTIVE);

// Next cycle → Alice included again
```

### Multiple Compensation Updates

**Scenario:** Multiple salary changes over time

**Behavior:**
- Each profile maintains historical record
- `getActiveCompensation(employeeId, timestamp)` retrieves correct profile
- Enables retroactive analysis and auditing

## Integration Points

### Current Features

- **ERC20 Payments**: Supports any ERC20 token (USDC, USDT, DAI)
- **Multi-address Payouts**: Split compensation across addresses with percentage allocations
- **Role-based Access**: Org owners control their org, admins manage protocol

### Future Integration Hooks

#### Base Pay Integration
```solidity
// Future: Base Pay API for treasury top-ups
IBasePay.initiatePayment(recipient, amount, token, metadata);
```

#### Payment Buckets
Structured to support bucketed allocations:
- Net pay (primary)
- Tax withholding (treasury/escrow)
- Benefits (insurance, retirement)
- Expense reimbursements

Implementation approach:
- Add `PaymentBucket` struct and bucket allocations to `CompensationProfile`
- Modify `executePayrollCycle` to distribute to buckets
- Maintain separate bucket balance tracking

#### Attestations (EAS)
Employee metadata designed to reference attestations:
- Compliance certifications
- Employment verification
- KYC/AML status

#### Subgraph/Indexer
Rich event emissions enable:
- Historical payroll analytics
- Compensation trending
- Cycle execution monitoring
- Employee lifecycle tracking

## Gas Optimization Patterns

- **Custom errors** instead of require strings
- **Unchecked increments** for ID counters
- **Storage gaps** for upgrade-safe storage layout
- **Batch operations** via cycle execution (single tx for all employees)

## Security Considerations

- **Reentrancy protection** on payment execution
- **Access control** via OpenZeppelin AccessControl
- **UUPS upgrade pattern** for controlled upgrades
- **Balance checks** before cycle execution
- **SafeERC20** for token transfers

## Upgrade Safety

V2 maintains upgrade compatibility:
- Storage gaps (`uint256[50] private __gap;`)
- New storage appended only (no reordering)
- Initializer pattern for proxy deployments

## Usage Example

```solidity
// 1. Organization setup
uint256 orgId = baseRoll.registerOrganization("Acme Labs", "{}");

// 2. Add employee with split payout (70% primary, 30% savings)
address[] memory payouts = [primaryWallet, savingsWallet];
uint256[] memory percentages = [7000, 3000]; // basis points
EmployeeMetadata memory metadata = EmployeeMetadata({
    role: "Senior Engineer",
    department: "Engineering",
    jurisdictionCode: "US",
    customData: ""
});
uint256 empId = baseRoll.addEmployee(orgId, primaryWallet, payouts, percentages, metadata);

// 3. Set compensation (5000 USDC base + 1000 USDC bonus monthly)
CompensationComponent memory comp = CompensationComponent({
    baseAmount: 5000e6,      // USDC has 6 decimals
    bonusAmount: 1000e6,
    tokenAddress: address(0),
    tokenAmount: 0,
    vestingDuration: 0,
    vestingCliff: 0
});
baseRoll.createCompensationProfile(empId, comp, block.timestamp);

// 4. Create monthly payroll cycle
uint256 cycleId = baseRoll.createPayrollCycle(
    orgId,
    PayrollPeriod.MONTHLY,
    monthStart,
    monthEnd,
    usdcAddress
);

// 5. Execute payroll (transfers funds)
usdc.approve(address(baseRoll), 10000e6);
baseRoll.executePayrollCycle(cycleId);

// 6. Finalize cycle
baseRoll.finalizePayrollCycle(cycleId);
```

## Deployment Strategy

1. **Deploy on Base Sepolia** for testing
2. Run at least one full test cycle on-chain
3. Verify contracts on BaseScan
4. Deploy to Base mainnet after validation
5. Document addresses in `deployments/*.json`

## Technical Stack

- **Solidity 0.8.26** (Cancun EVM)
- **OpenZeppelin v4.9.6** (Upgradeable contracts)
- **Foundry** (Testing and deployment)
- **Base L2** (Optimized for low gas costs)

---

**Version:** 2.0.0
**Chain:** Base (Mainnet & Sepolia)
**License:** MIT
