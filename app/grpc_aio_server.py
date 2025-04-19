import asyncio
from concurrent import futures

import grpc

from app.pb import payload_pb2, payload_pb2_grpc

class PayloadServiceImpl(payload_pb2_grpc.PayloadServiceServicer):
    async def GetLargePayload(self, request, context):
        data = b"x" * request.size_in_kb * 1024
        return payload_pb2.PayloadResponse(data=data)

async def serve():
    server = grpc.aio.server(futures.ThreadPoolExecutor(max_workers=10))
    payload_pb2_grpc.add_PayloadServiceServicer_to_server(PayloadServiceImpl(), server)
    server.add_insecure_port('[::]:50052')
    await server.start()
    print("gRPC aio server running on port 50052")
    await server.wait_for_termination()

if __name__ == '__main__':
    asyncio.run(serve())