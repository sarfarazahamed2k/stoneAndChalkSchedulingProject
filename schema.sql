-- =========================================================
-- EMERGENCY EDUCATOR NETWORK AUSTRALIA
-- Simplified Proof of Concept (POC) Schema & Seed Data
-- (Expanded seed data version)
-- =========================================================

BEGIN;

DROP SCHEMA IF EXISTS emergency_educator CASCADE;
CREATE SCHEMA emergency_educator;
SET search_path TO emergency_educator, public;

-- =========================================================
-- 1. TABLE DEFINITIONS
-- =========================================================

-- CORE USERS (One table for everyone: Admins, Educators, School Contacts)
CREATE TABLE users (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email       text NOT NULL UNIQUE,
    first_name  text NOT NULL,
    last_name   text NOT NULL,
    role_type   text NOT NULL, -- 'EDUCATOR', 'SCHOOL_ADMIN', 'PLATFORM_ADMIN'
    is_active   boolean NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- EDUCATOR AVAILABILITY (Flat and simple)
CREATE TABLE availability (
    id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    educator_id    uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    start_time     timestamptz NOT NULL,
    end_time       timestamptz NOT NULL,
    status         text NOT NULL DEFAULT 'AVAILABLE', -- 'AVAILABLE', 'BOOKED'
    CONSTRAINT time_chk CHECK (end_time > start_time)
);

-- COVER REQUESTS (Sectors, subjects, and demands combined)
CREATE TABLE class_requests (
    id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by     uuid NOT NULL REFERENCES users(id),
    school_name    text NOT NULL,
    subject_name   text NOT NULL,
    start_time     timestamptz NOT NULL,
    end_time       timestamptz NOT NULL,
    rate_cents     integer NOT NULL, -- Storing money as cents eliminates decimal bugs
    status         text NOT NULL DEFAULT 'OPEN', -- 'OPEN', 'CONFIRMED', 'CANCELLED'
    CONSTRAINT req_time_chk CHECK (end_time > start_time)
);

-- BOOKINGS (The link table matching a request to an educator)
CREATE TABLE bookings (
    id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    class_request_id uuid NOT NULL UNIQUE REFERENCES class_requests(id) ON DELETE CASCADE,
    educator_id      uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    confirmed_at     timestamptz NOT NULL DEFAULT now(),
    status           text NOT NULL DEFAULT 'CONFIRMED' -- 'CONFIRMED', 'COMPLETED', 'CANCELLED'
);

-- SIMPLIFIED AUDIT LOG (Flat text storage for rapid analysis)
CREATE TABLE audit_logs (
    id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    actor_id     uuid REFERENCES users(id) ON DELETE SET NULL,
    action       text NOT NULL, -- e.g., 'BOOKING_CREATED', 'AVAILABILITY_ADDED'
    description  text NOT NULL,
    created_at   timestamptz NOT NULL DEFAULT now()
);

-- =========================================================
-- 2. SAMPLE / DUMMY SEED DATA
-- =========================================================

-- Populate Users (1 Platform Admin, 4 School Admins, 8 Educators)
INSERT INTO users (id, email, first_name, last_name, role_type, is_active) VALUES
    ('a0000000-0000-0000-0000-000000000001', 'admin@emergencyeducator.com', 'System', 'Admin', 'PLATFORM_ADMIN', true),
    ('a0000000-0000-0000-0000-000000000002', 'daniel.w@harbourview.edu.au', 'Daniel', 'Wong', 'SCHOOL_ADMIN', true),
    ('a0000000-0000-0000-0000-000000000003', 'priya.n@southerncollege.edu.au', 'Priya', 'Nair', 'SCHOOL_ADMIN', true),
    ('a0000000-0000-0000-0000-000000000004', 'tom.b@westgatehigh.edu.au', 'Tom', 'Baxter', 'SCHOOL_ADMIN', true),
    ('a0000000-0000-0000-0000-000000000005', 'lena.k@stmarks.edu.au', 'Lena', 'Kowalski', 'SCHOOL_ADMIN', true),
    ('e0000000-0000-0000-0000-000000000001', 'sarah.mitchell@gmail.com', 'Sarah', 'Mitchell', 'EDUCATOR', true),
    ('e0000000-0000-0000-0000-000000000002', 'james.okafor@outlook.com', 'James', 'Okafor', 'EDUCATOR', true),
    ('e0000000-0000-0000-0000-000000000003', 'mei.chen@yahoo.com', 'Mei', 'Chen', 'EDUCATOR', true),
    ('e0000000-0000-0000-0000-000000000004', 'liam.osullivan@gmail.com', 'Liam', 'O''Sullivan', 'EDUCATOR', true),
    ('e0000000-0000-0000-0000-000000000005', 'fatima.hassan@outlook.com', 'Fatima', 'Hassan', 'EDUCATOR', true),
    ('e0000000-0000-0000-0000-000000000006', 'nick.papadopoulos@gmail.com', 'Nick', 'Papadopoulos', 'EDUCATOR', true),
    ('e0000000-0000-0000-0000-000000000007', 'aisha.singh@yahoo.com', 'Aisha', 'Singh', 'EDUCATOR', true),
    -- Inactive educator (left the platform)
    ('e0000000-0000-0000-0000-000000000008', 'greg.turner@gmail.com', 'Greg', 'Turner', 'EDUCATOR', false);

-- Populate Availability (relative timestamps: today through the next 3 days)
INSERT INTO availability (id, educator_id, start_time, end_time, status) VALUES
    -- Sarah: today 9-3, tomorrow 10-2
    ('b0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', date_trunc('day', now()) + interval '9 hours',  date_trunc('day', now()) + interval '15 hours', 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000001', date_trunc('day', now()) + interval '1 day 10 hours', date_trunc('day', now()) + interval '1 day 14 hours', 'AVAILABLE'),
    -- James: today 12-5, day after tomorrow 9-3
    ('b0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', date_trunc('day', now()) + interval '12 hours', date_trunc('day', now()) + interval '17 hours', 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000002', date_trunc('day', now()) + interval '2 days 9 hours', date_trunc('day', now()) + interval '2 days 15 hours', 'AVAILABLE'),
    -- Mei: today 8-1, tomorrow 8-4
    ('b0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000003', date_trunc('day', now()) + interval '8 hours',  date_trunc('day', now()) + interval '13 hours', 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000006', 'e0000000-0000-0000-0000-000000000003', date_trunc('day', now()) + interval '1 day 8 hours', date_trunc('day', now()) + interval '1 day 16 hours', 'AVAILABLE'),
    -- Liam: today 9-5
    ('b0000000-0000-0000-0000-000000000007', 'e0000000-0000-0000-0000-000000000004', date_trunc('day', now()) + interval '9 hours',  date_trunc('day', now()) + interval '17 hours', 'AVAILABLE'),
    -- Fatima: tomorrow 9-1, day 3 9-1
    ('b0000000-0000-0000-0000-000000000008', 'e0000000-0000-0000-0000-000000000005', date_trunc('day', now()) + interval '1 day 9 hours', date_trunc('day', now()) + interval '1 day 13 hours', 'AVAILABLE'),
    ('b0000000-0000-0000-0000-000000000009', 'e0000000-0000-0000-0000-000000000005', date_trunc('day', now()) + interval '3 days 9 hours', date_trunc('day', now()) + interval '3 days 13 hours', 'AVAILABLE'),
    -- Nick: today 7:30-12
    ('b0000000-0000-0000-0000-000000000010', 'e0000000-0000-0000-0000-000000000006', date_trunc('day', now()) + interval '7 hours 30 minutes', date_trunc('day', now()) + interval '12 hours', 'AVAILABLE'),
    -- Aisha: day after tomorrow 10-4
    ('b0000000-0000-0000-0000-000000000011', 'e0000000-0000-0000-0000-000000000007', date_trunc('day', now()) + interval '2 days 10 hours', date_trunc('day', now()) + interval '2 days 16 hours', 'AVAILABLE');

-- Populate Class Requests
INSERT INTO class_requests (id, created_by, school_name, subject_name, start_time, end_time, rate_cents, status) VALUES
    -- 1: Harbourview Math (Confirmed -> Sarah)
    ('c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002', 'Harbourview College', 'Year 9 Mathematics', date_trunc('day', now()) + interval '10 hours', date_trunc('day', now()) + interval '11 hours', 8500, 'CONFIRMED'),
    -- 2: Southern College IT (Confirmed -> James)
    ('c0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000003', 'Southern Learning College', 'VET Digital Skills', date_trunc('day', now()) + interval '13 hours', date_trunc('day', now()) + interval '15 hours', 15000, 'CONFIRMED'),
    -- 3: Harbourview English (Open/Unmatched)
    ('c0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000002', 'Harbourview College', 'Year 11 English', date_trunc('day', now()) + interval '1 day 11 hours', date_trunc('day', now()) + interval '1 day 12 hours 30 minutes', 11000, 'OPEN'),
    -- 4: Southern College Science (Cancelled)
    ('c0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000003', 'Southern Learning College', 'Year 8 Science', date_trunc('day', now()) + interval '9 hours', date_trunc('day', now()) + interval '10 hours 30 minutes', 9000, 'CANCELLED'),
    -- 5: Westgate PE (Confirmed -> Liam)
    ('c0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000004', 'Westgate High School', 'Year 7 Physical Education', date_trunc('day', now()) + interval '11 hours', date_trunc('day', now()) + interval '13 hours', 9500, 'CONFIRMED'),
    -- 6: St Marks Music (Confirmed -> Mei, tomorrow, later marked COMPLETED workflow-wise)
    ('c0000000-0000-0000-0000-000000000006', 'a0000000-0000-0000-0000-000000000005', 'St Marks Grammar', 'Year 10 Music', date_trunc('day', now()) + interval '1 day 9 hours', date_trunc('day', now()) + interval '1 day 11 hours', 12000, 'CONFIRMED'),
    -- 7: Westgate History (Open, tomorrow afternoon)
    ('c0000000-0000-0000-0000-000000000007', 'a0000000-0000-0000-0000-000000000004', 'Westgate High School', 'Year 12 Modern History', date_trunc('day', now()) + interval '1 day 13 hours', date_trunc('day', now()) + interval '1 day 15 hours', 13500, 'OPEN'),
    -- 8: St Marks Art (Open, day after tomorrow)
    ('c0000000-0000-0000-0000-000000000008', 'a0000000-0000-0000-0000-000000000005', 'St Marks Grammar', 'Year 8 Visual Arts', date_trunc('day', now()) + interval '2 days 10 hours', date_trunc('day', now()) + interval '2 days 12 hours', 10000, 'OPEN'),
    -- 9: Harbourview Chemistry (Confirmed -> Nick, early morning)
    ('c0000000-0000-0000-0000-000000000009', 'a0000000-0000-0000-0000-000000000002', 'Harbourview College', 'Year 12 Chemistry', date_trunc('day', now()) + interval '8 hours', date_trunc('day', now()) + interval '10 hours', 16000, 'CONFIRMED'),
    -- 10: Southern College Drama (Cancelled)
    ('c0000000-0000-0000-0000-000000000010', 'a0000000-0000-0000-0000-000000000003', 'Southern Learning College', 'Year 9 Drama', date_trunc('day', now()) + interval '2 days 13 hours', date_trunc('day', now()) + interval '2 days 14 hours 30 minutes', 8800, 'CANCELLED'),
    -- 11: Completed booking from yesterday (Aisha)
    ('c0000000-0000-0000-0000-000000000011', 'a0000000-0000-0000-0000-000000000005', 'St Marks Grammar', 'Year 11 Biology', date_trunc('day', now()) - interval '1 day' + interval '10 hours', date_trunc('day', now()) - interval '1 day' + interval '12 hours', 14000, 'CONFIRMED'),
    -- 12: Cancelled booking scenario (Fatima withdrew)
    ('c0000000-0000-0000-0000-000000000012', 'a0000000-0000-0000-0000-000000000004', 'Westgate High School', 'Year 10 Geography', date_trunc('day', now()) + interval '3 days 10 hours', date_trunc('day', now()) + interval '3 days 12 hours', 9800, 'OPEN');

-- Populate Bookings
INSERT INTO bookings (id, class_request_id, educator_id, status) VALUES
    ('d0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'CONFIRMED'),
    ('d0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 'CONFIRMED'),
    ('d0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000004', 'CONFIRMED'),
    ('d0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000006', 'e0000000-0000-0000-0000-000000000003', 'CONFIRMED'),
    ('d0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000009', 'e0000000-0000-0000-0000-000000000006', 'CONFIRMED'),
    -- Yesterday's Biology cover was completed by Aisha
    ('d0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000011', 'e0000000-0000-0000-0000-000000000007', 'COMPLETED'),
    -- Fatima accepted the Geography cover then withdrew (request reopened)
    ('d0000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000012', 'e0000000-0000-0000-0000-000000000005', 'CANCELLED');

-- Simulate application workflow by updating booked availability slots
UPDATE availability SET status = 'BOOKED' WHERE id IN (
    'b0000000-0000-0000-0000-000000000001', -- Sarah today
    'b0000000-0000-0000-0000-000000000003', -- James today
    'b0000000-0000-0000-0000-000000000006', -- Mei tomorrow
    'b0000000-0000-0000-0000-000000000007', -- Liam today
    'b0000000-0000-0000-0000-000000000010'  -- Nick today
);

-- Populate Audit Logs
INSERT INTO audit_logs (actor_id, action, description) VALUES
    ('e0000000-0000-0000-0000-000000000001', 'AVAILABILITY_ADDED', 'Sarah Mitchell added availability for today and tomorrow.'),
    ('a0000000-0000-0000-0000-000000000002', 'REQUEST_CREATED', 'Daniel Wong created an emergency request for Year 9 Mathematics.'),
    ('e0000000-0000-0000-0000-000000000001', 'BOOKING_CONFIRMED', 'Sarah Mitchell accepted the Year 9 Mathematics emergency request.'),
    ('a0000000-0000-0000-0000-000000000003', 'REQUEST_CREATED', 'Priya Nair created a request for VET Digital Skills.'),
    ('e0000000-0000-0000-0000-000000000002', 'BOOKING_CONFIRMED', 'James Okafor accepted the VET Digital Skills request.'),
    ('a0000000-0000-0000-0000-000000000003', 'REQUEST_CANCELLED', 'Priya Nair cancelled the Year 8 Science request as regular staff returned.'),
    ('a0000000-0000-0000-0000-000000000004', 'REQUEST_CREATED', 'Tom Baxter created an emergency request for Year 7 Physical Education.'),
    ('e0000000-0000-0000-0000-000000000004', 'BOOKING_CONFIRMED', 'Liam O''Sullivan accepted the Year 7 Physical Education request.'),
    ('a0000000-0000-0000-0000-000000000005', 'REQUEST_CREATED', 'Lena Kowalski created a request for Year 10 Music.'),
    ('e0000000-0000-0000-0000-000000000003', 'BOOKING_CONFIRMED', 'Mei Chen accepted the Year 10 Music request.'),
    ('a0000000-0000-0000-0000-000000000002', 'REQUEST_CREATED', 'Daniel Wong created an urgent request for Year 12 Chemistry.'),
    ('e0000000-0000-0000-0000-000000000006', 'BOOKING_CONFIRMED', 'Nick Papadopoulos accepted the Year 12 Chemistry request.'),
    ('e0000000-0000-0000-0000-000000000007', 'BOOKING_COMPLETED', 'Aisha Singh completed the Year 11 Biology cover at St Marks Grammar.'),
    ('e0000000-0000-0000-0000-000000000005', 'BOOKING_CANCELLED', 'Fatima Hassan withdrew from the Year 10 Geography cover; request reopened.'),
    ('a0000000-0000-0000-0000-000000000003', 'REQUEST_CANCELLED', 'Priya Nair cancelled the Year 9 Drama request due to timetable change.'),
    ('a0000000-0000-0000-0000-000000000001', 'USER_DEACTIVATED', 'System Admin deactivated Greg Turner at his request.');

COMMIT;