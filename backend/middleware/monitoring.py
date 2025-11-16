from fastapi import Request
import time
import logging

logger = logging.getLogger(__name__)

async def performance_monitor(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    
    logger.info(f"{request.method} {request.url.path} - {process_time:.2f}s")
    response.headers["X-Process-Time"] = str(process_time)
    
    return response
