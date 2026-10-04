# MiniCampusLMS 인프라 검증 증빙

## 목적
이 폴더는 MiniCampusLMS를 개인 VirtualBox 환경에 배포하고 운영·보안 항목을 단계별로 확인한 기록을 모으기 위한 안내입니다. 실습에서 확인한 결과와 저장소에 실제 보관된 증빙 파일은 구분합니다.

## 구성
- Windows Server 2022: Tomcat 9와 MySQL 8을 실행하는 애플리케이션 서버
- Ubuntu Server: Nginx Reverse Proxy와 ModSecurity/OWASP CRS
- MiniCampusNet: Windows Server `192.168.50.10`, Ubuntu/Nginx `192.168.50.20`
- DB: MySQL 8, Windows Server VM 안에서 Tomcat과 함께 실행

## 수행 내용

```text
Windows Server 구축
  → DB 백업 및 별도 DB 복구
  → Ubuntu Server / Nginx Reverse Proxy
  → Tomcat 직접 접근 제한
  → Windows Firewall 로그 확인
  → ModSecurity / OWASP CRS 적용
  → SQLi / XSS 패턴 탐지
  → 차단 모드에서 HTTP 403 확인
```

세부 내용:
- [Windows Server 실습](windows-server/README.md)
- [DB 백업 및 복구](db-backup-restore/README.md)
- [Nginx Reverse Proxy](nginx-reverse-proxy/README.md)
- [Windows Firewall 접근 제어](windows-firewall/README.md)
- [Nginx WAF 탐지 및 차단](nginx-waf/README.md)

## 검증 결과
사용자가 실제 VM에서 수행·확인한 결과를 각 문서에 정리했습니다. 정상 요청 HTTP 200, SQLi 차단 HTTP 403, Firewall 접근 경로와 DB 복구 건수 등은 해당 실습 시점의 결과이며, 상시 운영값이나 저장소 안의 로그로 오해하지 않도록 각 페이지에서 상태를 구분합니다.

## 증빙 파일
현재 이 저장소에는 VM 화면 캡처, 로그, 설정 파일, DB 덤프가 없습니다. 대표 스크린샷 파일명만 제안했으며, 실제 파일은 추후 민감정보를 제거한 뒤 추가 예정입니다. DB dump 원본, 쿠키, 세션 ID, 토큰, 비밀번호, VM 이미지와 운영 자격정보는 추가하지 않습니다.

## 의미
애플리케이션 개발에 그치지 않고 서버 배포, DB 복구, 네트워크 경로, 방화벽과 WAF의 동작을 나누어 확인한 개인 실습입니다. 실제 대학·공공기관 운영 서버 구축이나 실서비스 보안 인증을 의미하지 않습니다.