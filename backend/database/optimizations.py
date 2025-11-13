from motor.motor_asyncio import AsyncIOMotorClient

class DatabaseOptimizer:
    @staticmethod
    async def create_indexes(db):
        await db.companies.create_index("wallet_address")
        await db.employees.create_index([("company_id", 1), ("is_active", 1)])
        await db.payments.create_index([("timestamp", -1)])
