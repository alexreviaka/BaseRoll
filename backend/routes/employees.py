from fastapi import APIRouter, HTTPException
from typing import List
from models import Employee, EmployeeCreate
from motor.motor_asyncio import AsyncIOMotorClient
import os

router = APIRouter(prefix="/api/employees", tags=["employees"])

mongo_url = os.environ.get('MONGO_URL', 'mongodb://localhost:27017')
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ.get('DB_NAME', 'baseroll')]

@router.post("/", response_model=Employee)
async def create_employee(employee: EmployeeCreate):
    """Add a new employee"""
    employee_obj = Employee(**employee.model_dump())
    
    doc = employee_obj.model_dump()
    doc['created_at'] = doc['created_at'].isoformat()
    
    result = await db.employees.insert_one(doc)
    return employee_obj

@router.get("/company/{company_id}", response_model=List[Employee])
async def list_company_employees(company_id: str):
    """Get all employees of a company"""
    employees = await db.employees.find(
        {"company_id": company_id},
        {"_id": 0}
    ).to_list(1000)
    
    for employee in employees:
        if isinstance(employee.get('created_at'), str):
            from datetime import datetime
            employee['created_at'] = datetime.fromisoformat(employee['created_at'])
    
    return employees

@router.get("/{employee_id}", response_model=Employee)
async def get_employee(employee_id: str):
    """Get employee by ID"""
    employee = await db.employees.find_one({"id": employee_id}, {"_id": 0})
    
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")
    
    if isinstance(employee.get('created_at'), str):
        from datetime import datetime
        employee['created_at'] = datetime.fromisoformat(employee['created_at'])
    
    return employee

@router.put("/{employee_id}", response_model=Employee)
async def update_employee(employee_id: str, updates: dict):
    """Update employee information"""
    result = await db.employees.update_one(
        {"id": employee_id},
        {"$set": updates}
    )
    
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Employee not found")
    
    return await get_employee(employee_id)

@router.delete("/{employee_id}")
async def delete_employee(employee_id: str):
    """Remove employee"""
    result = await db.employees.update_one(
        {"id": employee_id},
        {"$set": {"is_active": False}}
    )
    
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Employee not found")
    
    return {"message": "Employee deactivated successfully"}
