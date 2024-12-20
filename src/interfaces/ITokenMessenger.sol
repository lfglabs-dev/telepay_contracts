// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ITokenMessenger {
    function depositForBurn(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address burnToken
    ) external returns (uint64);
}
