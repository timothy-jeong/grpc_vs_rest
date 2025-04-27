package main

import (
	"context"
	"log"
	"net/http"

	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"github.com/timothy-jeong/grpc_vs_rest/gen/go/proto/payload"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

const (
	httpPort             = ":8001" // Gateway가 리스닝할 HTTP 포트
	pythonGrpcServerAddr = "localhost:50051"
)

func main() {
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	mux := runtime.NewServeMux()
	opts := []grpc.DialOption{grpc.WithTransportCredentials(insecure.NewCredentials())} // 개발용 insecure

	// 생성된 핸들러 등록 - Python gRPC 서버로 연결되도록 설정
	err := payload.RegisterPayloadServiceHandlerFromEndpoint(ctx, mux, pythonGrpcServerAddr, opts) // 서비스 이름 확인 필요
	if err != nil {
		log.Fatalf("Failed to register gateway handler: %v", err)
	}

	log.Printf("HTTP Gateway server listening at %s", httpPort)
	log.Printf("Proxying requests to Python gRPC server at %s", pythonGrpcServerAddr)

	if err := http.ListenAndServe(httpPort, mux); err != nil {
		log.Fatalf("Failed to serve HTTP gateway: %v", err)
	}
}
