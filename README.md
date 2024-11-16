# TelePay Smart Contracts

**TelePay is a cross-chain USD transfer system built for Telegram, enabling seamless transfers between users while abstracting away blockchain complexity.**

## Overview

TelePay consists of a network of smart contracts deployed across multiple chains that enable:
- Native USD transfers between Telegram users
- Cross-chain deposits and withdrawals
- Abstracted transaction fees and complexity
- Batched transfer operations
- Automated liquidity management

## Core Features

### User Operations
- Deposit USDC to any user's balance using their public key
- Withdraw USDC to any chain
- Transfer USDC between TelePay users
- Cross-chain transfers via CCTP

## Architecture

- Each supported chain has an identical contract deployment
- Cross-chain messaging handled via [Circle's CCTP](https://www.cctp.io/)
- Frontend interface available as a Telegram Mini App
- Signature-based authorization for user operations

## Development

### Prerequisites
- Python 3.8+
- Foundry
- Node.js 16+

### Setup

1. Clone the repository and install Foundry dependencies:
```shell
$ forge install
```

2. Set up Python virtual environment:
```shell
# Create virtual environment
$ python3 -m venv ./venv

# Activate virtual environment
# On macOS/Linux:
$ source venv/bin/activate
# On Windows:
$ .\venv\Scripts\activate

# Install Python dependencies
$ pip3 install -r requirements.txt
```

3. Set up environment variables:
```shell
# Copy example env file
$ cp .env.example .env

# Add your private key and other required variables to .env
PRIVATE_KEY=0x...
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Deploy

You can deploy and verify the contracts in two ways:

#### Option 1: Automated Deployment with Verification (Recommended)
Using the Python deployment script:
```shell
# Make sure your virtual environment is activated
$ source venv/bin/activate

# First, set up your explorer API keys in .env:
BASE_EXPLORER_API_KEY=your_basescan_api_key
ETHERSCAN_API_KEY=your_etherscan_api_key
ARBISCAN_API_KEY=your_arbiscan_api_key

# Run deployment script
$ python3 script/deploy.py
```

The script will:
1. Deploy Telepay on Base Sepolia
2. Verify Telepay contract on Basescan
3. Deploy Vault on Ethereum Sepolia
4. Verify Vault contract on Etherscan
5. Deploy Router on Arbitrum Sepolia
6. Verify Router contract on Arbiscan
7. Update .env with all contract addresses
8. Guide you through the process with interactive prompts

#### Option 2: Manual Deployment and Verification
If you prefer to deploy and verify manually:
```shell
# 1. Deploy and verify Telepay on Base Sepolia
$ forge script script/Telepay.s.sol --fork-url base_sepolia --broadcast --verify -vvv \
    --etherscan-api-key $BASE_EXPLORER_API_KEY
# Copy BASE_TELEPAY_ADDRESS to .env

# 2. Deploy and verify Vault and Router on Ethereum Sepolia
$ forge script script/Telepay.s.sol --fork-url eth_sepolia --broadcast --verify -vvv \
    --etherscan-api-key $ETHERSCAN_API_KEY
# Copy ETH_VAULT_ADDRESS to .env

# 3. Deploy and verify Router on Arbitrum
$ forge script script/Telepay.s.sol --fork-url arbitrum_sepolia --broadcast --verify -vvv \
    --etherscan-api-key $ARBISCAN_API_KEY
```

### Getting Explorer API Keys
To verify your contracts, you'll need API keys from:
- Base Sepolia: https://basescan.org/apis
- Ethereum Sepolia: https://etherscan.io/apis
- Arbitrum Sepolia: https://arbiscan.io/apis

### Available Networks
Networks are configured in foundry.toml:
- `base_sepolia`
- `eth_sepolia`
- `arbitrum_sepolia`

### Faucets
- Base Sepolia: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet
- Ethereum Sepolia: https://sepoliafaucet.com
- Arbitrum Sepolia: https://sepolia-faucet.arbitrum.io

## Links

- Frontend Repository: [@lfglabs-dev/app.telepay.cc](https://github.com/lfglabs-dev/app.telepay.cc)
- Telegram Bot: [TelePay Bot](https://t.me/telepay_bot)

## Security

This project is under active development. Use at your own risk.
