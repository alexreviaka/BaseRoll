from typing import List
from models import Employee
from web3_utils import base_mainnet

class BatchPaymentService:
    def __init__(self, payroll_contract):
        self.contract = payroll_contract
    
    async def process_batch(self, employee_addresses: List[str]):
        tx = await self.contract.functions.batchProcessPayments(
            employee_addresses
        ).build_transaction()
        return tx
