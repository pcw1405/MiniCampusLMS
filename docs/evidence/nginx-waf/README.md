# ModSecurity 및 OWASP CRS WAF 실습

## 목적
웹 요청을 검사해 SQL Injection이나 XSS와 비슷한 공격 패턴을 탐지하고, 차단 모드에서 요청을 막을 수 있는지 확인합니다. 이는 공격 성공이 아니라 WAF의 공격 패턴 탐지·차단 검증입니다.

## 구성
- Ubuntu Server VM의 Nginx Reverse Proxy
- ModSecurity v3
- OWASP Core Rule Set 3.3.8
- Nginx에서 Tomcat 9 / MiniCampusLMS로 요청 전달

## 수행 내용
- ModSecurity v3와 OWASP CRS 3.3.8을 적용했습니다.
- 약 924개 로컬 규칙이 로드되는지 확인했습니다.
- DetectionOnly 모드에서 정상 요청과 SQLi/XSS 형태 요청을 검사했습니다.
- ModSecurity audit log를 확인했습니다.
- `SecRuleEngine On`으로 전환해 SQLi 형태 요청의 차단을 확인했습니다.

## 검증 결과
사용자 제공 실습 결과 기준:

| 테스트 | 확인 결과 |
| :--- | :--- |
| DetectionOnly 정상 요청 | HTTP 200 유지 |
| SQL Injection 형태 요청 | CRS Rule 942100 탐지, Anomaly Score 5 |
| XSS 형태 요청 | CRS Rule 941100, 941110, 941160 탐지, Anomaly Score 15 |
| ModSecurity audit log | 생성 및 확인 |
| 차단 모드 SQL Injection 형태 요청 | HTTP 403 차단 |
| 차단 모드 정상 요청 | HTTP 200 유지 |

## 증빙 파일
현재 이미지나 로그 파일은 저장소에 없습니다. 추후 민감정보 제거 후 추가 예정입니다. 제안 파일명:
- `crs-rules-loaded.png`
- `sqli-942100-detection.png`
- `xss-941100-detection.png`
- `sqli-403-block.png`

## 의미
DetectionOnly로 규칙이 어떤 요청을 탐지하는지 먼저 확인한 뒤 차단 모드의 응답을 검증한 실습입니다. SQLi/XSS 형태의 테스트 요청은 실제 취약점 공격 성공을 의미하지 않으며, audit log와 규칙 ID를 바탕으로 탐지 결과를 설명할 수 있습니다.