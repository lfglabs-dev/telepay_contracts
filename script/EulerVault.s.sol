// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/EulerVaultMock.sol";

contract EulerVaultScript is Script {
    function run() external {
        require(block.chainid == 11155111, "Must be on Ethereum Sepolia");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address usdc = vm.envAddress("ETH_SEPOLIA_USDC");
        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deploying from:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        EulerVaultMock eulerVault = new EulerVaultMock(usdc);

        console.log("EulerVaultMock deployed at:", address(eulerVault));

        vm.stopBroadcast();
    }
}
