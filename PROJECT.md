# MiniCampusLMS

## 프로젝트 목표

JSP/JDBC 기반 학사정보시스템의 핵심 수강 기능을 구현하고, 이후 운영·성능·보안 실습으로 확장하는 개인 포트폴리오 프로젝트다.

## 기술 환경

- Java 11
- JSP / JDBC
- MySQL 8
- Apache Tomcat 9
- Eclipse Dynamic Web Project
- 세션 기반 로그인 및 `ADMIN` / `STUDENT` 역할 구분

## 구현 및 검증 완료

### 학생 학사 기능

- 학생의 개설강좌 조회
- 학생 수강신청
- 본인 수강내역 조회
- 본인 enrollment인지 서버에서 확인한 뒤 수강취소
- 취소 시 삭제하지 않고 `status = 'CANCELED'`, `canceled_at = NOW()`로 이력 유지

### 수강신청 검증

- `STUDENT` 권한 확인
- 개설강좌 `OPEN` 상태 확인
- 현재 수강 인원과 정원 비교
- 동일 학생의 동일 개설강좌 중복 신청 확인

### 동시 수강신청 검증

로컬 Eclipse/Tomcat 환경에서 JMeter Thread 4, 서로 다른 학생 4명, Login 4회, Enrollment 4회, Synchronizing Timer 4명으로 테스트했다. 대상은 `section_id=12`, `capacity=1`, `status=OPEN`이다.

- 개선 전: 요청 8건, 오류 0건, 최종 `ENROLLED=4`로 Race Condition 재현
- 개선 후: 동일 조건에서 요청 8건, 오류 0건, 최종 `ENROLLED=1`
- 조치: JDBC Transaction, 대상 `course_sections` 행의 `SELECT ... FOR UPDATE`, 잠금 후 `ENROLLED` 건수 재조회, 성공 commit 및 실패/예외 rollback

위 동시성 결과는 로컬 Eclipse/Tomcat에서 확인한 결과다. 이 변경을 포함한 최신 WAR의 Windows Server 재배포와 재검증은 아직 완료하지 않았다.

## 현재 범위에서 남은 기능 및 검증

- 같은 과목의 다른 분반 중복 신청 방지
- 시간표 충돌 검사
- 취소 후 동일 분반 재신청
- 최신 동시성 수정본의 Windows Server WAR 재배포 및 확인

## 향후 운영·인프라 작업

- Splunk 통합 로그 수집, 대시보드 및 Alert
- 자동 예약 백업 및 보관주기 정책
- 별도 DB 서버 분리
- HTTPS/TLS 구성
- IDS/IPS 및 DLP 실습

## 제외 범위

- 성적, 등록금, 휴학, 장학금
- 복잡한 교수 전용 기능
- Spring/Spring Boot 전환

## UI 및 개발 원칙

- 기존 MiniCampusLMS 구조와 화면 스타일 유지
- 목록은 표, 등록·수정은 단순한 폼으로 제공
- 성공·실패 이유를 사용자에게 안내
- 학생·관리자 기능과 권한을 구분
- 한 단계씩 구현하고 확인되지 않은 기능은 완료로 표시하지 않음
