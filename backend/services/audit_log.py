from datetime import datetime
from models import AuditLog

class AuditLogService:
    def __init__(self, db):
        self.db = db
    
    async def log_action(self, user_id: str, action: str, details: dict):
        log = AuditLog(
            user_id=user_id,
            action=action,
            details=details,
            timestamp=datetime.utcnow()
        )
        await self.db.audit_logs.insert_one(log.model_dump())
    
    async def get_logs(self, user_id: str = None, limit: int = 100):
        query = {"user_id": user_id} if user_id else {}
        logs = await self.db.audit_logs.find(query).sort("timestamp", -1).limit(limit).to_list(limit)
        return logs
