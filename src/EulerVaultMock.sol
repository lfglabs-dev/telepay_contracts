// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EulerVaultMock {
    IERC20 public immutable underlying;

    mapping(address => uint256) public shares;
    uint256 public totalShares;

    event Deposit(
        address indexed caller,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );
    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function deposit(
        uint256 amount,
        address receiver
    ) external returns (uint256) {
        require(amount > 0, "Amount must be greater than 0");
        require(receiver != address(0), "Invalid receiver");

        uint256 totalSupply = underlying.balanceOf(address(this));
        uint256 sharesToMint;

        if (totalShares == 0) {
            sharesToMint = amount;
        } else {
            sharesToMint = (amount * totalShares) / totalSupply;
        }

        // Handle "max" amount case
        if (amount == type(uint256).max) {
            amount = underlying.balanceOf(msg.sender);
        }

        // Transfer tokens from sender
        require(
            underlying.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        // Mint shares
        shares[receiver] += sharesToMint;
        totalShares += sharesToMint;

        emit Deposit(msg.sender, receiver, amount, sharesToMint);

        return sharesToMint;
    }

    function withdraw(
        uint256 amount,
        address receiver,
        address owner
    ) external returns (uint256) {
        require(amount > 0, "Amount must be greater than 0");
        require(receiver != address(0), "Invalid receiver");
        require(owner != address(0), "Invalid owner");
        require(msg.sender == owner, "Not authorized");

        uint256 totalSupply = underlying.balanceOf(address(this));
        uint256 sharesToBurn = (amount * totalShares) / totalSupply;

        require(shares[owner] >= sharesToBurn, "Insufficient shares");

        // Burn shares first (protect against reentrancy)
        shares[owner] -= sharesToBurn;
        totalShares -= sharesToBurn;

        // Transfer tokens to receiver
        require(underlying.transfer(receiver, amount), "Transfer failed");

        emit Withdraw(msg.sender, receiver, owner, amount, sharesToBurn);

        return sharesToBurn;
    }
}
