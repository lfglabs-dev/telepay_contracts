// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Telepay} from "../src/Telepay.sol";

contract TelepayBaseScript is Script {
    uint256 constant BASE_SEPOLIA_CHAIN_ID = 84532;

    function run() public {
        require(
            block.chainid == BASE_SEPOLIA_CHAIN_ID,
            "Must be on Base Sepolia"
        );

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        console2.log("Deploying from:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        Telepay telepay = new Telepay();
        console2.log("Base Telepay deployed at:", address(telepay));

        vm.stopBroadcast();
    }
}
