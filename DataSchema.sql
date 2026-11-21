CREATE TABLE users (
    user_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL
    CONSTRAINT users_name_ck
    CHECK (user_name ~ '^[A-Za-zА-Яа-яІіЇїЄєҐґ''’ -]{2,50}$')
);

CREATE TABLE video_records (
    video_record_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users (user_id),
    frame_num INTEGER NOT NULL CHECK (frame_num > 0)
);

CREATE TABLE reference_angles (
    reference_angle_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    joint_name VARCHAR(20) NOT NULL
    CONSTRAINT reference_angles_joint_ck
    CHECK (joint_name ~ '^(плече|лікоть|зап''ястя|стегно|коліно|щиколотка)$'),
    angle_value NUMERIC(5, 2) NOT NULL CHECK (angle_value BETWEEN 0 AND 180),
    tolerance_value NUMERIC(4, 2) NOT NULL DEFAULT 10
    CHECK (tolerance_value > 0),
    safe_min_value NUMERIC(5, 2) NOT NULL
    CHECK (safe_min_value BETWEEN 0 AND 180),
    safe_max_value NUMERIC(5, 2) NOT NULL
    CHECK (safe_max_value BETWEEN 0 AND 180),
    CONSTRAINT reference_angles_safe_ck CHECK (safe_min_value <= safe_max_value)
);

CREATE TABLE body_landmarks (
    body_landmark_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    video_record_id INTEGER NOT NULL REFERENCES video_records (video_record_id),
    joint_name VARCHAR(20) NOT NULL
    CONSTRAINT body_landmarks_joint_ck
    CHECK (joint_name ~ '^(плече|лікоть|зап''ястя|стегно|коліно|щиколотка)$'),
    x_coord NUMERIC(5, 4) NOT NULL CHECK (x_coord BETWEEN 0 AND 1),
    y_coord NUMERIC(5, 4) NOT NULL CHECK (y_coord BETWEEN 0 AND 1)
);

CREATE TABLE joint_angles (
    joint_angle_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reference_angle_id INTEGER NOT NULL
    REFERENCES reference_angles (reference_angle_id),
    angle_value NUMERIC(5, 2) NOT NULL CHECK (angle_value BETWEEN 0 AND 180)
);

CREATE TABLE angle_vertices (
    joint_angle_id INTEGER NOT NULL REFERENCES joint_angles (joint_angle_id),
    body_landmark_id INTEGER NOT NULL
    REFERENCES body_landmarks (body_landmark_id),
    PRIMARY KEY (joint_angle_id, body_landmark_id)
);

CREATE TABLE pose_assessments (
    pose_assessment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    video_record_id INTEGER NOT NULL UNIQUE
    REFERENCES video_records (video_record_id),
    assessment_status VARCHAR(10) NOT NULL
    CHECK (assessment_status IN ('норма', 'відхилення'))
);

CREATE TABLE deviations (
    deviation_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    joint_angle_id INTEGER NOT NULL UNIQUE
    REFERENCES joint_angles (joint_angle_id),
    pose_assessment_id INTEGER NOT NULL
    REFERENCES pose_assessments (pose_assessment_id),
    deviation_value NUMERIC(5, 2) NOT NULL CHECK (deviation_value > 0)
);

CREATE TABLE symmetry_violations (
    symmetry_violation_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pose_assessment_id INTEGER NOT NULL
    REFERENCES pose_assessments (pose_assessment_id),
    body_part_name VARCHAR(30) NOT NULL,
    difference_value NUMERIC(5, 2) NOT NULL CHECK (difference_value > 0)
);

CREATE TABLE hints (
    hint_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pose_assessment_id INTEGER NOT NULL
    REFERENCES pose_assessments (pose_assessment_id),
    hint_text VARCHAR(200) NOT NULL
    CONSTRAINT hints_text_ck
    CHECK (hint_text ~ '^[^[:space:]].{3,198}[^[:space:]]$')
);
