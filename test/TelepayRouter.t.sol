// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TelepayRouter} from "../src/TelepayRouter.sol";
import {Telepay} from "../src/Telepay.sol";
import "../test/mocks/MockUSDC.sol";

contract TelepayRouterTest is Test {
    TelepayRouter public router;
    Telepay public telepay;
    MockUSDC public usdc;

    address public constant USER = address(0x1234);
    address public constant MOCK_VAULT = address(0x5678);
    address public constant MOCK_TOKEN_MESSENGER = address(0x9ABC);
    address public constant MOCK_MESSAGE_TRANSMITTER = address(0xDEF0);
    uint256 constant INITIAL_BALANCE = 1000e6; // 1000 USDC

    // Test keys (64 bytes each, representing uncompressed public keys without 0x04 prefix)
    bytes constant TEST_PUB_KEY_1 =
        hex"0102030405060708091011121314151617181920212223242526272829303132333435363738394041424344454647484950515253545556575859606162636465";

    function setUp() public {
        // Deploy contracts
        telepay = new Telepay();
        usdc = new MockUSDC();
        router = new TelepayRouter(
            address(usdc),
            address(telepay),
            MOCK_VAULT,
            MOCK_TOKEN_MESSENGER,
            MOCK_MESSAGE_TRANSMITTER
        );

        // Label addresses for better trace output
        vm.label(address(telepay), "Telepay");
        vm.label(address(router), "TelepayRouter");
        vm.label(address(usdc), "USDC");
        vm.label(USER, "User");
        vm.label(MOCK_VAULT, "Vault");
        vm.label(MOCK_TOKEN_MESSENGER, "TokenMessenger");
        vm.label(MOCK_MESSAGE_TRANSMITTER, "MessageTransmitter");

        // Setup test user
        vm.startPrank(USER);
        usdc.mint(USER, INITIAL_BALANCE);
        usdc.approve(address(router), type(uint256).max);
        vm.stopPrank();
    }
}
