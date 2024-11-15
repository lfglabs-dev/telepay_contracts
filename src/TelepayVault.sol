// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMessageHandler.sol";
import "./interfaces/ITokenMessenger.sol";

contract TelepayVault is IMessageHandler {
    IERC20 public immutable token;
    ITokenMessenger public immutable tokenMessenger;
    address public immutable telepay;

    event Invested(uint256 amount);
    event Uninvested(uint256 amount);

    constructor(address _token, address _tokenMessenger, address _telepay) {
        token = IERC20(_token);
        tokenMessenger = ITokenMessenger(_tokenMessenger);
        telepay = _telepay;
    }

    function invest(uint256 amount) external {
        // Vault must already have the tokens
        require(
            token.balanceOf(address(this)) >= amount,
            "Insufficient balance"
        );

        emit Invested(amount);
    }

    function uninvest(uint256 amount) external {
        emit Uninvested(amount);
    }

    function handleReceiveMessage(
        bytes calldata message,
        uint256 sourceDomain,
        bytes32 sender
    ) external override {
        // Verify sender is Telepay
        require(msg.sender == telepay, "Only Telepay can call");

        // Decode message
        (uint256 amount, uint32 targetDomain, address target) = abi.decode(
            message,
            (uint256, uint32, address)
        );

        // Approve TokenMessenger to spend tokens
        token.approve(address(tokenMessenger), amount);

        // Send tokens via CCTP
        tokenMessenger.depositForBurn(
            amount,
            targetDomain, // Use decoded targetDomain
            bytes32(uint256(uint160(target))), // Convert address to bytes32
            address(token)
        );
    }
}
