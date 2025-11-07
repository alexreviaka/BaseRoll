import pytest
from services.batch_payments import BatchPaymentService

@pytest.mark.asyncio
async def test_batch_payment():
    service = BatchPaymentService(None)
    assert service is not None
