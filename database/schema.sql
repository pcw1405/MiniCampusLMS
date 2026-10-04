-- MiniCampusLMS target schema for a fresh database
-- This file reflects the approved MVP academic design only.
-- It does not modify the current live database.

CREATE TABLE IF NOT EXISTS users (
    id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    name VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'STUDENT',
    PRIMARY KEY (id),
    UNIQUE KEY uk_users_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notice (
    id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    writer_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_notice_writer_id (writer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS security_test_log (
    id INT NOT NULL AUTO_INCREMENT,
    vuln_type VARCHAR(50) NOT NULL,
    target_page VARCHAR(100) NOT NULL,
    parameter_name VARCHAR(50) NOT NULL,
    payload TEXT NULL,
    executed_sql TEXT NULL,
    result_count INT NOT NULL DEFAULT 0,
    true_false_result VARCHAR(20) NULL,
    memo VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_security_test_log_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS students (
    id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    student_number VARCHAR(20) NOT NULL,
    admission_year SMALLINT NOT NULL,
    status ENUM('ACTIVE', 'LEAVE', 'GRADUATED', 'DROP') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_students_user_id (user_id),
    UNIQUE KEY uk_students_student_number (student_number),
    CONSTRAINT fk_students_user
        FOREIGN KEY (user_id) REFERENCES users (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS courses (
    id INT NOT NULL AUTO_INCREMENT,
    course_code VARCHAR(20) NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_courses_course_code (course_code),
    KEY idx_courses_course_name (course_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS semesters (
    id INT NOT NULL AUTO_INCREMENT,
    year SMALLINT NOT NULL,
    term ENUM('1', '2', 'SUMMER', 'WINTER') NOT NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_semesters_year_term (year, term),
    CONSTRAINT chk_semesters_dates
        CHECK (start_date IS NULL OR end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS course_sections (
    id INT NOT NULL AUTO_INCREMENT,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    section_no INT NOT NULL,
    professor_name VARCHAR(50) NOT NULL,
    day_of_week ENUM('MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room_name VARCHAR(50) NULL,
    capacity INT NOT NULL,
    status ENUM('OPEN', 'CLOSED', 'CANCELLED') NOT NULL DEFAULT 'OPEN',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_course_sections_course_semester_section (course_id, semester_id, section_no),
    KEY idx_course_sections_course_id (course_id),
    KEY idx_course_sections_semester_id (semester_id),
    CONSTRAINT fk_course_sections_course
        FOREIGN KEY (course_id) REFERENCES courses (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_course_sections_semester
        FOREIGN KEY (semester_id) REFERENCES semesters (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_course_sections_capacity
        CHECK (capacity >= 1),
    CONSTRAINT chk_course_sections_time
        CHECK (start_time < end_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS enrollments (
    id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    section_id INT NOT NULL,
    status ENUM('ENROLLED', 'CANCELED') NOT NULL DEFAULT 'ENROLLED',
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    canceled_at TIMESTAMP NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_enrollments_student_section (student_id, section_id),
    KEY idx_enrollments_student_status (student_id, status),
    KEY idx_enrollments_section_status (section_id, status),
    CONSTRAINT fk_enrollments_student
        FOREIGN KEY (student_id) REFERENCES students (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_enrollments_section
        FOREIGN KEY (section_id) REFERENCES course_sections (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_enrollments_canceled_at
        CHECK (
            (status = 'ENROLLED' AND canceled_at IS NULL)
            OR
            (status = 'CANCELED' AND canceled_at IS NOT NULL)
        )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Self review notes:
-- 1. Table creation order follows FK dependency: users -> students -> courses -> semesters -> course_sections -> enrollments.
-- 2. `students.user_id` intentionally references `users.id` to reuse the existing login identity.
-- 3. `enrollments.student_id` and `enrollments.section_id` are both required for one student to be enrolled in one section only once.
-- 4. `CHECK (capacity >= 1)` prevents invalid non-positive capacities.
-- 5. `CHECK (start_time < end_time)` prevents impossible lecture time ranges.
-- 6. `CHECK (status = 'ENROLLED' OR canceled_at IS NOT NULL)` keeps a canceled enrollment tied to a cancellation timestamp.
-- 7. This schema is limited to the approved MVP academic model and does not alter the live `courses` or `enrollments` tables.
