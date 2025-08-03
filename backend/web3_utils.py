from web3 import Web3
from typing import Dict, Any
import json
import os
from pathlib import Path

class Web3Helper:
    def __init__(self, rpc_url: str):
        self.w3 = Web3(Web3.HTTPProvider(rpc_url))
        self.contracts_dir = Path(__file__).parent.parent / "artifacts" / "contracts"
        
    def is_connected(self) -> bool:
        return self.w3.is_connected()
    
    def get_contract(self, contract_name: str, address: str):
        """Load contract ABI and create contract instance"""
        abi_path = self.contracts_dir / f"{contract_name}.sol" / f"{contract_name}.json"
        
        with open(abi_path, 'r') as f:
            contract_json = json.load(f)
            abi = contract_json['abi']
        
        return self.w3.eth.contract(address=address, abi=abi)
    
    def get_balance(self, address: str) -> float:
        """Get ETH balance of address"""
        balance_wei = self.w3.eth.get_balance(address)
        return self.w3.from_wei(balance_wei, 'ether')
    
    def get_token_balance(self, token_address: str, wallet_address: str) -> float:
        """Get ERC20 token balance"""
        # Minimal ERC20 ABI for balanceOf
        erc20_abi = [
            {
                "constant": True,
                "inputs": [{"name": "_owner", "type": "address"}],
                "name": "balanceOf",
                "outputs": [{"name": "balance", "type": "uint256"}],
                "type": "function"
            }
        ]
        
        token_contract = self.w3.eth.contract(address=token_address, abi=erc20_abi)
        balance = token_contract.functions.balanceOf(wallet_address).call()
        return self.w3.from_wei(balance, 'ether')
    
    def send_transaction(self, tx_params: Dict[str, Any], private_key: str) -> str:
        """Sign and send transaction"""
        signed_tx = self.w3.eth.account.sign_transaction(tx_params, private_key)
        tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)
        return tx_hash.hex()
    
    def wait_for_transaction(self, tx_hash: str, timeout: int = 120) -> Dict:
        """Wait for transaction receipt"""
        receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash, timeout=timeout)
        return dict(receipt)

# Initialize Web3 instances
base_mainnet = Web3Helper(os.getenv("BASE_RPC_URL", "https://mainnet.base.org"))
base_sepolia = Web3Helper(os.getenv("BASE_SEPOLIA_RPC_URL", "https://sepolia.base.org"))
