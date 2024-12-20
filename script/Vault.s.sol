// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/TelepayVault.sol";

contract VaultScript is Script {
    function run() external {
        require(block.chainid == 11155111, "Must be on Ethereum Sepolia");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenMessenger = vm.envAddress("ETH_TOKEN_MESSENGER");
        address usdc = vm.envAddress("ETH_SEPOLIA_USDC");
        address eulerVault = vm.envAddress("ETH_EULER_VAULT_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        TelepayVault vault = new TelepayVault(usdc, tokenMessenger, eulerVault);

        console.log("TelepayVault deployed at:", address(vault));

        vm.stopBroadcast();
    }
}
