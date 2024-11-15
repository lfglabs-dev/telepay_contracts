// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Telepay} from "../src/Telepay.sol";

contract TelepayTest is Test {
    Telepay public telepay;

    // Test keys (64 bytes each, representing uncompressed public keys without 0x04 prefix)
    bytes constant TEST_PUB_KEY_1 =
        hex"0102030405060708091011121314151617181920212223242526272829303132333435363738394041424344454647484950515253545556575859606162636465";
    bytes constant TEST_PUB_KEY_2 =
        hex"6566676869707172737475767778798081828384858687888990919293949596979899000102030405060708091011121314151617181920212223242526272829";

    // Test private key (for signing)
    uint256 constant PRIVATE_KEY_1 = 0x1234;

    uint256 constant TEST_AMOUNT = 1000;

    function setUp() public {
        telepay = new Telepay();
        vm.label(address(telepay), "Telepay");
    }

    function _signMessage(
        uint256 amount,
        bytes memory pubKey,
        address target,
        uint256 privateKey
    ) internal view returns (bytes memory) {
        bytes32 messageHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(
                    abi.encodePacked(amount, pubKey, target, address(telepay))
                )
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);
        return abi.encodePacked(r, s, v);
    }

    function test_Transfer() public {
        // Setup initial balance for TEST_PUB_KEY_1
        bytes32 slot = keccak256(
            abi.encodePacked(
                TEST_PUB_KEY_1,
                uint256(0) // mapping slot is 0
            )
        );

        vm.store(address(telepay), slot, bytes32(uint256(TEST_AMOUNT)));

        // Verify initial balance
        assertEq(telepay.balances(TEST_PUB_KEY_1), TEST_AMOUNT);
        assertEq(telepay.balances(TEST_PUB_KEY_2), 0);

        // Perform transfer
        telepay.transfer(
            TEST_AMOUNT,
            TEST_PUB_KEY_1,
            TEST_PUB_KEY_2,
            _signMessage(TEST_AMOUNT, TEST_PUB_KEY_1, address(0), PRIVATE_KEY_1)
        );

        // Verify final balances
        assertEq(telepay.balances(TEST_PUB_KEY_1), 0);
        assertEq(telepay.balances(TEST_PUB_KEY_2), TEST_AMOUNT);
    }

    function testFail_TransferInsufficientBalance() public {
        // Try to transfer more than available balance
        telepay.transfer(
            TEST_AMOUNT,
            TEST_PUB_KEY_1,
            TEST_PUB_KEY_2,
            _signMessage(TEST_AMOUNT, TEST_PUB_KEY_1, address(0), PRIVATE_KEY_1)
        );
    }
}
