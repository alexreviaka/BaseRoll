from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class CompanySchema(BaseModel):
    id: str
    name: str
    email: str
    wallet_address: str
    payroll_contract: Optional[str] = None
    created_at: datetime

class EmployeeSchema(BaseModel):
    id: str
    company_id: str
    name: str
    email: str
    wallet_address: str
    position: str
    salary: float
    payment_token: str = "ETH"
    is_active: bool = True
    created_at: datetime

class PaymentSchema(BaseModel):
    id: str
    company_id: str
    employee_id: str
    amount: float
    token: str
    tx_hash: Optional[str] = None
    status: str
    timestamp: datetime
