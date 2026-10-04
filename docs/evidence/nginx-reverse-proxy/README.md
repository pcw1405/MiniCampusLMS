# Nginx Reverse Proxy 실습

## 목적
사용자가 Tomcat에 직접 접근하는 대신 Nginx를 앞단에 두고 요청을 전달하는 구성을 확인합니다. Nginx와 애플리케이션 서버의 역할을 분리해 요청 경로와 접근 통제를 점검합니다.

## 구성
- Host PC → Ubuntu Server VM의 Nginx
- Ubuntu/Nginx 내부망 주소: `192.168.50.20`
- MiniCampusNet을 통한 Windows Server 주소: `192.168.50.10`
- Windows Server의 Tomcat 9: TCP 8080
- MySQL 8: Tomcat과 같은 Windows Server VM

```text
Host PC
  → Ubuntu Server / Nginx
  → MiniCampusNet
  → Windows Server / Tomcat 8080
  → MiniCampusLMS
  → MySQL 8 (Windows Server 내)
```

## 수행 내용
- Ubuntu Server VM에 NAT NIC와 MiniCampusNet 내부 NIC를 구성했습니다.
- Nginx를 설치하고 Reverse Proxy로 Tomcat에 요청을 전달하도록 구성했습니다.
- Ubuntu에서 Windows Tomcat으로 HTTP 요청을 보냈습니다.
- Host PC에서 포트포워딩을 통해 Nginx 경유 LMS에 접근했습니다.
- Nginx Access Log를 확인했습니다.

## 검증 결과
사용자 제공 실습 결과 기준:
- Ubuntu → Windows Tomcat HTTP 요청 성공
- `nginx -t` 설정 검사 성공
- Nginx Reverse Proxy 경유 LMS 응답 HTTP 200
- Host PC의 `localhost:18081` 경유 LMS 정상 접근
- Nginx Access Log 확인

## 증빙 파일
현재 이미지나 로그 파일은 저장소에 없습니다. 추후 민감정보 제거 후 추가 예정입니다. 제안 파일명:
- `nginx-test-success.png`
- `reverse-proxy-http200.png`
- `nginx-access-log.png`

## 의미
Reverse Proxy를 이용해 앞단 프록시와 뒤쪽 애플리케이션 서버를 연결하고, 내부망 요청과 사용자 접근 경로를 확인한 실습입니다. MySQL은 별도 DB 서버가 아니라 Tomcat과 같은 Windows Server VM에서 실행됩니다.