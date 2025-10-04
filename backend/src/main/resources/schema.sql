http://localhost:8080/uploads/1759608574183-CV.docx.pdf

'https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/youtube.upload https://www.googleapis.com/auth/youtube&access_type=offline&include_granted_scopes=true&response_type=code&redirect_uri=http://localhost:8080/api/auth/youtube/oauth/callback&client_id=967252627443-jb04c3epqil13lo4i9aecr8akqe3iupo.apps.googleusercontent.com&prompt=consent'

-- 1. Users (both Students & Teachers)
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('STUDENT', 'TEACHER', 'ADMIN')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Courses
CREATE TABLE courses (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    teacher_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    price DECIMAL(10,2) DEFAULT 0.00, -- 0 = free course
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Course Content (Videos, PPTs, PDFs, etc.)
CREATE TABLE course_contents (
    id BIGSERIAL PRIMARY KEY,
    course_id BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    file_type VARCHAR(50) NOT NULL CHECK (file_type IN ('VIDEO', 'PPT', 'PDF', 'DOC')),
    file_url TEXT NOT NULL, -- MinIO/S3 signed URL or path
    duration_seconds INT, -- applicable for videos
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Enrollments (Student <-> Course mapping)
CREATE TABLE enrollments (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    access_granted_by BIGINT REFERENCES users(id), -- Teacher/Admin who gave free access
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (student_id, course_id) -- prevents duplicate enrollments
);

-- 5. Payments
CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    razorpay_order_id VARCHAR(100) UNIQUE NOT NULL,
    razorpay_payment_id VARCHAR(100),
    razorpay_signature VARCHAR(255),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR',
    status VARCHAR(20) NOT NULL CHECK (status IN ('CREATED', 'SUCCESS', 'FAILED', 'REFUNDED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Student Progress (Optional: Track video watching, PPT completion)
CREATE TABLE progress (
    id BIGSERIAL PRIMARY KEY,
    enrollment_id BIGINT NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,
    content_id BIGINT NOT NULL REFERENCES course_contents(id) ON DELETE CASCADE,
    progress_percent DECIMAL(5,2) DEFAULT 0.00,
    last_accessed TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (enrollment_id, content_id)
);
ALTER TABLE course_contents
ADD COLUMN is_free boolean NOT NULL DEFAULT false;
