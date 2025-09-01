# GitHub Secrets Configuration

To enable GitHub Actions workflows, add the following secrets to your repository.

## How to Add Secrets

1. Go to: `https://github.com/alexreviaka/BaseRoll/settings/secrets/actions`
2. Click "New repository secret"
3. Add each secret below

---

## Required Secrets

### Smart Contract Deployment

**PRIVATE_KEY**
- Description: Private key for deploying contracts to Base network
- Value: Your Ethereum private key (without 0x prefix)
- ⚠️ NEVER commit this to repository
- Used in: Contract deployment workflows

**BASESCAN_API_KEY**
- Description: API key for contract verification on BaseScan
- Get it at: https://basescan.org/myapikey
- Used in: Contract verification after deployment

**BASE_RPC_URL** (Optional)
- Description: Custom RPC endpoint for Base Mainnet
- Default: https://mainnet.base.org
- Use if you have Alchemy/Infura endpoint

**BASE_SEPOLIA_RPC_URL** (Optional)
- Description: Custom RPC endpoint for Base Sepolia testnet
- Default: https://sepolia.base.org
- Use if you have Alchemy/Infura endpoint

---

## Optional Secrets (for enhanced features)

**BASE_PAY_API_KEY**
- Description: API key for Base Pay integration
- Required when: Integrating Base Pay payment processing
- Get it at: Base Pay developer portal

**MONGODB_URI** (for production)
- Description: MongoDB connection string for production database
- Format: `mongodb+srv://username:password@cluster.mongodb.net/baseroll`
- Required when: Deploying backend to production

**JWT_SECRET**
- Description: Secret key for JWT token generation
- Generate: `openssl rand -hex 32`
- Required when: Enabling authentication features

---

## CI/CD Workflow Secrets

Currently the workflows will fail until you add:
1. ✅ **PRIVATE_KEY** - for contract tests and deployment
2. ✅ **BASESCAN_API_KEY** - for contract verification

After adding these, GitHub Actions will turn green! 🟢

---

## Security Notes

- Never commit secrets to repository
- Rotate keys regularly
- Use different keys for testnet and mainnet
- Monitor usage in GitHub Actions logs
