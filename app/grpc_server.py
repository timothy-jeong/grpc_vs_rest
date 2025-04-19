import grpc
from concurrent import futures
from app.pb import payload_pb2, payload_pb2_grpc

class PayloadServiceImpl(payload_pb2_grpc.PayloadServiceServicer):
    def GetLargePayload(self, request, context):
        data = b"x" * request.size_in_kb * 1024
        return payload_pb2.PayloadResponse(data=data)

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    payload_pb2_grpc.add_PayloadServiceServicer_to_server(PayloadServiceImpl(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    print("gRPC server running on port 50051")
    server.wait_for_termination()

if __name__ == '__main__':
    serve()