from fastapi import APIRouter, HTTPException
from typing import List
from models import PaymentRecord
from motor.motor_asyncio import AsyncIOMotorClient
from web3_utils import base_mainnet, base_sepolia
import os

router = APIRouter(prefix="/api/payments", tags=["payments"])

mongo_url = os.environ.get('MONGO_URL', 'mongodb://localhost:27017')
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ.get('DB_NAME', 'baseroll')]

@router.post("/process")
async def process_payment(
    company_id: str,
    employee_id: str,
    payroll_contract_address: str,
    network: str = "sepolia"
):
    """Process payment for an employee via smart contract"""
    
    # Get employee details
    employee = await db.employees.find_one({"id": employee_id}, {"_id": 0})
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")
    
    # Select network
    web3_helper = base_sepolia if network == "sepolia" else base_mainnet
    
    try:
        # Get payroll contract
        payroll = web3_helper.get_contract("Payroll", payroll_contract_address)
        
        # Check if payment is due
        employee_data = payroll.functions.getEmployee(employee['wallet_address']).call()
        
        if not employee_data[4]:  # isActive
            raise HTTPException(status_code=400, detail="Employee not active on chain")
        
        # Create payment record
        payment = PaymentRecord(
            company_id=company_id,
            employee_id=employee_id,
            amount=employee['salary'],
            token=employee['payment_token'],
            status="processing"
        )
        
        doc = payment.model_dump()
        doc['timestamp'] = doc['timestamp'].isoformat()
        
        await db.payments.insert_one(doc)
        
        return {
            "message": "Payment initiated",
            "payment_id": payment.id,
            "status": "processing"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Payment failed: {str(e)}")

@router.get("/company/{company_id}", response_model=List[PaymentRecord])
async def get_company_payments(company_id: str):
    """Get all payments for a company"""
    payments = await db.payments.find(
        {"company_id": company_id},
        {"_id": 0}
    ).to_list(1000)
    
    for payment in payments:
        if isinstance(payment.get('timestamp'), str):
            from datetime import datetime
            payment['timestamp'] = datetime.fromisoformat(payment['timestamp'])
    
    return payments

@router.get("/employee/{employee_id}", response_model=List[PaymentRecord])
async def get_employee_payments(employee_id: str):
    """Get all payments for an employee"""
    payments = await db.payments.find(
        {"employee_id": employee_id},
        {"_id": 0}
    ).to_list(1000)
    
    for payment in payments:
        if isinstance(payment.get('timestamp'), str):
            from datetime import datetime
            payment['timestamp'] = datetime.fromisoformat(payment['timestamp'])
    
    return payments

@router.get("/{payment_id}", response_model=PaymentRecord)
async def get_payment(payment_id: str):
    """Get payment details"""
    payment = await db.payments.find_one({"id": payment_id}, {"_id": 0})
    
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    if isinstance(payment.get('timestamp'), str):
        from datetime import datetime
        payment['timestamp'] = datetime.fromisoformat(payment['timestamp'])
    
    return payment
