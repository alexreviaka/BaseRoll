# Base Pay Integration

## Setup

1. Get API key from Base Pay dashboard
2. Add to `.env`:
```
BASE_PAY_API_KEY=your_key_here
```

## Usage

### Create Payment
```python
from integrations.base_pay import BasePayClient

client = BasePayClient()
payment = client.create_payment(
    recipient="0x...",
    amount=1000,
    token="USDC"
)
```

### Check Status
```python
status = client.get_payment_status(payment_id)
```

## API Reference

- POST /api/base-pay/payment - Create payment
- GET /api/base-pay/payment/{id} - Get status
