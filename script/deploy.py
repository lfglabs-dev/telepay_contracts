import os
import subprocess
import time
from dotenv import load_dotenv
from pathlib import Path

# Load environment variables from .env file
load_dotenv()


class DeploymentManager:
    def __init__(self):
        self.env_file = Path(".env")
        self.networks = {
            "base_sepolia": {
                "name": "Base Sepolia",
                "chain_id": 84532,
                "explorer_api_key": os.getenv("BASE_EXPLORER_API_KEY"),
                "verify_url": "https://api-sepolia.basescan.org/api",
            },
            "eth_sepolia": {
                "name": "Ethereum Sepolia",
                "chain_id": 11155111,
                "explorer_api_key": os.getenv("ETHERSCAN_API_KEY"),
                "verify_url": "https://api-sepolia.etherscan.io/api",
            },
            "arbitrum_sepolia": {
                "name": "Arbitrum Sepolia",
                "chain_id": 421614,
                "explorer_api_key": os.getenv("ARBISCAN_API_KEY"),
                "verify_url": "https://api-sepolia.arbiscan.io/api",
            },
        }

    def run_forge_command(
        self, network: str, verify: bool = True
    ) -> subprocess.CompletedProcess:
        """Run forge script command for a specific network"""
        print(f"\n🚀 Deploying to {self.networks[network]['name']}...")

        cmd = [
            "forge",
            "script",
            "script/Telepay.s.sol",
            "--fork-url",
            network,
            "--broadcast",
            "-vvv",
        ]

        if verify and self.networks[network]["explorer_api_key"]:
            cmd.extend(
                [
                    "--verify",
                    "--etherscan-api-key",
                    self.networks[network]["explorer_api_key"],
                ]
            )

        return subprocess.run(cmd, capture_output=True, text=True)

    def verify_contract(self, network: str, address: str, contract_name: str) -> bool:
        """Verify a deployed contract"""
        if not self.networks[network]["explorer_api_key"]:
            print(
                f"⚠️  Skipping verification: No API key for {self.networks[network]['name']}"
            )
            return False

        print(f"🔍 Verifying {contract_name} on {self.networks[network]['name']}...")

        cmd = [
            "forge",
            "verify-contract",
            address,
            contract_name,
            "--chain",
            str(self.networks[network]["chain_id"]),
            "--etherscan-api-key",
            self.networks[network]["explorer_api_key"],
            "--verifier-url",
            self.networks[network]["verify_url"],
        ]

        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ {contract_name} verified successfully!")
            return True
        else:
            print(f"❌ Verification failed: {result.stderr}")
            return False

    def update_env_file(self, key: str, value: str):
        """Update .env file with new values"""
        print(f"✍️  Updating {key} in .env file...")

        # Read current content
        with open(self.env_file, "r") as file:
            lines = file.readlines()

        # Update or add the key
        key_found = False
        for i, line in enumerate(lines):
            if line.startswith(f"{key}="):
                lines[i] = f"{key}={value}\n"
                key_found = True
                break

        if not key_found:
            lines.append(f"{key}={value}\n")

        # Write back to file
        with open(self.env_file, "w") as file:
            file.writelines(lines)

    def extract_address(self, output: str, contract_type: str) -> str:
        """Extract deployed contract address from forge output"""
        if contract_type == "Telepay":
            search_text = "Base Telepay deployed at:"
        elif contract_type == "Vault":
            search_text = "Ethereum Vault deployed at:"
        else:
            search_text = f"{contract_type} Router deployed at:"

        for line in output.split("\n"):
            if search_text in line:
                return line.split(":")[1].strip()
        return None

    def deploy(self):
        """Run the complete deployment sequence"""
        try:
            # Check for required API keys
            if not any(
                network["explorer_api_key"] for network in self.networks.values()
            ):
                print("⚠️  Warning: No explorer API keys found in .env")
                proceed = input("Continue without verification? (y/n): ")
                if proceed.lower() != "y":
                    return

            # 1. Deploy Telepay on Base Sepolia
            print("\n📝 Step 1: Deploying Telepay on Base Sepolia")
            result = self.run_forge_command("base_sepolia")
            if result.returncode != 0:
                print("❌ Base Sepolia deployment failed:")
                print(result.stderr)
                return

            telepay_address = self.extract_address(result.stdout, "Telepay")
            if telepay_address:
                self.update_env_file("BASE_TELEPAY_ADDRESS", telepay_address)
                print(f"✅ Telepay deployed at: {telepay_address}")
                self.verify_contract("base_sepolia", telepay_address, "Telepay")

            input("\n⏸️  Press Enter to continue with Ethereum Sepolia deployment...")

            # 2. Deploy Vault on Ethereum Sepolia
            print("\n📝 Step 2: Deploying Vault on Ethereum Sepolia")
            result = self.run_forge_command("eth_sepolia")
            if result.returncode != 0:
                print("❌ Ethereum Sepolia deployment failed:")
                print(result.stderr)
                return

            vault_address = self.extract_address(result.stdout, "Vault")
            if vault_address:
                self.update_env_file("ETH_VAULT_ADDRESS", vault_address)
                print(f"✅ Vault deployed at: {vault_address}")
                self.verify_contract("eth_sepolia", vault_address, "Vault")

            input("\n⏸️  Press Enter to continue with Arbitrum Sepolia deployment...")

            # 3. Deploy Router on Arbitrum Sepolia
            print("\n📝 Step 3: Deploying Router on Arbitrum Sepolia")
            result = self.run_forge_command("arbitrum_sepolia")
            if result.returncode != 0:
                print("❌ Arbitrum Sepolia deployment failed:")
                print(result.stderr)
                return

            router_address = self.extract_address(result.stdout, "Router")
            if router_address:
                self.update_env_file("ARBITRUM_ROUTER_ADDRESS", router_address)
                print(f"✅ Router deployed at: {router_address}")
                self.verify_contract("arbitrum_sepolia", router_address, "Router")

            print("\n✅ Deployment sequence completed successfully!")

        except Exception as e:
            print(f"\n❌ Deployment failed with error: {str(e)}")


if __name__ == "__main__":
    deployer = DeploymentManager()
    deployer.deploy()
