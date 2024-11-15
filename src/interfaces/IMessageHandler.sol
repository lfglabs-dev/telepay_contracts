// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMessageHandler {
    function handleReceiveMessage(
        bytes calldata message,
        uint256 sourceDomain,
        bytes32 sender
    ) external;
}
