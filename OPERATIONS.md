# MiniCampusLMS 운영 매뉴얼 (OPERATIONS.md)

## 1. 문서 목적 및 범위
본 문서는 MiniCampusLMS의 실제 실습 환경, 확인한 운영 점검 결과, 장애 대응 절차와 남은 계획을 정리한다.

> **운영 원칙**
> - **[완료]**로 표시한 항목은 실제 VM 환경에서 수행하고 검증한 실습이다.
> - **[현재 상태]**에는 저장소에 포함된 구현과 증빙 자료의 유무를 구분해 적는다.
> - **[향후 계획]**은 아직 수행하지 않은 작업이다.
> - GitHub 저장소에는 현재 VM 설정 파일, 로그, 백업 파일 등 운영 증빙이 포함되어 있지 않다. 증빙은 민감정보를 제거해 별도 정리할 예정이다.

---

## 2. 현재 실행 환경 (Current Baseline)
### [완료] Windows Server 2022

| 항목 | 검증 결과 |
| :--- | :--- |
| 운영체제 | Windows Server 2022 VM 구축 |
| Java / WAS | Java 11, Apache Tomcat 9 설치 및 Windows Service 등록 |
| 데이터베이스 | MySQL 8 설치, 애플리케이션 WAR 배포 |
| 애플리케이션 확인 | 학생 로그인과 수강신청 동작 확인 |
| DB 권한 | 애플리케이션 전용 계정에 SELECT, INSERT, UPDATE, DELETE 권한 적용 |
| 접속 정보 | Windows 시스템 환경변수로 분리 |
| 가상 네트워크 | VirtualBox NAT 포트포워딩을 통해 호스트 PC 접근 확인 |
| 운영 점검 | Tomcat/MySQL 서비스 상태, Windows Event Log, Windows Firewall 로그 활성화 및 확인 |
| 백업/복구 | `mysqldump` 백업 후 별도 recovery DB에 복원하고 테이블·데이터 건수 확인 |

### [완료] Ubuntu Server 및 Nginx

Ubuntu Server VM에 NAT NIC와 MiniCampusNet 내부 NIC를 구성했다. 내부 통신 주소는 Windows Server `192.168.50.10`, Ubuntu/Nginx `192.168.50.20`이다.

Nginx Reverse Proxy는 사용자가 Tomcat에 직접 접속하지 않고 Nginx를 거쳐 서비스에 접근하도록 요청을 전달한다. Ubuntu에서 Windows Tomcat으로의 HTTP 접근, Nginx에서 Tomcat을 거쳐 MiniCampusLMS에 이르는 경로, 호스트 PC에서 Nginx를 통한 LMS 접근을 확인했다. Nginx Access Log도 확인했다.

### [현재 상태]

실습 결과는 실제 VM 환경에서 검증했다. 다만 Nginx 설정, Windows Firewall 규칙, 로그와 화면 캡처 등 증빙 자료는 아직 GitHub 저장소에 포함하지 않았다.

---

## 3. 현재 서비스 기동 및 처리 흐름
확인한 요청 경로는 다음과 같다.

```text
[ 호스트 PC / 사용자 브라우저 ]
   │ HTTP 요청
        ▼
[ Ubuntu Server: Nginx 192.168.50.20 ]
   │ Reverse Proxy가 요청 전달
   ▼
[ Windows Server: Tomcat 9, TCP 8080 ]
   │ JSP 실행 및 세션 기반 로그인/권한 확인
        ▼
[ MiniCampusLMS / util.DBUtil ]
   │ Windows 시스템 환경변수에서 DB 연결 설정 읽기
        ▼
[ Windows Server의 MySQL 8 ]
   │ JDBC SQL 요청
        ▼
[ JSP 응답을 Nginx를 거쳐 브라우저에 반환 ]
```

VirtualBox NAT 포트포워딩은 호스트 PC에서 실습 VM에 접근할 때 사용한다. Tomcat 직접 접근은 별도의 Windows Firewall 규칙으로 제한한다(9장).

---

## 4. 주요 환경변수 관리 기준
DB 연결 값은 소스에 넣지 않는다. `src/main/java/util/DBUtil.java`는 아래 Windows 시스템 환경변수를 읽는다. 값 자체는 이 문서나 Git에 기록하지 않는다.

### 4.1 필수 환경변수 목록
| 환경변수명 | 필수 여부 | 설명 |
| :--- | :---: | :--- |
| `MINICAMPUS_DB_URL` | 필수 | 환경별 MySQL JDBC 접속 주소 |
| `MINICAMPUS_DB_USER` | 필수 | 애플리케이션 전용 DB 계정 |
| `MINICAMPUS_DB_PASSWORD` | 필수 | 해당 계정의 비밀번호 |

### 4.2 환경변수 설정 및 보안 규칙
- **하드코딩 금지**: 소스코드, JSP, XML 설정 파일 내에 DB 계정/암호를 절대 직접 입력하지 않는다.
- **환경변수 누락 시 동작**: `DBUtil` 초기화 중 필수 값이 없으면 `IllegalStateException`이 발생한다. 실제 서비스 영향은 해당 배포 환경에서 별도로 확인한다.
- **형상관리 제외**: 비밀번호가 노출될 수 있는 `.env`, 배치 파일, 설정 덤프는 `.gitignore`에 등록하여 Git 커밋을 원천 차단한다.
- **주입 방식**:
   - 현재 실습 VM: Windows 시스템 환경변수로 관리하고 Tomcat 서비스에 적용.
   - 환경변수 값과 서비스 설정 화면은 비밀값을 가린 뒤에만 증빙으로 공유.

---

## 5. 기본 운영 점검 절차 (Daily Operational Checklist)
실습 환경을 시작하거나 변경한 뒤 다음 항목을 확인한다.

### 5.1 DB 연결성 점검
1. Tomcat 구동 후 브라우저에서 `dbTest.jsp` 또는 `login.jsp`를 호출한다.
2. HTTP 500 에러 또는 `IllegalStateException: 필수 환경 변수가 없습니다` 발생 여부를 확인한다.
3. MySQL 서버(포트 3306) 프로세스 활성 상태 및 접근 권한을 확인한다.

### 5.2 계정 및 인증/권한 점검
1. **관리자 로그인**: 준비된 관리자 테스트 계정으로 관리자 강좌 목록에 진입되는지 확인.
2. **학생 로그인**: 준비된 학생 테스트 계정으로 강좌 목록에 진입되는지 확인.
3. **접근 제어 검증**: 로그아웃 상태에서 관리자 URL 직접 호출 시 로그인 페이지로 강제 리다이렉트되는지 점검.

### 5.3 핵심 서비스 페이지 점검
| 점검 페이지 | 주요 확인 내용 | 정상 판정 기준 |
| :--- | :--- | :--- |
| `login.jsp` | 로그인 폼 로딩 및 자바스크립트 유효성 | 폼 로딩 및 오류 메시지 미출력 |
| `main.jsp` | 메인 대시보드 레이아웃 및 세션 정보 표기 | 로그인 사용자 이름/권한 정상 표기 |
| `noticeList.jsp` | 공지사항 목록 DB 조회 | 게시글 목록 테이블 정상 렌더링 |
| `studentCourseList.jsp`| 개설 강좌 목록 조회 및 신청 상태 표기 | 잔여 정원, 요일/시간 정보 정상 출력 |
| `adminCourseList.jsp` | 강좌 관리 및 수강생 현황 조회 | 개설 분반 목록 및 관리 액션 버튼 활성화 |

### 5.4 데이터 정합성 점검 (Data Integrity)
- `users` 테이블과 `students` 테이블의 1:1 관계 누락 여부 확인 (`user_id` 외래키 점검).
- `course_sections`의 현재 신청 인원과 `enrollments` 테이블의 `status = 'ENROLLED'` 카운트 간 일치 여부 확인.

---

## 6. 로그 확인 위치 및 분석 방법
실습 중 확인한 로그는 Windows Server의 Event Log와 Firewall 로그, Ubuntu/Nginx의 Access Log, ModSecurity audit log다. 실제 파일 경로와 캡처는 GitHub 저장소에 아직 포함하지 않았다. 경로는 각 VM의 실제 설정에서 확인한다.

### 6.1 개발 및 실습 VM 로그
- Eclipse WTP를 사용할 때는 Eclipse `Console View`에서 로컬 Tomcat 출력과 오류를 확인한다.
- 운영 실습 VM에서는 Windows Event Viewer와 Firewall 로그, Nginx Access Log, ModSecurity audit log를 확인한다.

### 6.2 로그에서 확인할 내용
- 요청 시간과 HTTP 응답 코드
- Tomcat/MySQL 서비스 상태와 애플리케이션 오류
- 방화벽에서 허용·차단된 연결
- ModSecurity 탐지 규칙 ID와 차단 결과

### 6.3 로그 분석 시 핵심 확인 사항
- `java.lang.IllegalStateException`: 필수 DB 환경변수 설정을 확인한다.
- `java.sql.SQLException`: DB 서비스, 네트워크와 권한을 확인한다. 비밀번호나 연결 문자열은 로그·보고서에 복사하지 않는다.
- SQL 제약조건 오류는 애플리케이션 검증 결과와 구분해 조사한다.
- 로그나 캡처를 공개할 때 쿠키, 토큰, 사용자 개인정보와 연결 비밀값을 제거한다.

---

## 7. 장애 발생 시 표준 점검 프로세스 (Incident Handling)
서비스 장애 발생 시 다음 6단계 절차에 따라 체계적으로 대응한다.

```text
[1단계: 현상 파악] ──> [2단계: WAS 점검] ──> [3단계: DB 점검]
         │
         ▼
[4단계: 환경변수] ──> [5단계: 로그 추적] ──> [6단계: 복구 & 검증]
```

1. **1단계: 현상 파악 및 장애 범위 식별**
   - 브라우저 HTTP 응답 코드 확인 (`404 Not Found`, `500 Internal Server Error`, `Connection Refused` 등).
   - 특정 기능(예: 수강신청) 장애인지, 시스템 전체(로그인 불가) 장애인지 확인.
2. **2단계: Tomcat WAS 프로세스 점검**
   - Tomcat 프로세스 생존 여부 및 8080 포트 리스닝 상태 확인.
   - 서버 리소스(CPU, Memory) 고갈 여부 확인.
3. **3단계: MySQL DB 인스턴스 점검**
   - MySQL 8 서비스 동작 여부 및 3306 포트 확인.
   - 테이블 락(Lock), 권한 문제, UNIQUE/FK 제약 조건 위반 여부 점검.
4. **4단계: 환경변수 및 네트워크 점검**
   - WAS 기동 계정의 `MINICAMPUS_DB_*` 환경변수 주입 상태 확인.
   - DB 방화벽/포트 허용 상태 점검.
5. **5단계: 에러 로그 상세 추적**
   - Windows Event Log, Tomcat 출력, Nginx 및 ModSecurity 로그의 발생 시각을 대조.
   - 최근 수정된 JSP 파일 또는 배포된 class 파일의 변경 이력 대조.
6. **6단계: 원인 조치 및 정상화 검증**
   - 원인 해결 후 Tomcat 재기동.
   - 기본 점검 체크리스트(5번 항목)를 수행하여 전체 서비스 정상 동작 최종 검증.

---

## 8. MySQL 백업 및 복구 (Backup & Recovery)
### [완료] 수동 백업 및 별도 DB 복구 검증

`mysqldump`로 DB를 백업한 뒤 운영 DB와 분리된 recovery DB에 복원했다. 복원한 테이블과 데이터 건수를 확인했다. 백업 파일은 Git 저장소 밖에 보관한다.

### 8.1 백업 기준과 현재 상태

- 백업 방식: MySQL `mysqldump` 논리 백업
- 복구 검증: 별도 recovery DB에 restore 후 테이블·데이터 건수 확인
- 백업 파일과 실제 데이터 덤프는 Git에 올리지 않는다.

### 8.2 복구 검증
이번 실습에서 백업과 별도 DB 복구 및 건수 확인을 완료했다. 명령 실행 계정과 파일 경로 등 민감하거나 환경별인 값은 저장소 문서에 기록하지 않는다.

### [향후 계획]

- 예약 백업 자동화와 백업 보관주기 정책 수립
- 복구 절차를 반복 실행하고 결과를 비밀정보 없이 증빙으로 정리

---

## 9. [완료] Windows Server 2022 Phase 1
### [완료] Windows Server 2022 운영 실습

### 9.1 설치 및 운영 확인
- Windows Server 2022 VM에 Java 11, Tomcat 9 Windows Service, MySQL 8 설치
- MiniCampusLMS WAR 배포 및 학생 로그인/수강신청 확인
- 애플리케이션 전용 계정 사용, SELECT/INSERT/UPDATE/DELETE 최소 권한 적용
- DB 연결 값을 Windows 시스템 환경변수로 분리
- Tomcat/MySQL 서비스, Windows Event Log와 Firewall 로그 확인
- VirtualBox NAT 포트포워딩을 통한 호스트 접근 및 `mysqldump`/별도 DB 복구 확인

### 9.2 현재 상태와 남은 점검
- 위에 적은 서비스, 권한, 로그, 백업/복구 실습은 완료했다.
- 자동화된 장애 복구나 예약 백업을 구축했다는 뜻은 아니다.

### 9.3 Phase 1 적용 방향
Windows Server는 학습용 VM이며 실제 기관 운영 서버가 아니다. Tomcat 8080 접근 제어는 10장에서 설명한다.

---

## 10. [완료] Ubuntu Server와 Nginx Reverse Proxy

Ubuntu Server VM에 NAT NIC와 MiniCampusNet 내부 NIC를 구성했다. Ubuntu에서 Windows Tomcat으로 접근하고, Nginx → Tomcat → MiniCampusLMS 및 호스트 PC → Nginx 경로의 정상 응답을 확인했다. Nginx Access Log도 확인했다.

Nginx는 Tomcat 앞단에서 사용자 요청을 받아 내부 Tomcat으로 전달한다. 내부망 주소는 Windows `192.168.50.10`, Ubuntu/Nginx `192.168.50.20`이다.

---

## 11. [완료] Windows Firewall 접근 제어 및 Nginx WAF 실습

Windows Firewall에서 기존 Tomcat TCP 8080 전체 허용 규칙을 비활성화하고, Nginx 서버 `192.168.50.20`에서 오는 TCP 8080만 허용했다. 호스트 PC의 Tomcat 직접 접근은 실패하고 Nginx를 통한 LMS 접근은 정상임을 확인했다.

ModSecurity v3와 OWASP Core Rule Set(CRS)을 Nginx에 설치했다. 약 924개 로컬 규칙 로드를 확인했다.

| 검증 | 확인 결과 |
| :--- | :--- |
| DetectionOnly 정상 요청 | HTTP 200 유지 |
| SQL Injection 형태 요청 | CRS 942100 탐지 확인 |
| XSS 형태 요청 | CRS 941100, 941110, 941160 탐지 확인 |
| ModSecurity audit log | 생성 및 확인 |
| 차단 모드(SecRuleEngine On) SQL Injection 형태 요청 | HTTP 403 차단 확인 |
| 차단 모드 정상 LMS 요청 | HTTP 200 유지 |

WAF는 공격 형태의 웹 요청을 탐지하거나 차단하는 방어 계층이다. 위 실습은 실제 VM에서 확인했지만 Nginx/Firewall 설정과 audit log 증빙은 아직 GitHub에 포함하지 않았다.

### [향후 계획]

- Splunk 통합 로그 수집, 대시보드와 Alert 구성
- Tomcat/MySQL 로그를 포함한 중앙 모니터링 구성

이 단계는 실제 운영 환경을 모니터링하고, 로그 기반 대응을 학습하는 데 중점을 둔다.

---

## 12. 결론 및 운영 요약
### [현재 상태]

MiniCampusLMS는 Java 11, JSP/JDBC, Tomcat 9, MySQL 8 기반이다. Windows Server 2022, Ubuntu/Nginx Reverse Proxy, Windows Firewall 접근 제어, ModSecurity/CRS 탐지·차단, 수동 DB 백업/복구와 로그 확인을 실제 실습 VM에서 검증했다. GitHub 저장소에는 이를 재현·검토할 증빙 자료가 아직 없다.

### [향후 계획]

- 수강취소 및 내 수강내역 조회
- 같은 과목의 다른 분반 중복 신청 차단
- 시간표 충돌 검사
- 명시적 DB Transaction 및 commit/rollback
- 취소 후 재신청 처리
- JMeter 동시성 검증 및 DB Lock 적용
- Splunk 통합 로그 수집, 대시보드, Alert
- 자동 예약 백업 및 보관주기 정책
- 별도 DB 서버 분리
- HTTPS/TLS 최종 구성
- IDS/IPS 및 DLP 실습