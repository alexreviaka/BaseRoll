import asyncio
import aiohttp
import time

async def make_request(session, url):
    async with session.get(url) as response:
        return await response.json()

async def load_test(url, num_requests):
    start_time = time.time()
    
    async with aiohttp.ClientSession() as session:
        tasks = [make_request(session, url) for _ in range(num_requests)]
        responses = await asyncio.gather(*tasks)
    
    end_time = time.time()
    duration = end_time - start_time
    
    print(f"Completed {num_requests} requests in {duration:.2f}s")
    print(f"Average: {duration/num_requests:.4f}s per request")
    print(f"RPS: {num_requests/duration:.2f}")

if __name__ == "__main__":
    asyncio.run(load_test("http://localhost:8000/health", 1000))
