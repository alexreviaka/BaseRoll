from fastapi import APIRouter
from web3_utils import base_mainnet

router = APIRouter(prefix="/api/blockchain", tags=["blockchain"])

@router.get("/balance/{address}")
async def get_balance(address: str):
    balance = base_mainnet.get_balance(address)
    return {"address": address, "balance": balance}
