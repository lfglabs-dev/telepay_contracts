// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Telepay} from "../src/Telepay.sol";
import {TelepayRouter} from "../src/TelepayRouter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TelepayVault} from "../src/TelepayVault.sol";

contract TelepayScript is Script {
    Telepay public telepay;
    TelepayRouter public router;

    // Add chain IDs as constants for clarity
    uint256 constant BASE_SEPOLIA_CHAIN_ID = 84532;
    uint256 constant ARBITRUM_SEPOLIA_CHAIN_ID = 421614;
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;

    // USDC addresses for each network
    address constant BASE_SEPOLIA_USDC =
        0x036CbD53842c5426634e7929541eC2318f3dCF7e;
    address constant ETH_SEPOLIA_USDC =
        0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
    address constant ARBITRUM_SEPOLIA_USDC =
        0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d;

    function deployRouter(
        address _usdc,
        address _telepayAddress,
        address _vaultAddress,
        address _tokenMessenger,
        address _messageTransmitter
    ) internal returns (TelepayRouter) {
        return
            new TelepayRouter(
                _usdc,
                _telepayAddress,
                _vaultAddress,
                _tokenMessenger,
                _messageTransmitter
            );
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        console2.log("Deploying from:", deployer);
        console2.log("On chain ID:", block.chainid);

        vm.startBroadcast(deployerPrivateKey);

        if (block.chainid == BASE_SEPOLIA_CHAIN_ID) {
            console2.log("Deploying Telepay on Base Sepolia");
            telepay = new Telepay();
            console2.log("Base Telepay deployed at:", address(telepay));

            // Add router deployment for Base
            router = deployRouter(
                BASE_SEPOLIA_USDC,
                address(telepay), // Use the just-deployed Telepay address
                vm.envAddress("ETH_VAULT_ADDRESS"),
                vm.envAddress("BASE_TOKEN_MESSENGER"),
                vm.envAddress("BASE_MESSAGE_TRANSMITTER")
            );
            console2.log("Base Router deployed at:", address(router));

            console2.log("IMPORTANT: Add these addresses to .env:");
            console2.log("BASE_TELEPAY_ADDRESS=", address(telepay));
            console2.log("BASE_ROUTER_ADDRESS=", address(router));
        } else if (block.chainid == ETH_SEPOLIA_CHAIN_ID) {
            console2.log(
                "Deploying TelepayVault and Router on Ethereum Sepolia"
            );

            TelepayVault vault = new TelepayVault(
                ETH_SEPOLIA_USDC,
                vm.envAddress("ETH_TOKEN_MESSENGER"),
                vm.envAddress("BASE_TELEPAY_ADDRESS")
            );
            console2.log("TelepayVault deployed at:", address(vault));

            router = deployRouter(
                ETH_SEPOLIA_USDC,
                vm.envAddress("BASE_TELEPAY_ADDRESS"),
                address(vault),
                vm.envAddress("ETH_TOKEN_MESSENGER"),
                vm.envAddress("ETH_MESSAGE_TRANSMITTER")
            );
            console2.log("Ethereum Router deployed at:", address(router));
        } else if (block.chainid == ARBITRUM_SEPOLIA_CHAIN_ID) {
            console2.log("Deploying Router on Arbitrum Sepolia");

            router = deployRouter(
                ARBITRUM_SEPOLIA_USDC,
                vm.envAddress("BASE_TELEPAY_ADDRESS"),
                vm.envAddress("ETH_VAULT_ADDRESS"),
                vm.envAddress("ARBITRUM_TOKEN_MESSENGER"),
                vm.envAddress("ARBITRUM_MESSAGE_TRANSMITTER")
            );
            console2.log("Arbitrum Router deployed at:", address(router));
        } else {
            console2.log("Unsupported chain ID:", block.chainid);
            console2.log("Supported chains:");
            console2.log("- Base Sepolia:", BASE_SEPOLIA_CHAIN_ID);
            console2.log("- Arbitrum Sepolia:", ARBITRUM_SEPOLIA_CHAIN_ID);
            console2.log("- Ethereum Sepolia:", ETH_SEPOLIA_CHAIN_ID);
            revert("Unsupported chain");
        }

        vm.stopBroadcast();
    }
}
