// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {TelepayVault} from "../src/TelepayVault.sol";

contract TelepayVaultScript is Script {
    address constant ETH_SEPOLIA_USDC =
        0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;

    function run() public {
        require(
            block.chainid == ETH_SEPOLIA_CHAIN_ID,
            "Must be on Ethereum Sepolia"
        );

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        console2.log("Deploying from:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        TelepayVault vault = new TelepayVault(
            ETH_SEPOLIA_USDC,
            vm.envAddress("ETH_TOKEN_MESSENGER")
        );
        console2.log("TelepayVault deployed at:", address(vault));

        vm.stopBroadcast();
    }
}
