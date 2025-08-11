# BaseRoll Backend API

FastAPI backend for BaseRoll payroll system with Base blockchain integration.

## Features

- Company and employee management
- Payment processing via smart contracts
- Web3 integration with Base network
- MongoDB for data persistence
- RESTful API endpoints

## Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your settings

# Run server
python main.py
```

## API Endpoints

### Companies
- `POST /api/companies/` - Create company
- `GET /api/companies/` - List all companies
- `GET /api/companies/{id}` - Get company details
- `PUT /api/companies/{id}` - Update company
- `DELETE /api/companies/{id}` - Delete company

### Employees
- `POST /api/employees/` - Add employee
- `GET /api/employees/company/{company_id}` - List company employees
- `GET /api/employees/{id}` - Get employee details
- `PUT /api/employees/{id}` - Update employee
- `DELETE /api/employees/{id}` - Deactivate employee

### Payments
- `POST /api/payments/process` - Process payment
- `GET /api/payments/company/{company_id}` - Company payment history
- `GET /api/payments/employee/{employee_id}` - Employee payment history
- `GET /api/payments/{id}` - Payment details

## Development

```bash
# Run with auto-reload
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Run tests
pytest
```

## Environment Variables

See `.env.example` for required configuration.
