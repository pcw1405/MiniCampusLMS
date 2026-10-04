# MySQL 백업 및 복구 실습

## 목적
DB 장애나 데이터 손실에 대비해 백업 파일을 만들고, 운영 DB와 분리된 곳에서 복구 가능한지 확인합니다. 원본 데이터를 바로 덮어쓰지 않고 별도 Recovery DB를 사용했습니다.

## 구성
- DB 서버: Windows Server 2022 VM의 MySQL 8
- 백업 방식: `mysqldump` 논리 백업
- 복구 대상: 별도 `mini_lms_recovery` DB
- 데이터: MiniCampusLMS 실습용 데이터

## 수행 내용
- `mysqldump` 방식으로 DB 백업을 수행했습니다.
- 별도 `mini_lms_recovery` DB를 만들었습니다.
- 백업 파일을 Recovery DB에 Restore했습니다.
- 주요 테이블의 존재와 데이터 건수를 확인했습니다.

## 검증 결과
아래 건수는 해당 백업/복구 실습 시점에 확인한 값입니다. 운영 DB의 고정된 데이터 수나 이후 실행의 기대값을 뜻하지 않습니다.

| 테이블 | 실습 시점 건수 |
| :--- | ---: |
| `users` | 5 |
| `students` | 4 |
| `courses` | 5 |
| `course_sections` | 7 |
| `enrollments` | 2 |

## 증빙 파일
현재 이미지나 로그 파일은 저장소에 없습니다. 추후 민감정보 제거 후 추가 예정입니다. DB dump 원본 SQL은 공개 저장소에 올리지 않습니다. 제안 파일명:
- `restore-tables.png`
- `restore-counts.png`

## 의미
백업 파일이 만들어지는 것만으로는 복구 가능성을 보장할 수 없습니다. 별도 DB에서 테이블과 건수를 확인해 복구 절차가 동작하는지 점검한 실습입니다.