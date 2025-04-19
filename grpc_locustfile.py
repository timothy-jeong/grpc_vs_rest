from locust import User, task, between, events
import grpc
from pb import payload_pb2, payload_pb2_grpc
import time

class GrpcClient:
    def __init__(self):
        self.channel = grpc.insecure_channel("localhost:50051")
        self.stub = payload_pb2_grpc.PayloadServiceStub(self.channel)

    def get_large_payload(self):
        return self.stub.GetLargePayload(payload_pb2.Empty())

class GrpcUser(User):
    wait_time = between(0.01, 0.1)

    def on_start(self):
        self.client = GrpcClient()

    @task
    def grpc_payload(self):
        start_time = time.time()
        try:
            response = self.client.get_large_payload()
            total_time = (time.time() - start_time) * 1000
            events.request.fire(
                request_type="gRPC",
                name="GetLargePayload",
                response_time=total_time,
                response_length=len(response.data),
                exception=None,
            )
        except Exception as e:
            total_time = (time.time() - start_time) * 1000
            events.request.fire(
                request_type="gRPC",
                name="GetLargePayload",
                response_time=total_time,
                response_length=0,
                exception=e,
            )
