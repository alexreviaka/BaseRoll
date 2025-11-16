# BaseRoll 🚀

Decentralized payroll system built on Base blockchain.

## Features

- 🏢 **Company Management**: Register and manage your company on-chain
- 👥 **Employee Onboarding**: Add employees with their wallet addresses
- 💰 **Automated Payments**: Schedule and process payments automatically
- 🪙 **Multi-Token Support**: Pay in ETH, USDC, DAI, or any ERC-20
- 📊 **Analytics Dashboard**: Track payments, employees, and metrics
- 🔗 **Base Pay Integration**: Seamless integration with Base Pay
- ⚡ **Upgradeable Contracts**: Proxy pattern for future improvements

## Tech Stack

**Smart Contracts**
- Solidity 0.8.20
- Hardhat
- OpenZeppelin (Upgradeable)

**Backend**
- FastAPI
- MongoDB
- Web3.py

**Frontend**
- React 18
- Vite
- Tailwind CSS
- ethers.js

**Blockchain**
- Base Mainnet (ChainID: 8453)
- Base Sepolia (ChainID: 84532)

## Quick Start

### Prerequisites
- Node.js 18+
- Python 3.11+
- MongoDB
- MetaMask wallet

### Installation

**1. Clone repository**
```bash
git clone https://github.com/alexreviaka/BaseRoll.git
cd BaseRoll
```

**2. Install contracts dependencies**
```bash
npm install
npx hardhat compile
```

**3. Setup backend**
```bash
cd backend
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your settings
python main.py
```

**4. Setup frontend**
```bash
cd frontend
yarn install
cp .env.example .env
# Edit .env with your settings
yarn dev
```

## Deployment

### Smart Contracts

**Base Sepolia (Testnet)**
```bash
npx hardhat run scripts/deploy.js --network baseSepolia
```

**Base Mainnet**
```bash
npx hardhat run scripts/deploy.js --network baseMainnet
```

### Verification
```bash
npx hardhat verify --network baseSepolia CONTRACT_ADDRESS
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [API Documentation](docs/API.md)
- [Base Pay Integration](docs/BASE_PAY.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [User Guide](docs/USER_GUIDE.md)
- [FAQ](docs/FAQ.md)

## Testing

**Smart Contracts**
```bash
npx hardhat test
npx hardhat coverage
```

**Backend**
```bash
cd backend
pytest
```

**Frontend**
```bash
cd frontend
yarn test
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md)

## Security

Report vulnerabilities to security@baseroll.io

See [SECURITY.md](SECURITY.md) for details.

## License

MIT © 2025 BaseRoll

## Links

- Website: https://baseroll.io
- Documentation: https://docs.baseroll.io
- Twitter: https://twitter.com/baseroll
- Discord: https://discord.gg/baseroll

---

Built with ❤️ on Base
