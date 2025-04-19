#!/bin/bash

set -e

uv run python -m grpc_tools.protoc \
    -I=./proto \
    --python_out=./app/pb \
    --grpc_python_out=./app/pb \
    ./proto/payload.proto