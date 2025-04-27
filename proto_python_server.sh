#!/bin/bash

set -e

uv run python -m grpc_tools.protoc \
    -I. -I./proto -I./proto/google \
    --python_out=./app/pb \
    --grpc_python_out=./app/pb \
    ./proto/payload/payload.proto