#!/bin/bash

# --- 기본 설정 값 ---
DEFAULT_SIZE_KB="14"
DEFAULT_IP="0.0.0.0" # 로컬 테스트 기본값, EC2 IP 등으로 변경 필요 시 파라미터 사용
DEFAULT_PORT="50051"
DEFAULT_PROTO_PATH="./proto/payload/payload.proto" # proto 파일 상대 경로 (스크립트 실행 위치 기준)
DEFAULT_RESULTS_DIR="benchmark/results/grpc" # 결과 저장 디렉토리

# --- 테스트할 파라미터 목록 (수정 가능) ---
CONCURRENCY_VALUES=(50 50 50 100 100 100)
TOTAL_VALUES=(2000 5000 10000 2000 5000 10000)

# --- 스크립트 실행 파라미터 처리 ---
# 사용법: ./benchmark_grpc.sh [size_kb] [ip] [port] [proto_path] [results_dir]
# 예시: ./benchmark_grpc.sh 14 15.165.33.135 50052 # size 14KB, 원격 서버 대상
# 예시: ./benchmark_grpc.sh 256                            # size 256KB, 나머지 기본값 사용
# 예시: ./benchmark_grpc.sh                                # 모든 기본값 사용

SIZE_KB="${1:-$DEFAULT_SIZE_KB}"
TARGET_IP="${2:-$DEFAULT_IP}"
TARGET_PORT="${3:-$DEFAULT_PORT}"
PROTO_PATH="${4:-$DEFAULT_PROTO_PATH}"
RESULTS_DIR="${5:-$DEFAULT_RESULTS_DIR}"

TARGET_ADDR="${TARGET_IP}:${TARGET_PORT}"

# --- 결과 저장 디렉토리 생성 ---
mkdir -p "$RESULTS_DIR"

# --- JSON 데이터 생성 ---
# size_in_kb 값을 파라미터로 받아 동적으로 생성
JSON_DATA=$(printf '{"size_in_kb": "%s"}' "$SIZE_KB")

# --- 정보 출력 ---
echo "=================================================="
echo "gRPC Benchmark Started"
echo "=================================================="
echo "Target Server: $TARGET_ADDR"
echo "Proto File:    $PROTO_PATH"
echo "Payload Size:  ${SIZE_KB} KB (approx, based on input)"
echo "Concurrency (C): ${CONCURRENCY_VALUES[@]}"
echo "Total Requests (N): ${TOTAL_VALUES[@]}"
echo "Results will be saved in: $RESULTS_DIR"
echo "--------------------------------------------------"

num_tests=${#CONCURRENCY_VALUES[@]}

# (선택 사항) 두 배열의 길이가 같은지 확인
if [ ${#CONCURRENCY_VALUES[@]} -ne ${#TOTAL_VALUES[@]} ]; then
  echo "[ERROR] CONCURRENCY_VALUES and TOTAL_VALUES arrays must have the same number of elements."
  exit 1
fi

# --- 벤치마크 루프 실행 ---
for (( i=0; i<num_tests; i++ )); do
  c=${CONCURRENCY_VALUES[$i]}
  n=${TOTAL_VALUES[$i]}
  echo "Running: Concurrency=$c, Total=$n"

  # 결과 파일 이름 생성 (타임스탬프 포함하여 중복 방지)
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  RESULTS_FILE="${RESULTS_DIR}/grpc_${TIMESTAMP}_sz${SIZE_KB}_c${c}_n${n}.txt"

  echo "  -> Saving results to: $RESULTS_FILE"

  # ghz 실행 및 결과 파일 저장
  # --format summary : 최종 요약 결과만 출력 (원하는 포맷으로 변경 가능)
  ghz --insecure \
      --import-paths="./proto" \
      --proto "$PROTO_PATH" \
      --call payload.PayloadService/GetLargePayload \
      --data "$JSON_DATA" \
      --format summary \
      --concurrency "$c" \
      --total "$n" \
      "$TARGET_ADDR" > "$RESULTS_FILE"

  # ghz 실행 결과 확인 (오류 시 메시지 출력)
  if [ $? -ne 0 ]; then
    echo "  [ERROR] ghz command failed for C=$c, N=$n. Check log file for details: $RESULTS_FILE"
  else
    # 성공 시, 결과 파일에 테스트 정보 추가 기록 (선택 사항)
    echo "" >> "$RESULTS_FILE" # 빈 줄 추가
    echo "--- Benchmark Parameters ---" >> "$RESULTS_FILE"
    echo "Target: $TARGET_ADDR" >> "$RESULTS_FILE"
    echo "Payload Size (KB Input): $SIZE_KB" >> "$RESULTS_FILE"
    echo "Concurrency (Client): $c" >> "$RESULTS_FILE"
    echo "Total Requests (N): $n" >> "$RESULTS_FILE"
    echo "Timestamp: $TIMESTAMP" >> "$RESULTS_FILE"
    echo "  [SUCCESS] Test completed for C=$c, N=$n."
  fi
  echo "--------------------------------------------------"
  # 테스트 사이에 약간의 지연 시간 추가 (선택 사항)
  sleep 5
done

echo "=================================================="
echo "All gRPC benchmark runs completed."
echo "Results saved in: $RESULTS_DIR"
echo "=================================================="