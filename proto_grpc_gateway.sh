#!/bin/bash

PROTO_DEST_DIR=./grpc-gateway/gen/go

set -e

protoc -I. -I./proto -I./proto/google \
    --go_out=$PROTO_DEST_DIR --go_opt=paths=source_relative \
    --go-grpc_out=$PROTO_DEST_DIR --go-grpc_opt=paths=source_relative \
    --grpc-gateway_out=$PROTO_DEST_DIR --grpc-gateway_opt=paths=source_relative \
    --grpc-gateway_opt=generate_unbound_methods=true \
    ./proto/payload/payload.proto