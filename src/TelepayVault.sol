// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMessageHandler.sol";
import "./interfaces/ITokenMessenger.sol";
import "./EulerVaultMock.sol";

contract TelepayVault is IMessageHandler {
    IERC20 public immutable token;
    ITokenMessenger public immutable tokenMessenger;
    EulerVaultMock public immutable eulerVault;

    event Invested(uint256 amount);
    event Uninvested(uint256 amount);

    constructor(address _token, address _tokenMessenger, address _eulerVault) {
        token = IERC20(_token);
        tokenMessenger = ITokenMessenger(_tokenMessenger);
        eulerVault = EulerVaultMock(_eulerVault);

        // Approve EulerVault to spend tokens
        token.approve(_eulerVault, type(uint256).max);
    }

    function invest(uint256 amount) external {
        // Vault must already have the tokens
        require(
            token.balanceOf(address(this)) >= amount,
            "Insufficient balance"
        );

        // Deposit into Euler vault
        eulerVault.deposit(amount, address(this));

        emit Invested(amount);
    }

    function uninvest(uint256 amount) external {
        // Withdraw from Euler vault
        eulerVault.withdraw(
            amount,
            address(this), // receive tokens back to this contract
            address(this) // we are the owner of the shares
        );

        emit Uninvested(amount);
    }

    function handleReceiveMessage(
        uint32 sourceDomain,
        bytes32 sender,
        bytes calldata messageBody
    ) external override returns (bool) {
        //  todo: check it is actually called by circle

        // todo: check it is called by telepay router
        // require(
        //     sender == bytes32(uint256(uint160(telepay_router))),
        //     "Only Telepay can call"
        // );

        // Decode message
        (uint256 amount, uint32 targetDomain, address target) = abi.decode(
            messageBody,
            (uint256, uint32, address)
        );

        // Approve TokenMessenger to spend tokens
        token.approve(address(tokenMessenger), amount);

        // Send tokens via CCTP
        tokenMessenger.depositForBurn(
            amount,
            targetDomain,
            bytes32(uint256(uint160(target))),
            address(token)
        );

        return true;
    }
}
