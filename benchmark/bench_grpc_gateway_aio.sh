#!/bin/bash

# --- 기본 설정 값 ---
DEFAULT_SIZE_KB="14"
DEFAULT_IP="0.0.0.0"  # 로컬 테스트 기본값 (uvicorn 기본값과 맞춤)
DEFAULT_PORT="8001"  # REST API 서버 포트 (uvicorn 기본값)
DEFAULT_PATH="/payload" # 테스트할 API 경로
DEFAULT_RESULTS_DIR="benchmark/results/grpc_gateway_aio" # 결과 저장 디렉토리
DEFAULT_METHOD="GET" # 기본 HTTP 메서드

# --- 테스트할 파라미터 쌍 (수정 가능) ---
# CONCURRENCY_VALUES 와 TOTAL_VALUES 는 반드시 같은 개수여야 함
CONCURRENCY_VALUES=(50 50 50 100 100 100)
TOTAL_VALUES=(2000 5000 10000 2000 5000 10000)
# --- 스크립트 실행 파라미터 처리 ---
# 사용법: ./benchmark_rest.sh [size_kb] [ip] [port] [results_dir] [api_path] [http_method]
# 예시: ./benchmark_rest.sh 14 15.165.33.135 8000 # size 14KB, 원격 서버 대상
# 예시: ./benchmark_rest.sh 256                            # size 256KB, 나머지 기본값 사용
# 예시: ./benchmark_rest.sh                                # 모든 기본값 사용

SIZE_KB="${1:-$DEFAULT_SIZE_KB}"
TARGET_IP="${2:-$DEFAULT_IP}"
TARGET_PORT="${3:-$DEFAULT_PORT}"
RESULTS_DIR="${4:-$DEFAULT_RESULTS_DIR}"
API_PATH="${5:-$DEFAULT_PATH}"
HTTP_METHOD="${6:-$DEFAULT_METHOD}" # GET, POST, PUT 등

# --- 결과 저장 디렉토리 생성 ---
mkdir -p "$RESULTS_DIR"

# --- 정보 출력 ---
echo "=================================================="
echo "REST API Benchmark Started (Paired Tests)"
echo "=================================================="
echo "Target Server: http://${TARGET_IP}:${TARGET_PORT}"
echo "API Path:      $API_PATH"
echo "HTTP Method:   $HTTP_METHOD"
echo "Query Param:   size_in_kb=$SIZE_KB"
echo "Concurrency (C): ${CONCURRENCY_VALUES[@]}"
echo "Total Requests (N): ${TOTAL_VALUES[@]}"
echo "Results will be saved in: $RESULTS_DIR"
echo "--------------------------------------------------"

# --- 배열 길이 확인 (안전 장치) ---
num_tests=${#CONCURRENCY_VALUES[@]}
if [ "$num_tests" -ne "${#TOTAL_VALUES[@]}" ]; then
  echo "[ERROR] CONCURRENCY_VALUES (${#CONCURRENCY_VALUES[@]} items) and TOTAL_VALUES (${#TOTAL_VALUES[@]} items) arrays must have the same number of elements."
  exit 1
fi
echo "Number of test pairs defined: $num_tests"
echo "--------------------------------------------------"

# --- 벤치마크 루프 실행 (쌍으로 묶어서) ---
for (( i=0; i<num_tests; i++ )); do
  c=${CONCURRENCY_VALUES[$i]}
  n=${TOTAL_VALUES[$i]}

  # 현재 테스트 정보 출력
  echo "Running test pair $((i+1)) / $num_tests : Concurrency=$c, Total=$n"

  # 테스트 대상 URL 생성 (쿼리 파라미터 포함)
  TARGET_URL="http://${TARGET_IP}:${TARGET_PORT}${API_PATH}?size_in_kb=${SIZE_KB}"

  # 결과 파일 이름 생성
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  RESULTS_FILE="${RESULTS_DIR}/rest_sz${SIZE_KB}_c${c}_n${n}_${TIMESTAMP}.txt"

  echo "  -> Targeting URL: $TARGET_URL"
  echo "  -> Saving results to: $RESULTS_FILE"

  # hey 실행 및 결과 파일 저장
  # 참고: POST/PUT 등 다른 메서드 사용 시 -m, -H, -d/-D 옵션 추가 필요
  hey -m "$HTTP_METHOD" \
      -c "$c" \
      -n "$n" \
      "$TARGET_URL" > "$RESULTS_FILE"

  # hey 실행 결과 확인
  if [ $? -ne 0 ]; then
    echo "  [ERROR] hey command failed for C=$c, N=$n. Check log file for details: $RESULTS_FILE"
  else
    # 성공 시, 결과 파일에 테스트 정보 추가 기록
    echo "" >> "$RESULTS_FILE"
    echo "--- Benchmark Parameters ---" >> "$RESULTS_FILE"
    echo "Target URL: $TARGET_URL" >> "$RESULTS_FILE"
    echo "HTTP Method: $HTTP_METHOD" >> "$RESULTS_FILE"
    echo "Concurrency (Client): $c" >> "$RESULTS_FILE"
    echo "Total Requests (N): $n" >> "$RESULTS_FILE"
    echo "Timestamp: $TIMESTAMP" >> "$RESULTS_FILE"
    echo "  [SUCCESS] Test completed for C=$c, N=$n."
  fi
  echo "--------------------------------------------------"
  sleep 5
done

echo "=================================================="
echo "All REST API benchmark runs completed."
echo "Results saved in: $RESULTS_DIR"
echo "=================================================="