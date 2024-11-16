import os
import subprocess
import time
from dotenv import load_dotenv
from pathlib import Path

load_dotenv()


class DeploymentManager:
    def __init__(self):
        # Check required environment variables
        required_vars = [
            "BASE_SEPOLIA_RPC",
            "ETH_SEPOLIA_RPC",
            "ARBITRUM_SEPOLIA_RPC",
            "BASE_EXPLORER_API_KEY",
            "ETHERSCAN_API_KEY",
            "ARBISCAN_API_KEY",
            "PRIVATE_KEY",
            "BASE_TOKEN_MESSENGER",
            "BASE_MESSAGE_TRANSMITTER",
            "ETH_TOKEN_MESSENGER",
            "ETH_MESSAGE_TRANSMITTER",
            "ARBITRUM_TOKEN_MESSENGER",
            "ARBITRUM_MESSAGE_TRANSMITTER",
            "BASE_SEPOLIA_USDC",
            "ETH_SEPOLIA_USDC",
            "ARBITRUM_SEPOLIA_USDC",
        ]

        missing_vars = [var for var in required_vars if not os.getenv(var)]
        if missing_vars:
            raise EnvironmentError(
                f"Missing required environment variables: {', '.join(missing_vars)}\n"
                f"Please check your .env file"
            )

        # Store deployed addresses in memory
        self.deployed_addresses = {
            "ETH_VAULT_ADDRESS": None,
            "BASE_TELEPAY_ADDRESS": None,
            "BASE_ROUTER_ADDRESS": None,
            "ETH_ROUTER_ADDRESS": None,
            "ARBITRUM_ROUTER_ADDRESS": None,
            "ETH_EULER_VAULT_ADDRESS": None,
        }

        self.networks = {
            "base_sepolia": {
                "name": "Base Sepolia",
                "chain_id": 84532,
                "rpc_url": os.getenv("BASE_SEPOLIA_RPC"),
                "explorer_api_key": os.getenv("BASE_EXPLORER_API_KEY"),
                "verify_url": "https://api-sepolia.basescan.org/api",
            },
            "eth_sepolia": {
                "name": "Ethereum Sepolia",
                "chain_id": 11155111,
                "rpc_url": os.getenv("ETH_SEPOLIA_RPC"),
                "explorer_api_key": os.getenv("ETHERSCAN_API_KEY"),
                "verify_url": "https://api-sepolia.etherscan.io/api",
            },
            "arbitrum_sepolia": {
                "name": "Arbitrum Sepolia",
                "chain_id": 421614,
                "rpc_url": os.getenv("ARBITRUM_SEPOLIA_RPC"),
                "explorer_api_key": os.getenv("ARBISCAN_API_KEY"),
                "verify_url": "https://api-sepolia.arbiscan.io/api",
            },
        }
        self.deployed_contracts = {
            "base_sepolia": {},
            "eth_sepolia": {},
            "arbitrum_sepolia": {},
        }

    def run_forge_command(
        self, script_path: str, network: str, verify: bool = True
    ) -> subprocess.CompletedProcess:
        """Run forge script command for a specific network"""
        print(f"\n🚀 Deploying {script_path} to {self.networks[network]['name']}...")

        # Create environment variables for the subprocess
        env = os.environ.copy()
        for key, value in self.deployed_addresses.items():
            if value is not None:
                env[key] = value

        # First run deployment without verification
        cmd = [
            "forge",
            "script",
            script_path,
            "--rpc-url",
            self.networks[network]["rpc_url"],
            "--broadcast",
            "-vvv",
        ]

        result = subprocess.run(cmd, capture_output=True, text=True, env=env)

        if result.returncode != 0:
            return result

        # If deployment successful and verification requested, try to verify
        if verify and self.networks[network]["explorer_api_key"]:
            print(
                f"🔍 Attempting to verify contract on {self.networks[network]['name']}..."
            )
            verify_cmd = cmd + [
                "--verify",
                "--etherscan-api-key",
                self.networks[network]["explorer_api_key"],
            ]
            verify_result = subprocess.run(
                verify_cmd, capture_output=True, text=True, env=env
            )

            if verify_result.returncode != 0:
                print(
                    f"❌ Verification failed on {self.networks[network]['name']}: {verify_result.stderr}"
                )
                return verify_result

        return result

    def extract_address(self, output: str, contract_type: str) -> str:
        """Extract deployed contract address from forge output"""
        search_texts = {
            "Telepay": "Base Telepay deployed at:",
            "TelepayVault": "TelepayVault deployed at:",
            "Router": "Router deployed at:",
            "BaseRouter": "Base Router deployed at:",
            "EthereumRouter": "Ethereum Router deployed at:",
            "ArbitrumRouter": "Arbitrum Router deployed at:",
            "EulerVaultMock": "EulerVaultMock deployed at:",
        }

        search_text = search_texts.get(contract_type, f"{contract_type} deployed at:")

        for line in output.split("\n"):
            if search_text in line:
                return line.split(":", 1)[1].strip()
        return None

    def deploy(self):
        """Run the complete deployment sequence"""
        try:
            # 1. Deploy EulerVaultMock on Ethereum Sepolia
            print("\n📝 Step 1: Deploying EulerVaultMock on Ethereum Sepolia")
            result = self.run_forge_command("script/EulerVault.s.sol", "eth_sepolia")
            if result.returncode != 0:
                raise Exception(f"EulerVaultMock deployment failed: {result.stderr}")

            euler_vault_address = self.extract_address(result.stdout, "EulerVaultMock")
            if euler_vault_address:
                self.deployed_addresses["ETH_EULER_VAULT_ADDRESS"] = euler_vault_address
                self.deployed_contracts["eth_sepolia"][
                    "EulerVaultMock"
                ] = euler_vault_address
                print(f"✅ EulerVaultMock deployed at: {euler_vault_address}")

            # 2. Deploy Vault on Ethereum Sepolia
            print("\n📝 Step 2: Deploying Vault on Ethereum Sepolia")
            result = self.run_forge_command("script/Vault.s.sol", "eth_sepolia")
            if result.returncode != 0:
                raise Exception(f"Vault deployment failed: {result.stderr}")

            vault_address = self.extract_address(result.stdout, "TelepayVault")
            if vault_address:
                self.deployed_addresses["ETH_VAULT_ADDRESS"] = vault_address
                self.deployed_contracts["eth_sepolia"]["TelepayVault"] = vault_address
                print(f"✅ Vault deployed at: {vault_address}")

            # 3. Deploy Telepay on Base Sepolia
            print("\n📝 Step 3: Deploying Telepay on Base Sepolia")
            result = self.run_forge_command("script/Telepay.s.sol", "base_sepolia")
            if result.returncode != 0:
                raise Exception(f"Telepay deployment failed: {result.stderr}")

            telepay_address = self.extract_address(result.stdout, "Telepay")
            if telepay_address:
                self.deployed_addresses["BASE_TELEPAY_ADDRESS"] = telepay_address
                self.deployed_contracts["base_sepolia"]["Telepay"] = telepay_address
                print(f"✅ Telepay deployed at: {telepay_address}")

            # 4. Deploy Router only on Arbitrum
            print(f"\n📝 Deploying Router on Arbitrum Sepolia")
            result = self.run_forge_command("script/Router.s.sol", "arbitrum_sepolia")
            if result.returncode != 0:
                raise Exception(
                    f"Router deployment on arbitrum_sepolia failed: {result.stderr}"
                )

            router_address = self.extract_address(result.stdout, "Router")
            if router_address:
                self.deployed_addresses["ARBITRUM_ROUTER_ADDRESS"] = router_address
                self.deployed_contracts["arbitrum_sepolia"][
                    "TelepayRouter"
                ] = router_address
                print(f"✅ Router deployed at: {router_address}")

            # Comment out Base and Ethereum router deployments for now
            # for network in ["base_sepolia", "eth_sepolia", "arbitrum_sepolia"]:
            #     print(f"\n📝 Deploying Router on {self.networks[network]['name']}")
            #     result = self.run_forge_command("script/Router.s.sol", network)
            #     if result.returncode != 0:
            #         raise Exception(
            #             f"Router deployment on {network} failed: {result.stderr}"
            #         )

            # Print deployment summary
            print("\n" + "=" * 50)
            print("📋 DEPLOYMENT SUMMARY")
            print("=" * 50)

            for network, contracts in self.deployed_contracts.items():
                if contracts:
                    print(f"\n🌐 {self.networks[network]['name']}:")
                    print("-" * 40)
                    for contract_name, address in contracts.items():
                        print(f"📄 {contract_name}: {address}")

            print("\n✅ Deployment sequence completed successfully!")

        except Exception as e:
            print(f"\n❌ Deployment failed with error: {str(e)}")
            raise


if __name__ == "__main__":
    deployer = DeploymentManager()
    deployer.deploy()
