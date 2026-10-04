# Windows Firewall 접근 제어 실습

## 목적
Tomcat 포트에 아무 클라이언트나 직접 접근하지 못하게 하고, 앞단 Nginx 서버에서 오는 요청만 허용합니다. 허용·차단 연결 로그를 함께 확인해 정책이 실제 요청 경로에 적용되는지 점검합니다.

## 구성
- Windows Server 2022 Firewall
- Tomcat 9: TCP 8080
- 허용할 Nginx 서버: `192.168.50.20`
- Host PC 포트포워딩 경로: Tomcat 직접 접근 `localhost:18080`, Nginx 경유 `localhost:18081`
- Windows Firewall allowed/dropped connection logging: 활성화
- Firewall 로그 파일: `pfirewall.log`

## 수행 내용
- 기존 MiniCampus Tomcat TCP 8080 전체 허용 규칙을 비활성화했습니다.
- Nginx 서버 `192.168.50.20`에서 오는 TCP 8080 연결만 허용했습니다.
- Host의 Tomcat 직접 접근과 Nginx 경유 접근을 각각 확인했습니다.
- Windows Firewall allowed/dropped connection logging을 활성화했습니다.
- `pfirewall.log`를 확인했습니다.

## 검증 결과
사용자 제공 실습 결과 기준, Tomcat 직접 경로 `localhost:18080`은 실패했고 Nginx 경유 경로 `localhost:18081`은 성공했습니다. Firewall 허용/차단 연결 로깅 활성화와 `pfirewall.log` 확인을 수행했습니다.

## 증빙 파일
현재 이미지나 로그 파일은 저장소에 없습니다. 추후 민감정보 제거 후 추가 예정입니다. 제안 파일명:
- `nginx-only-rule.png`
- `direct-access-blocked.png`
- `nginx-access-success.png`

## 의미
방화벽 규칙으로 서버 포트의 접근 가능한 출발지를 제한하고, 직접 경로와 프록시 경유 경로의 차이를 검증한 실습입니다. 실제 기관 네트워크 정책의 적용을 의미하지 않습니다.