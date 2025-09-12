from web3 import Web3
import json

class BlockchainService:
    def __init__(self, rpc_url: str):
        self.w3 = Web3(Web3.HTTPProvider(rpc_url))
        
    def get_contract(self, address: str, abi_path: str):
        with open(abi_path, 'r') as f:
            abi = json.load(f)['abi']
        return self.w3.eth.contract(address=address, abi=abi)
