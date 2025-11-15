import requests
from typing import Dict

class WebhookService:
    def __init__(self, webhook_url: str):
        self.webhook_url = webhook_url
    
    async def send_notification(self, event: str, data: Dict):
        payload = {
            "event": event,
            "data": data,
            "timestamp": str(datetime.utcnow())
        }
        try:
            response = requests.post(self.webhook_url, json=payload, timeout=5)
            return response.status_code == 200
        except Exception as e:
            print(f"Webhook failed: {e}")
            return False
