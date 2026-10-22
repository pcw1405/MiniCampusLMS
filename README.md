# MiniCampusLMS

대학·공공기관 전산직 포트폴리오를 위한 개인 실습 프로젝트입니다. 수강신청 중심의 미니 학사정보시스템을 JSP/JDBC로 개발하고, 개인 VirtualBox 환경에 배포해 DB, 서버 운영, 네트워크 접근제어와 웹 보안 실습까지 진행합니다.

기능을 많이 나열하는 것보다 업무용 웹 애플리케이션이 실제 서버에서 어떻게 배포되고, 연결되고, 점검되는지를 단계별로 확인하는 데 초점을 둡니다.

## 시스템 구성

```text
사용자 / Host PC
       |
       v
Ubuntu Server VM
Nginx Reverse Proxy
ModSecurity v3 + OWASP CRS
       |
       | MiniCampusNet 내부망
       | Ubuntu: 192.168.50.20
       | TCP 8080 접근 허용 대상
       v
Windows Server 2022 VM
Tomcat 9 (MiniCampusLMS WAR)
MySQL 8 (Tomcat과 같은 VM)
       |
       v
애플리케이션 전용 DB 계정
```

Nginx Reverse Proxy는 사용자 요청을 먼저 받아 내부 Tomcat으로 전달합니다. Windows Firewall은 Tomcat TCP 8080을 Nginx 서버에서 오는 연결로 제한했습니다. 이 구성은 VirtualBox 개인 실습 환경이며 실제 기관의 운영망이 아닙니다.

## 구현 기능

- Java 11, JSP, JDBC 기반 웹 애플리케이션과 환경변수 기반 DB 연결
- 세션 기반 로그인·로그아웃과 `ADMIN` / `STUDENT` 역할 확인
- 공지사항 작성, 조회, 수정, 삭제 및 목록 검색
- 관리자 과목 등록, 개설강좌 등록·수정·상태 변경, 수강생 조회
- 학생의 2026년 1학기 개설강좌 조회 및 수강신청
- 신청 시 학생 권한, 개설강좌 `OPEN` 상태, 정원, 동일 개설강좌 중복을 확인
- 학생 본인의 수강내역 조회와 본인 enrollment 소유권을 확인하는 수강취소
- 수강취소 시 행을 삭제하지 않고 `status = 'CANCELED'`, `canceled_at = NOW()`로 이력 유지
- 보안 실습용 공지 검색 페이지를 안전 버전과 의도적 취약 버전으로 분리

수강신청은 동일 학생의 동일 개설강좌 중복과 정원 초과를 검사합니다. 개설강좌 행 잠금과 트랜잭션을 적용해 동시 신청을 처리합니다. 시간표 충돌이나 같은 과목의 다른 분반 신청 여부는 현재 확인 로직에 포함되어 있지 않습니다.

### 수강신청 동시성 검증

로컬 Eclipse/Tomcat 환경에서 `section_id=12`, `capacity=1`, 서로 다른 학생 4명, JMeter Thread 4 및 Synchronizing Timer 4 조건으로 검증했습니다. 개선 전에는 8건 요청에서 오류 없이 처리됐지만 `ENROLLED=4`가 되어 정원 초과가 재현됐습니다. `studentCourseEnrollAction.jsp`에 JDBC 트랜잭션과 `SELECT ... FOR UPDATE`를 적용한 뒤 동일 조건에서 8건 요청 오류 0건, 최종 `ENROLLED=1`을 확인했습니다. Windows Server에 최신 WAR를 재배포한 결과는 아직 검증되지 않았습니다.

## DB 설계

`database/schema.sql`은 새 테스트 DB를 위한 8개 테이블의 목표 스키마입니다: `users`, `notice`, `security_test_log`, `students`, `courses`, `semesters`, `course_sections`, `enrollments`. PK, FK, UNIQUE, CHECK 제약조건을 사용합니다. 이 스키마 파일은 현재 운영 DB에 적용된 구조를 보장하지 않으며, 기존 DB에 검토 없이 실행하지 마세요.

`database/seed.example.sql`은 공개용 예시 데이터입니다. 실제 계정이나 운영 자격정보가 아니며, 현재 애플리케이션의 비밀번호 비교 방식에 맞춘 placeholder를 사용합니다. 격리된 테스트 DB에서만 사용하고 실제 환경의 비밀번호로 재사용하지 마세요. 로컬 `database/seed.sql`은 저장소에서 제외합니다.

## 운영 및 인프라 검증

| 영역 | 실제 실습에서 확인한 내용 |
| :--- | :--- |
| Windows Server | Windows Server 2022 VM에 Java 11, Tomcat 9 Windows Service, MySQL 8 설치 및 기존 WAR 배포 확인. 동시성 개선을 포함한 최신 WAR 재배포는 미완료 |
| DB 운영 | 애플리케이션 전용 계정과 SELECT/INSERT/UPDATE/DELETE 최소 권한, 시스템 환경변수로 DB 접속정보 분리 |
| 백업·복구 | `mysqldump` 백업을 별도 Recovery DB에 복원하고 테이블·데이터 건수 확인 |
| 로그 | Windows Event Log, Windows Firewall Log, Nginx Access Log 확인 |
| 네트워크 | VirtualBox NAT 포트포워딩과 Ubuntu·Windows VM 사이 MiniCampusNet 통신 확인 |
| Reverse Proxy | Host PC → Nginx → Tomcat → MiniCampusLMS 요청 경로 정상 확인 |
| Firewall | Host의 Tomcat 직접 접근은 실패하고 Nginx 경유 LMS 접근은 성공하는지 확인 |

## 보안 검증

WAF는 웹 요청에서 공격 형태를 탐지하거나 차단하는 방어 계층입니다. 아래 결과는 개인 실습 VM에서 확인했습니다.

| 검증 | 확인 결과 |
| :--- | :--- |
| DetectionOnly 상태의 정상 LMS 요청 | HTTP 200 유지 |
| SQL Injection 형태 요청 | OWASP CRS Rule 942100 탐지 |
| XSS 형태 요청 | CRS Rule 941100, 941110, 941160 탐지 |
| ModSecurity audit log | 생성 및 확인 |
| 차단 모드의 SQL Injection 형태 요청 | HTTP 403 차단 |
| 차단 모드의 정상 LMS 요청 | HTTP 200 유지 |

ModSecurity v3와 OWASP Core Rule Set(CRS)을 설치했고, 약 924개의 로컬 규칙이 로드되는 것을 확인했습니다. 실제 VM 설정·로그·화면 캡처는 아직 저장소에 포함하지 않았습니다.

## 기술 스택

| 구분 | 기술 |
| :--- | :--- |
| Application | Java 11, JSP, JDBC, Apache Tomcat 9 |
| Database | MySQL 8, MySQL Connector/J 8.2.0 |
| Server | Windows Server 2022, Ubuntu Server |
| Proxy / Network | Nginx Reverse Proxy, VirtualBox NAT, MiniCampusNet |
| Security | Windows Firewall, ModSecurity v3, OWASP CRS |
| Project format | Eclipse Dynamic Web Project |

## 프로젝트 문서

- [PROJECT.md](PROJECT.md): 프로젝트 목표와 애플리케이션 MVP 범위
- [DB_DESIGN.md](DB_DESIGN.md): 학사 DB 모델과 설계 의도
- [OPERATIONS.md](OPERATIONS.md): VM 운영, 로그, 백업·복구, Firewall 및 WAF 실습 기록
- [database/schema.sql](database/schema.sql): 신규 테스트 DB용 목표 스키마
- [database/seed.example.sql](database/seed.example.sql): 공개용 예시 테스트 데이터

## 향후 개선

- 취소 후 같은 분반 재신청
- 같은 과목의 다른 분반 중복 검사와 시간표 충돌 검사
- Splunk 통합 로그 수집, 대시보드와 Alert
- 예약 백업 및 보관주기 정책
- 별도 DB 서버 분리, HTTPS/TLS 최종 구성, IDS/IPS 및 DLP 실습

## 주의사항

- 이 프로젝트는 개인 VirtualBox 실습 환경이며, 완성된 실서비스나 완벽한 보안을 의미하지 않습니다.
- 실제 자격정보, 세션 쿠키, DB dump, VM 이미지와 운영 로그는 저장소에 포함하지 않습니다.
- `noticeSearch_vuln.jsp`는 취약점 재현을 위한 의도적 실습 코드입니다. 외부에 공개된 서비스에서 실행하지 마세요.
- GitHub 저장소에는 인프라 증빙 자료가 아직 정리되어 있지 않습니다. 운영 결과와 저장소에서 직접 확인할 수 있는 자료를 구분해 주세요.