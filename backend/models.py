from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, List
from datetime import datetime
import uuid

class Company(BaseModel):
    model_config = ConfigDict(extra="ignore")
    
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    email: str
    wallet_address: str
    payroll_contract: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

class Employee(BaseModel):
    model_config = ConfigDict(extra="ignore")
    
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    company_id: str
    name: str
    email: str
    wallet_address: str
    position: str
    salary: float
    payment_token: str = "ETH"
    is_active: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)

class PaymentRecord(BaseModel):
    model_config = ConfigDict(extra="ignore")
    
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    company_id: str
    employee_id: str
    amount: float
    token: str
    tx_hash: Optional[str] = None
    status: str = "pending"  # pending, completed, failed
    timestamp: datetime = Field(default_factory=datetime.utcnow)

class CompanyCreate(BaseModel):
    name: str
    email: str
    wallet_address: str

class EmployeeCreate(BaseModel):
    company_id: str
    name: str
    email: str
    wallet_address: str
    position: str
    salary: float
    payment_token: str = "ETH"
