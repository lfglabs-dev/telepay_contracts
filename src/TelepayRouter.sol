// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Telepay.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ITokenMessenger.sol";
import "./interfaces/IMessageTransmitter.sol";

contract TelepayRouter {
    IERC20 public immutable TOKEN;
    Telepay public immutable TELEPAY;
    address public immutable VAULT;
    ITokenMessenger public immutable TOKEN_MESSENGER;
    IMessageTransmitter public immutable MESSAGE_TRANSMITTER;

    uint32 public constant TELEPAY_DOMAIN = 6; // Base domain ID
    uint32 public constant VAULT_DOMAIN = 0; // Ethereum domain ID

    event Deposit(bytes indexed pubKey, uint256 amount);
    event TelepayRouterDeployed(address indexed telepay, address indexed vault);

    constructor(
        address _token,
        address _telepay,
        address _vault,
        address _tokenMessenger,
        address _messageTransmitter
    ) {
        TOKEN = IERC20(_token);
        TELEPAY = Telepay(_telepay);
        VAULT = _vault;
        TOKEN_MESSENGER = ITokenMessenger(_tokenMessenger);
        MESSAGE_TRANSMITTER = IMessageTransmitter(_messageTransmitter);

        // Approve TokenMessenger to spend tokens
        TOKEN.approve(address(TOKEN_MESSENGER), type(uint256).max);

        // Emit deployment event
        emit TelepayRouterDeployed(_telepay, _vault);
    }

    /// @notice Deposits tokens and credits the balance to a public key in Telepay
    /// @param pubKey The public key to credit the balance to
    /// @param amount The amount to deposit
    function deposit(bytes calldata pubKey, uint256 amount) external {
        // Check that amount is greater than 0
        require(amount > 0, "Amount must be greater than 0");

        // Check if the user has approved enough tokens
        require(
            TOKEN.allowance(msg.sender, address(this)) >= amount,
            "Insufficient allowance"
        );

        // Check if the user has enough balance
        require(TOKEN.balanceOf(msg.sender) >= amount, "Insufficient balance");

        // Transfer tokens from user to this contract
        require(
            TOKEN.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        // Ensure TOKEN_MESSENGER has approval to spend tokens
        uint256 currentAllowance = TOKEN.allowance(
            address(this),
            address(TOKEN_MESSENGER)
        );
        if (currentAllowance < amount) {
            require(
                TOKEN.approve(address(TOKEN_MESSENGER), type(uint256).max),
                "Token messenger approval failed"
            );
        }

        // Burn tokens via CCTP
        TOKEN_MESSENGER.depositForBurn(
            amount,
            VAULT_DOMAIN,
            bytes32(uint256(uint160(VAULT))),
            address(TOKEN)
        );

        // Send message to Telepay to credit balance
        bytes memory message = abi.encode(amount, pubKey);
        MESSAGE_TRANSMITTER.sendMessage(
            TELEPAY_DOMAIN,
            bytes32(uint256(uint160(address(TELEPAY)))),
            message
        );

        // Emit a deposit event
        emit Deposit(pubKey, amount);
    }
}
