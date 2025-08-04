from fastapi import APIRouter, HTTPException
from typing import List
from models import Company, CompanyCreate
from motor.motor_asyncio import AsyncIOMotorClient
import os

router = APIRouter(prefix="/api/companies", tags=["companies"])

# MongoDB connection
mongo_url = os.environ.get('MONGO_URL', 'mongodb://localhost:27017')
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ.get('DB_NAME', 'baseroll')]

@router.post("/", response_model=Company)
async def create_company(company: CompanyCreate):
    """Register a new company"""
    company_obj = Company(**company.model_dump())
    
    doc = company_obj.model_dump()
    doc['created_at'] = doc['created_at'].isoformat()
    
    result = await db.companies.insert_one(doc)
    return company_obj

@router.get("/", response_model=List[Company])
async def list_companies():
    """Get all companies"""
    companies = await db.companies.find({}, {"_id": 0}).to_list(1000)
    
    for company in companies:
        if isinstance(company.get('created_at'), str):
            from datetime import datetime
            company['created_at'] = datetime.fromisoformat(company['created_at'])
    
    return companies

@router.get("/{company_id}", response_model=Company)
async def get_company(company_id: str):
    """Get company by ID"""
    company = await db.companies.find_one({"id": company_id}, {"_id": 0})
    
    if not company:
        raise HTTPException(status_code=404, detail="Company not found")
    
    if isinstance(company.get('created_at'), str):
        from datetime import datetime
        company['created_at'] = datetime.fromisoformat(company['created_at'])
    
    return company

@router.put("/{company_id}", response_model=Company)
async def update_company(company_id: str, updates: dict):
    """Update company information"""
    result = await db.companies.update_one(
        {"id": company_id},
        {"$set": updates}
    )
    
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Company not found")
    
    return await get_company(company_id)

@router.delete("/{company_id}")
async def delete_company(company_id: str):
    """Delete company"""
    result = await db.companies.delete_one({"id": company_id})
    
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Company not found")
    
    return {"message": "Company deleted successfully"}
