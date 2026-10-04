# Windows Server 운영 실습

## 목적
웹 애플리케이션과 DB를 Windows 서버에 배포하고, 서비스와 운영 로그를 확인하는 기본 절차를 익힙니다. 실제 기관 서버가 아니라 개인 VirtualBox 실습 환경입니다.

## 구성
- OS: Windows Server 2022 VM
- Java: Java 11
- WAS: Apache Tomcat 9 Windows Service, TCP 8080
- DB: MySQL 8, TCP 3306
- 애플리케이션: MiniCampusLMS WAR

## 수행 내용
- Windows Server 2022 VM을 구성했습니다.
- Java 11, Tomcat 9 Windows Service, MySQL 8을 설치했습니다.
- MiniCampusLMS WAR를 배포했습니다.
- Tomcat과 MySQL 서비스 상태를 확인했습니다.
- Windows Event Log를 확인했습니다.
- Windows Firewall logging을 활성화하고 로그를 확인했습니다.

## 검증 결과
사용자 제공 실습 결과 기준으로 Tomcat/MySQL 서비스 상태와 Windows Event Log 및 Firewall 로그 확인을 완료했습니다. Service Control Manager 7045(서비스 설치), 7036(서비스 상태 변경), Kernel-Power 41 및 EventLog 6008(비정상 종료 관련)은 확인할 수 있는 이벤트 유형의 예시이며, 각 이벤트가 실습 VM에서 실제 발생했다고 단정하지 않습니다.

## 증빙 파일
현재 이미지나 로그 파일은 저장소에 없습니다. 추후 민감정보 제거 후 추가 예정입니다. 제안 파일명:
- `service-status.png`
- `event-log-tomcat.png`
- `firewall-log.png`

## 의미
Windows 서비스로 WAS와 DB를 실행하고 이벤트 및 방화벽 로그를 확인하는 과정을 보여줍니다. 이는 개인 실습 환경에서의 운영 경험이며 실제 기관 서버 운영 실적은 아닙니다.