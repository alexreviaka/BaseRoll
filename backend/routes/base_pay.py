from fastapi import APIRouter, HTTPException
from integrations.base_pay import BasePayClient

router = APIRouter(prefix="/api/base-pay", tags=["base-pay"])
base_pay = BasePayClient()

@router.post("/payment")
async def create_base_pay_payment(recipient: str, amount: float, token: str = "ETH"):
    try:
        result = base_pay.create_payment(recipient, amount, token)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/payment/{payment_id}")
async def get_payment_status(payment_id: str):
    try:
        status = base_pay.get_payment_status(payment_id)
        return status
    except Exception as e:
        raise HTTPException(status_code=404, detail="Payment not found")
