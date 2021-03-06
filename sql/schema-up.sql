-- Tables
CREATE TABLE teachers (
	teacher_id NUMBER NOT NULL,
	teacher_name VARCHAR2(50) NOT NULL,
	teacher_email VARCHAR2(50), 
	teacher_phone VARCHAR2(20),
	CONSTRAINT teacher_id_pk PRIMARY KEY ( teacher_id )
);

CREATE TABLE subjects (
	subject_id NUMBER NOT NULL,
	subject_name VARCHAR2(25) NOT NULL,
	CONSTRAINT subject_id_pk PRIMARY KEY ( subject_id )
);

CREATE TABLE batches (
	batch_id NUMBER NOT NULL,
	batch_year_passout NUMBER NOT NULL,
	batch_stream VARCHAR2(25) NOT NULL,
	CONSTRAINT batch_id_pk PRIMARY KEY ( batch_id )
);

CREATE TABLE sections (
	section_id NUMBER NOT NULL,
	batch_id NUMBER NOT NULL CONSTRAINT batch_id_fkey REFERENCES batches(batch_id),
	section_name VARCHAR(3) NOT NULL,
	CONSTRAINT section_id_pk PRIMARY KEY ( section_id )
);

CREATE TABLE students (
	student_id NUMBER NOT NULL,
	section_id NUMBER NOT NULL CONSTRAINT section_id_fkey REFERENCES sections(section_id),
	semester NUMBER NOT NULL,
	student_name VARCHAR2(50) NOT NULL,
	student_email VARCHAR2(50) , 
	student_phone VARCHAR2(20),
	CONSTRAINT student_id_pk PRIMARY KEY ( student_id )
);

CREATE TABLE schedules (
	schedule_id NUMBER NOT NULL,
	subject_id NUMBER NOT NULL CONSTRAINT subject_id_fkey REFERENCES subjects(subject_id),
	teacher_id NUMBER NOT NULL CONSTRAINT teacher_id_fkey REFERENCES teachers(teacher_id),
	section_id NUMBER NOT NULL CONSTRAINT section_id_fkey2 REFERENCES sections(section_id),
	schedule_weekday VARCHAR2(25) NOT NULL,
	schedule_period NUMBER NOT NULL, 
	CONSTRAINT schedule_id_pk PRIMARY KEY ( schedule_id )
);

CREATE TABLE attendance_records (
	attendance_record_id NUMBER NOT NULL,
	student_id NUMBER NOT NULL CONSTRAINT student_id_fkey REFERENCES students(student_id),
	schedule_id NUMBER NOT NULL CONSTRAINT schedule_id_fkey REFERENCES schedules(schedule_id),
	attendance_record_value NUMBER(1) DEFAULT 0,
	attendance_record_date DATE NOT NULL,
	CONSTRAINT attendance_id_pk PRIMARY KEY ( attendance_id )
);

-- Sequences
CREATE SEQUENCE teachers_teacher_id_seq 
	MINVALUE 1 
	START WITH 1
	INCREMENT BY 1
	NOCACHE 
;

CREATE SEQUENCE subjects_subject_id_seq 
	MINVALUE 10 
	START WITH 10
	INCREMENT BY 10
	NOCACHE 
;

CREATE SEQUENCE batches_batch_id_seq 
	MINVALUE 1 
	START WITH 1
	INCREMENT BY 1
	NOCACHE 
;

CREATE SEQUENCE sections_section_id_seq 
	MINVALUE 1 
	START WITH 1
	INCREMENT BY 1
	NOCACHE 
;

CREATE SEQUENCE students_student_id_seq 
	MINVALUE 1 
	START WITH 1
	INCREMENT BY 1
	NOCACHE 
;

CREATE SEQUENCE schedules_schedule_id_seq 
	MINVALUE 1 
	START WITH 1
	INCREMENT BY 1
	NOCACHE 
;

CREATE SEQUENCE attendance_rec_id_seq 
	MINVALUE 1 
	START WITH 1
	INCREMENT BY 1
	NOCACHE 
;

-- Triggers	
CREATE OR REPLACE TRIGGER trig_teacher_autoincrement
	BEFORE INSERT ON teachers
	FOR EACH ROW
	BEGIN
		:new.teacher_id := teachers_teacher_id_seq.nextval;
	END;
/

CREATE OR REPLACE TRIGGER trig_subject_autoincrement
	BEFORE INSERT ON subjects
	FOR EACH ROW
	BEGIN
		:new.subject_id := subjects_subject_id_seq.nextval;
	END;
/

CREATE OR REPLACE TRIGGER trig_batch_autoincrement
	BEFORE INSERT ON batches
	FOR EACH ROW
	BEGIN
		:new.batch_id := batches_batch_id_seq.nextval;
	END;
/

CREATE OR REPLACE TRIGGER trig_section_autoincrement
	BEFORE INSERT ON sections
	FOR EACH ROW
	BEGIN
		:new.section_id := sections_section_id_seq.nextval;
	END;
/

CREATE OR REPLACE TRIGGER trig_student_autoincrement
	BEFORE INSERT ON students
	FOR EACH ROW
	BEGIN
		:new.student_id := students_student_id_seq.nextval;
	END;
/

CREATE OR REPLACE TRIGGER trig_schedule_autoincrement
	BEFORE INSERT ON schedules
	FOR EACH ROW
	BEGIN
		:new.schedule_id := schedules_schedule_id_seq.nextval;
	END;
/

CREATE OR REPLACE TRIGGER trig_a_record_autoincrement
	BEFORE INSERT ON attendance_records
	FOR EACH ROW
	BEGIN
		:new.attendance_id := attendance_rec_id_seq.nextval;
	END;
/

-- Views
CREATE OR REPLACE VIEW class_routine AS
	SELECT
		schedules.section_id,
		schedules.schedule_weekday,
		schedules.schedule_period,
		sections.section_name,
		batches.batch_stream,
		subjects.subject_name,
		teachers.teacher_name
	FROM schedules
	INNER JOIN sections
		ON sections.section_id = schedules.section_id
	INNER JOIN batches
		ON batches.batch_id = sections.batch_id
	INNER JOIN subjects
		ON subjects.subject_id = schedules.subject_id
	INNER JOIN teachers
		ON teachers.teacher_id = schedules.teacher_id
WITH READ ONLY;

CREATE OR REPLACE VIEW teacher_routine AS
	SELECT
		schedules.teacher_id,
		schedules.schedule_weekday,
		schedules.schedule_period,
		teachers.t_name,
		subjects.s_name,
		sections.s_year,
		sections.s_letter,
		batches.stream
	FROM
		schedules,
		subjects,
		batches,
		teachers,
		sections
	WHERE schedules.teacher_id = teachers.teacher_id
	AND subjects.subject_id = schedules.subject_id
	AND schedules.section_id = sections.section_id
	AND batches.batch_id = sections.batch_id
WITH READ ONLY;

CREATE OR REPLACE VIEW attendance_list AS
SELECT
attendance_records.schedule_id,
schedules.section_id,
schedules.week_day,
schedules.period,
schedules.subject_id,
subjects.s_name,
students.s_name as student_name,
teachers.t_name,
attendance_records.student_id,
attendance_records.attended,
attendance_records.a_date
FROM
schedules,
sections,
subjects,
teachers,
attendance_records,
students
WHERE attendance_records.schedule_id = schedules.schedule_id
AND attendance_records.student_id = students.student_id
AND sections.section_id = schedules.section_id
AND subjects.subject_id = schedules.subject_id
AND teachers.teacher_id = schedules.teacher_id
WITH READ ONLY;

-- Procedures
CREATE OR REPLACE PROCEDURE add_teacher
	( 
		p_t_name   teachers.t_name%type,
		p_email   teachers.email%type,
		p_phone   teachers.phone%type
	)
	IS
	BEGIN
		INSERT INTO teachers(t_name,email,phone)
			VALUES(p_t_name,p_email,p_phone);
	END;
/

CREATE OR REPLACE PROCEDURE add_subject
	( 
		p_s_name   subjects.s_name%type
	)
	IS
	BEGIN
		INSERT INTO subjects(s_name)
			VALUES(p_s_name);
	END;
/

CREATE OR REPLACE PROCEDURE add_batch
	(
		p_year_passout  batches.year_passout%type,
		p_stream  batches.stream%type
	)
	IS
	BEGIN
		INSERT INTO batches(year_passout,stream)
			VALUES(p_year_passout,p_stream);
	END;
/

CREATE OR REPLACE PROCEDURE add_section
	(
		p_batch_id  sections.batch_id%type,
		p_s_letter  sections.s_letter%type,
		p_s_year  sections.s_year%type
	)
	IS
	BEGIN
		INSERT INTO sections(batch_id,s_letter,s_year)
			VALUES(p_batch_id,p_s_letter,p_s_year);
	END;
/

CREATE OR REPLACE PROCEDURE add_student
	( 
		p_section_id   students.section_id%type,
		p_semester   students.semester%type,
		p_s_name   students.s_name%type,
		p_email   students.email%type,
		p_phone   students.phone%type
	)
	IS
	BEGIN
		INSERT INTO students(section_id,semester,s_name,email,phone)
			VALUES(p_section_id,p_semester,p_s_name,p_email,p_phone);
	END;
/

CREATE OR REPLACE PROCEDURE add_schedule
	(
		p_teacher_id   schedules.teacher_id%type,
		p_section_id   schedules.section_id%type,
		p_subject_id   schedules.subject_id%type,
		p_week_day   schedules.week_day%type,
		p_period   schedules.period%type
	)
	IS
	BEGIN
		INSERT INTO schedules(teacher_id,section_id,subject_id,week_day,period)
			VALUES(p_teacher_id,p_section_id,p_subject_id,p_week_day,p_period);
	END;
/

CREATE OR REPLACE PROCEDURE add_attendance_record
	( 
		p_student_id   attendance_records.student_id%type,
		p_schedule_id   attendance_records.schedule_id%type,
		p_attended   attendance_records.attended%type,
		p_a_date   attendance_records.a_date%type
	)
	IS
	BEGIN
	  INSERT INTO attendance_records(student_id,schedule_id,attended,a_date)
		VALUES(p_student_id,p_schedule_id,p_attended,p_a_date);
	END;
/

CREATE OR REPLACE PROCEDURE view_class_routine
	( 
		p_s_letter   attendance_records.student_id%type,
		p_schedule_id   attendance_records.schedule_id%type,
		p_attended   attendance_records.attended%type,
		p_a_date   attendance_records.a_date%type
	)
	IS
	BEGIN
	  INSERT INTO attendance_records(student_id,schedule_id,attended,a_date)
		VALUES(p_student_id,p_schedule_id,p_attended,p_a_date);
	END;
/
