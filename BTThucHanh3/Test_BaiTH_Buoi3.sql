SET FEEDBACK ON
SET SERVEROUTPUT ON
SET LINESIZE 220
SET PAGESIZE 300
SET VERIFY OFF
SET DEFINE OFF

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';

CONNECT XUANTINH/XUANTINH
SHOW USER

SPOOL Test_BaiTH_Buoi3.log

PROMPT ==================================================
PROMPT CHAY SETUP + LOI GIAI
PROMPT ==================================================
@@00_setup_schema.sql
@@BaiTH_Buoi3.sql
SET SERVEROUTPUT ON

PROMPT
PROMPT ==================================================
PROMPT TEST BAI 1
PROMPT ==================================================
PROMPT [1a + 1b + 1c -> 1j] Kiem tra ket qua bang Cau1
SELECT id, name
FROM cau1
ORDER BY id;

PROMPT [1.2 - Case ton tai] Kiem tra SV da ton tai
BEGIN
    p_check_or_insert_student(101, NULL, NULL, NULL);
END;
/

PROMPT [1.2 - Case khong ton tai] Them moi SV
BEGIN
    p_check_or_insert_student(999, 'Test', 'Moi', 'Thu Duc');
END;
/

SELECT studentid, firstname, lastname, address
FROM student
WHERE studentid IN (101, 999)
ORDER BY studentid;

PROMPT
PROMPT ==================================================
PROMPT TEST BAI 2
PROMPT ==================================================
PROMPT [2.1] IF/ELSE so lop giao vien
BEGIN
    p_instructor_workload(1);
    p_instructor_workload(9999);
END;
/

PROMPT [2.2] CASE quy doi diem chu
BEGIN
    p_print_letter_grade(101, 1002);
    p_print_letter_grade(101, 9999);
    p_print_letter_grade(9999, 1002);
    p_print_letter_grade(130, 1001);
END;
/

PROMPT
PROMPT ==================================================
PROMPT TEST BAI 3
PROMPT ==================================================
PROMPT [3] Cursor long nhau
BEGIN
    p_course_class_report;
END;
/

PROMPT
PROMPT ==================================================
PROMPT TEST BAI 4
PROMPT ==================================================
PROMPT [4.1a] Test find_sname
DECLARE
    v_first  student.firstname%TYPE;
    v_last   student.lastname%TYPE;
BEGIN
    find_sname(101, v_first, v_last);
    DBMS_OUTPUT.PUT_LINE('find_sname(101) -> ' || v_first || ' ' || v_last);
END;
/

PROMPT [4.1b] Test print_student_name
BEGIN
    print_student_name(102);
END;
/

PROMPT [4.2] COST TRUOC KHI DISCOUNT
SELECT courseno, description, cost
FROM course
ORDER BY courseno;

BEGIN
    discount;
END;
/

PROMPT [4.2] COST SAU KHI DISCOUNT
SELECT courseno, description, cost
FROM course
ORDER BY courseno;

PROMPT [4.3] Test total_cost_for_student
SELECT total_cost_for_student(101) AS total_cost_sv_101 FROM dual;
SELECT total_cost_for_student(9999) AS total_cost_sv_9999 FROM dual;

PROMPT
PROMPT ==================================================
PROMPT TEST BAI 5
PROMPT ==================================================

PROMPT [5.1 - INSERT] TEST AUDIT TRIGGER COURSE
INSERT INTO course (courseno, description, cost, prerequisite)
VALUES (60, 'Cloud Basics', 460, NULL);
COMMIT;

SELECT courseno,
       created_by,
       TO_CHAR(created_date, 'DD/MM/YYYY HH24:MI:SS') AS created_date,
       modified_by,
       TO_CHAR(modified_date, 'DD/MM/YYYY HH24:MI:SS') AS modified_date
FROM course
WHERE courseno = 60;

PROMPT [5.1 - UPDATE] TEST AUDIT TRIGGER COURSE
UPDATE course
SET cost = 470
WHERE courseno = 60;
COMMIT;

SELECT courseno,
       created_by,
       TO_CHAR(created_date, 'DD/MM/YYYY HH24:MI:SS') AS created_date,
       modified_by,
       TO_CHAR(modified_date, 'DD/MM/YYYY HH24:MI:SS') AS modified_date,
       cost
FROM course
WHERE courseno = 60;

PROMPT [5.2 - CHAN QUA 3 LOP] TEST TRIGGER MAX ENROLLMENT
BEGIN
    INSERT INTO enrollment (studentid, classid, enrolldate, finalgrade)
    VALUES (101, 1007, SYSDATE, 88);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('FAIL: Trigger max enrollment khong chan insert vuot qua 3 lop.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PASS: Trigger max enrollment da chan. ' || SQLERRM);
        ROLLBACK;
END;
/

SELECT studentid, COUNT(*) AS so_lop
FROM enrollment
WHERE studentid = 101
GROUP BY studentid;

PROMPT [5.2 - CASE HOP LE] TEST ENROLLMENT TRIGGER AUDIT
BEGIN
    INSERT INTO enrollment (studentid, classid, enrolldate, finalgrade)
    VALUES (999, 1007, SYSDATE, 90);
    COMMIT;
END;
/

SELECT studentid,
       classid,
       created_by,
       TO_CHAR(created_date, 'DD/MM/YYYY HH24:MI:SS') AS created_date,
       modified_by,
       TO_CHAR(modified_date, 'DD/MM/YYYY HH24:MI:SS') AS modified_date
FROM enrollment
WHERE studentid = 999
ORDER BY classid;

PROMPT ==================================================
PROMPT HOAN TAT TEST BUOI 3
PROMPT Log chi tiet da luu tai TH_BUOI3/Test_BaiTH_Buoi3.log
PROMPT ==================================================

SPOOL OFF
EXIT
