from fastapi import Request, status
from fastapi.responses import JSONResponse

async def error_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"message": str(exc)}
    )
