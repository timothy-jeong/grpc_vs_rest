from locust import HttpUser, task, between

class RestLoadTest(HttpUser):
    wait_time = between(0.01, 0.1)  # 요청 간 간격 짧게

    @task
    def get_large_payload(self):
        self.client.get("/payload")

# 실행 방법 (터미널에서):
# locust -f locustfile.py --headless -u <사용자 수> -r <초당 생성 사용자 수> -t 30s --host=http://localhost:8000
# 예: locust -f locustfile.py --headless -u 10000 -r 100 --host=http://localhost:8000

# 참고:
# -u : 총 요청 수 비슷하게 맞추기 위한 사용자 수
# -r : 초당 생성 사용자 수
# -t : 테스트 지속 시간 (예: 30s, 1m)
