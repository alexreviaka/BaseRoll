from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import os
from pathlib import Path

# Load environment variables
load_dotenv(Path(__file__).parent / '.env')

app = FastAPI(
    title="BaseRoll API",
    description="Decentralized payroll system on Base blockchain",
    version="0.1.0"
)

# CORS configuration
origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Import and include routers
from routes.companies import router as companies_router
from routes.employees import router as employees_router
from routes.payments import router as payments_router

app.include_router(companies_router)
app.include_router(employees_router)
app.include_router(payments_router)

@app.get("/")
async def root():
    return {
        "name": "BaseRoll API",
        "version": "0.1.0",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
