ghz --insecure \
    --proto ./proto/payload.proto \
    --call payload.PayloadService/GetLargePayload \
    -d '{}' \
    -c 40 \
    -n 4000 \
    {ip}:50051
