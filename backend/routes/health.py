from fastapi import APIRouter
from motor.motor_asyncio import AsyncIOMotorClient
from web3_utils import base_mainnet
import os

router = APIRouter(prefix="/api/health", tags=["health"])

@router.get("/")
async def health_check():
    return {
        "status": "healthy",
        "version": "0.2.0",
        "timestamp": datetime.utcnow().isoformat()
    }

@router.get("/database")
async def database_health():
    try:
        client = AsyncIOMotorClient(os.getenv('MONGO_URL'))
        await client.server_info()
        return {"status": "healthy", "service": "mongodb"}
    except Exception as e:
        return {"status": "unhealthy", "service": "mongodb", "error": str(e)}

@router.get("/blockchain")
async def blockchain_health():
    try:
        is_connected = base_mainnet.is_connected()
        return {"status": "healthy" if is_connected else "unhealthy", "service": "base"}
    except Exception as e:
        return {"status": "unhealthy", "service": "base", "error": str(e)}
