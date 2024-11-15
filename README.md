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

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Deploy

```shell
$ forge script script/Deploy.s.sol:DeployScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

## Links

- Frontend Repository: [@lfglabs-dev/app.telepay.cc](https://github.com/lfglabs-dev/app.telepay.cc)
- Telegram Bot: [TelePay Bot](https://t.me/telepay_bot)

## Security

This project is under active development. Use at your own risk.
