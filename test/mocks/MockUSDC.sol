// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20 {
    constructor() ERC20("USD Coin", "USDC") {
        // Mint 1 million USDC to deployer
        // Note: USDC has 6 decimals, not 18 like most ERC20s
        _mint(msg.sender, 1_000_000 * 1e6);
    }

    // Override decimals to match real USDC
    function decimals() public pure override returns (uint8) {
        return 6;
    }

    // Optional: Add this for easier testing
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
