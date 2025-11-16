from web3 import Web3
import asyncio

class EventListener:
    def __init__(self, contract, event_name):
        self.contract = contract
        self.event_name = event_name
    
    async def start(self, callback):
        event_filter = self.contract.events[self.event_name].create_filter(fromBlock='latest')
        
        while True:
            for event in event_filter.get_new_entries():
                await callback(event)
            await asyncio.sleep(2)
