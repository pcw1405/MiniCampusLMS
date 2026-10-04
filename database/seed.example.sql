SET NAMES utf8mb4;

-- Public portfolio example data for a fresh, isolated test database only.
-- These are demo placeholders, not real development or production credentials.
-- The application currently compares the password column directly; replace these
-- placeholders before any use outside an isolated demonstration environment.

INSERT INTO users (id, username, password, name, role) VALUES
    (9001, 'admin_demo', 'DEMO_PASSWORD', '예제 관리자', 'ADMIN'),
    (9002, 'student_demo01', 'DEMO_PASSWORD', '예제 학생 1', 'STUDENT'),
    (9003, 'student_demo02', 'DEMO_PASSWORD', '예제 학생 2', 'STUDENT')
ON DUPLICATE KEY UPDATE
    username = VALUES(username),
    password = VALUES(password),
    name = VALUES(name),
    role = VALUES(role);

INSERT INTO students (id, user_id, student_number, admission_year, status, created_at) VALUES
    (9001, 9002, 'DEMO2026001', 2026, 'ACTIVE', NOW()),
    (9002, 9003, 'DEMO2026002', 2026, 'ACTIVE', NOW())
ON DUPLICATE KEY UPDATE
    user_id = VALUES(user_id),
    student_number = VALUES(student_number),
    admission_year = VALUES(admission_year),
    status = VALUES(status);

INSERT INTO semesters (id, year, term, start_date, end_date, created_at) VALUES
    (9001, 2026, '1', '2026-03-02', '2026-06-20', NOW())
ON DUPLICATE KEY UPDATE
    year = VALUES(year),
    term = VALUES(term),
    start_date = VALUES(start_date),
    end_date = VALUES(end_date);

INSERT INTO courses (id, course_code, course_name, description, created_at) VALUES
    (9001, 'DEMO101', '예제 과목', '공개 포트폴리오 테스트용 과목', NOW())
ON DUPLICATE KEY UPDATE
    course_code = VALUES(course_code),
    course_name = VALUES(course_name),
    description = VALUES(description);

INSERT INTO course_sections (id, course_id, semester_id, section_no, professor_name, day_of_week, start_time, end_time, room_name, capacity, status, created_at) VALUES
    (9001, 9001, 9001, 1, '예제 교수', 'MON', '09:00:00', '10:00:00', 'DEMO-A', 2, 'OPEN', NOW()),
    (9002, 9001, 9001, 2, '예제 교수', 'WED', '10:00:00', '11:00:00', 'DEMO-B', 1, 'OPEN', NOW())
ON DUPLICATE KEY UPDATE
    course_id = VALUES(course_id),
    semester_id = VALUES(semester_id),
    section_no = VALUES(section_no),
    professor_name = VALUES(professor_name),
    day_of_week = VALUES(day_of_week),
    start_time = VALUES(start_time),
    end_time = VALUES(end_time),
    room_name = VALUES(room_name),
    capacity = VALUES(capacity),
    status = VALUES(status);

INSERT INTO enrollments (id, student_id, section_id, status, enrolled_at, canceled_at) VALUES
    (9001, 9001, 9001, 'ENROLLED', NOW(), NULL)
ON DUPLICATE KEY UPDATE
    student_id = VALUES(student_id),
    section_id = VALUES(section_id),
    status = VALUES(status),
    canceled_at = VALUES(canceled_at);