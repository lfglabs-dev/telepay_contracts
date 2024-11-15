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

    event Deposit(bytes indexed pubKey, uint256 amount, uint256 nonce);

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
    }

    /// @notice Deposits tokens and credits the balance to a public key in Telepay
    /// @param pubKey The public key to credit the balance to
    /// @param amount The amount to deposit
    /// @param nonce A unique number to prevent replay attacks
    function deposit(
        bytes calldata pubKey,
        uint256 amount,
        uint256 nonce
    ) external {
        // Transfer tokens from user to vault

        // First transfer tokens from caller to this contract
        require(
            TOKEN.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

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
        emit Deposit(pubKey, amount, nonce);
    }
}
