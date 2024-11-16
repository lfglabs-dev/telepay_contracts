// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./interfaces/IMessageHandler.sol";

contract Telepay is IMessageHandler {
    using ECDSA for bytes32;

    mapping(bytes => uint256) public balances;

    event NativeTransfer(bytes fromPubKey, bytes toPubKey, uint256 amount);

    /// @notice Updates balances to reflect transfers between telegram users
    /// @param amount The amount to transfer between public keys
    /// @param sourcePubKey The public key of the sender
    /// @param targetPubKey The public key of the recipient
    /// @param signature Signature proving ownership of the source public key
    function transfer(
        uint256 amount,
        bytes calldata sourcePubKey,
        bytes calldata targetPubKey,
        bytes calldata signature
    ) external {
        require(balances[sourcePubKey] >= amount, "Insufficient balance");
        _verifySignature(amount, sourcePubKey, address(0), signature);

        balances[sourcePubKey] -= amount;
        balances[targetPubKey] += amount;

        emit NativeTransfer(sourcePubKey, targetPubKey, amount);
    }

    function handleReceiveMessage(
        bytes calldata message,
        uint256 sourceDomain,
        bytes32 sender
    ) external override {
        //  todo: check it is actually called by circle

        // Verify the sender is TelepayRouter
        _verifySender(sourceDomain, sender);

        // Decode message into amount and pubKey
        (uint256 amount, bytes memory pubKey) = abi.decode(
            message,
            (uint256, bytes)
        );

        // Credit the balance
        balances[pubKey] += amount;
    }

    function _verifySignature(
        uint256 amount,
        bytes memory pubKey,
        address target,
        bytes memory signature
    ) internal pure {
        // Mock implementation - in production, implement proper signature verification
        require(signature.length > 0, "Invalid signature");
    }

    function _verifySender(uint256 sourceDomain, bytes32 sender) internal pure {
        // Mock implementation - in production, implement proper sender verification
        // TODO: Verify the sender is an authorized contract on the source domain
        require(sender != bytes32(0), "Invalid sender");
    }

    // TODO: Add admin-only modifier
    function debugSetValue(bytes calldata pubKey, uint256 amount) external {
        balances[pubKey] = amount;
    }
}
