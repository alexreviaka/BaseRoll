# Deployment Guide

## Prerequisites
- Node.js 18+
- Hardhat
- Base RPC access
- Private key with funds

## Steps

### 1. Deploy Contracts
```bash
npx hardhat run scripts/deploy.js --network baseSepolia
```

### 2. Verify Contracts
```bash
npx hardhat verify --network baseSepolia CONTRACT_ADDRESS
```

### 3. Update Frontend Config
Add contract addresses to `.env`

### 4. Deploy Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

### 5. Deploy Frontend
```bash
cd frontend
yarn build
# Deploy to Vercel/Netlify
```
