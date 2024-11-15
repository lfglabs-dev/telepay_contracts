// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Telepay} from "../src/Telepay.sol";
import {TelepayRouter} from "../src/TelepayRouter.sol";
import "../test/mocks/MockUSDC.sol";
import {TelepayVault} from "../src/TelepayVault.sol";

contract TelepayScript is Script {
    Telepay public telepay;
    TelepayRouter public router;
    MockUSDC public usdc;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy USDC mock (in production, use real USDC address)
        usdc = new MockUSDC();

        // Deploy Telepay and Router
        telepay = new Telepay();

        // Deploy Vault (using mock addresses for TokenMessenger in this example)
        address mockTokenMessenger = address(1); // In production, use real CCTP TokenMessenger address
        TelepayVault vault = new TelepayVault(
            address(usdc),
            mockTokenMessenger,
            address(telepay)
        );

        // Deploy Router with mock addresses for TokenMessenger and MessageTransmitter
        address mockMessageTransmitter = address(2); // In production, use real MessageTransmitter address
        router = new TelepayRouter(
            address(usdc),
            address(telepay),
            address(vault),
            mockTokenMessenger,
            mockMessageTransmitter
        );

        vm.stopBroadcast();
    }
}
