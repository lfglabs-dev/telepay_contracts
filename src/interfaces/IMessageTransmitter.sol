// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMessageTransmitter {
    /// @notice Sends a message to a destination domain and recipient
    /// @param destinationDomain The domain ID of the destination chain
    /// @param recipient The recipient address on the destination chain (as bytes32)
    /// @param messageBody The message to be sent
    function sendMessage(
        uint32 destinationDomain,
        bytes32 recipient,
        bytes memory messageBody
    ) external;
}
