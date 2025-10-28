import requests
import os

class BasePayClient:
    def __init__(self):
        self.api_key = os.getenv('BASE_PAY_API_KEY')
        self.base_url = 'https://api.base.pay'
    
    def create_payment(self, recipient, amount, token):
        headers = {'Authorization': f'Bearer {self.api_key}'}
        payload = {
            'recipient': recipient,
            'amount': amount,
            'token': token
        }
        response = requests.post(
            f'{self.base_url}/payments',
            json=payload,
            headers=headers
        )
        return response.json()
    
    def get_payment_status(self, payment_id):
        headers = {'Authorization': f'Bearer {self.api_key}'}
        response = requests.get(
            f'{self.base_url}/payments/{payment_id}',
            headers=headers
        )
        return response.json()
