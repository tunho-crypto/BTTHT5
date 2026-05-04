-- Câu1.1: Tạoviewvw_course_summary-thôngtintổngquanmônhọc
CREATEORREPLACEVIEWvw_course_summary AS
SELECT co.courseno,
co.description,
co.cost,
COUNT(DISTINCT cl.classid) AS so_lop,
COUNT(e.studentid) AS tong_sv
FROMcourse co
LEFT JOIN class cl ON co.courseno = cl.courseno
LEFT JOIN enrollment e ON cl.classid = e.classid
GROUPBYco.courseno, co.description, co.cost
ORDERBYtong_sv DESC;
-- Kiem tra view:
SELECT *FROMvw_course_summary;

-- Câu 1.2: Tạo view vw_student_status- thông tin sinh viên và tình trạng học tập
CREATEORREPLACEVIEWvw_student_status AS
SELECT s.studentid,
s.firstname | ' ' | s.lastname AS ho_ten,
COUNT(e.classid) AS so_lop_hoc,
NVL(SUM(co.cost), 0) AS tong_hoc_phi,
ROUND(AVG(e.finalgrade), 2) AS diem_tb
FROMstudent s
JOIN enrollment e ON s.studentid = e.studentid
JOIN class cl ON e.classid = cl.classid
JOIN course co ON cl.courseno = co.courseno
GROUPBYs.studentid, s.firstname, s.lastname
HAVINGCOUNT(e.classid) >= 1
ORDERBYs.studentid;
SELECT *FROMvw_student_status;

-- Câu 1.3: Tạo view vw_class_availability- lớp học còn chỗ trống
CREATEORREPLACEVIEWvw_class_availability AS
SELECT cl.classid,
cl.courseno,
co.description,
i.firstname | ' ' | i.lastname AS ten_giao_vien,
cl.capacity,
COUNT(e.studentid) AS so_da_dk,
cl.capacity- COUNT(e.studentid) AS cho_trong,
CASE
WHENcl.capacity- COUNT(e.studentid) > 0 THEN 'Con
cho' ELSE 'Het cho'
ENDAStrang_thai
FROMclass cl
JOIN course co ON cl.courseno = co.courseno
JOIN instructor i ON cl.instructorid = i.instructorid
LEFT JOIN enrollment e ON cl.classid = e.classid
GROUPBYcl.classid, cl.courseno, co.description,
i.firstname, i.lastname, cl.capacity
HAVINGcl.capacity- COUNT(e.studentid) > 0
ORDERBYcl.classid;
SELECT *FROMvw_class_availability;

-- Câu 1.4: Tạo view vw_top_courses- chỉ đọc, top 5 môn được đăng ký nhiều nhất
CREATEORREPLACEVIEWvw_top_courses AS
SELECT courseno, description, cost, tong_dk, hang
FROM(
SELECT co.courseno,
co.description,
co.cost,
COUNT(e.studentid) AS tong_dk,
RANK() OVER(ORDERBYCOUNT(e.studentid) DESC) AS
hang FROMcourse co
LEFT JOIN class cl ON co.courseno = cl.courseno
LEFT JOIN enrollment e ON cl.classid = e.classid
GROUPBYco.courseno, co.description, co.cost
)
WHEREhang<=5
ORDERBYhang
WITHREADONLY;
SELECT *FROMvw_top_courses;-- Thu INSERT vao view nay (se bao loi ORA-42399):
INSERT INTO vw_top_courses (courseno, description, cost)
VALUES(999, 'Test', 100);-- Oracle bao: ORA-42399: cannot perform a DML operation on a read only view

-- Câu 1.5: Tạo view vw_pending_enrollment với WITH CHECK OPTION và kiểm tra
CREATEORREPLACEVIEWvw_pending_enrollment AS
SELECT studentid, classid, enrolldate, finalgrade,
createdby, createddate, modifiedby, modifieddate
FROMenrollment
WHEREfinalgrade IS NULL
WITHCHECKOPTION;
SELECT *FROMvw_pending_enrollment;-- INSERT 1: FinalGrade = NULL-> THANH CONG (thoa dieu
kien WHERE)
INSERT INTO vw_pending_enrollment
(studentid, classid, enrolldate, createdby, createddate,
modifiedby, modifieddate)
VALUES(999, 1, SYSDATE, USER, SYSDATE, USER, SYSDATE);-- INSERT 2: FinalGrade = 85-> LOI ORA-01402 (vi pham WITH
CHECK OPTION)
INSERT INTO vw_pending_enrollment
(studentid, classid, enrolldate, finalgrade,
createdby, createddate, modifiedby, modifieddate)
VALUES(998, 1, SYSDATE, 85, USER, SYSDATE, USER, SYSDATE);-- ORA-01402: view WITH CHECK OPTION where-clause violation

-- Câu 2.1: Thủ tục enroll_student- đăng ký sinh viên vào lớp học
CREATEORREPLACEPROCEDUREenroll_student
(p_studentid IN NUMBER,
p_classid IN NUMBER)
IS
v_check NUMBER;
v_capacity NUMBER;
v_enrolled NUMBER;
BEGIN-- DK1: Sinh vien phai ton tai
SELECT COUNT(*) INTO v_check FROM student WHERE
studentid = p_studentid;
IF v_check = 0 THEN
DBMS_OUTPUT.PUT_LINE('[LOI] Sinh vien ' | p_studentid | '
khong ton tai!');
RETURN;
ENDIF;-- DK2: Lop hoc phai ton tai
SELECT COUNT(*) INTO v_check FROM classWHERE
classid = p_classid;
IF v_check = 0 THEN
DBMS_OUTPUT.PUT_LINE('[LOI] Lop hoc ' | p_classid | ' khong
ton tai!');
RETURN;
ENDIF;
-- DK3: Kiem tra con cho trong
SELECT capacity INTO v_capacity FROM class WHERE
classid = p_classid;
SELECT COUNT(*) INTO v_enrolled FROM enrollment WHERE
classid = p_classid;
IF v_enrolled >= v_capacity THEN
DBMS_OUTPUT.PUT_LINE('[LOI] Lop ' | p_classid | ' da day!
(' | v_enrolled | '/' | v_capacity | ')');
RETURN;
ENDIF;-- DK4: Sinh vien chua dang ky lop nay
SELECT COUNT(*) INTO v_check FROMenrollment
WHEREstudentid = p_studentid AND classid =
p_classid; IF v_check > 0 THEN
DBMS_OUTPUT.PUT_LINE('[LOI] Sinh vien da dang ky lop nay
roi!'); RETURN;
ENDIF;-- DK5: Sinh vien chua qua 3 lop
SELECT COUNT(*) INTO v_check FROM enrollment WHERE
studentid = p_studentid;
IF v_check >= 3 THEN
DBMS_OUTPUT.PUT_LINE('[LOI] Sinh vien da dang ky du 3
lop!'); RETURN;
ENDIF;-- Tat ca OK: INSERT
INSERT INTOenrollment
(studentid, classid, enrolldate, createdby, createddate,
modifiedby, modifieddate);
VALUES
(p_studentid, p_classid, SYSDATE, USER, SYSDATE,
USER, SYSDATE);
COMMIT;
DBMS_OUTPUT.PUT_LINE('[OK] Dang ky thanh cong! SV ' |
p_studentid | '-> Lop ' | p_classid);
EXCEPTION
WHENOTHERSTHEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE('[LOI HE THONG] ' | SQLERRM);
ENDenroll_student;
/-- Kiem tra:
BEGIN
enroll_student(101, 5);-- Hop le
enroll_student(999, 5);-- SV khong ton tai
enroll_student(101, 999);-- Lop khong ton tai
END;
/

-- Câu 2.2: Thủ tục update_final_grade- cập nhật điểm tổng kết
CREATEORREPLACEPROCEDUREupdate_final_grade
(p_studentid IN NUMBER,
p_classid IN NUMBER,
p_grade IN NUMBER)
IS
v_check NUMBER;
v_old_grade NUMBER;
BEGIN-- Kiem tra diem hop le
IF p_grade < 0 OR p_grade > 100 THEN
DBMS_OUTPUT.PUT_LINE('[LOI] Diem khong hop le! Phai tu 0
den 100.');
RETURN;
ENDIF;-- Kiem tra cap (StudentID, ClassID) ton tai trong
ENROLLMENT SELECTCOUNT(*)INTOv_checkFROM
enrollment
WHEREstudentid = p_studentid AND classid = p_classid;
IF v_check = 0 THEN
DBMS_OUTPUT.PUT_LINE('[LOI] Sinh vien chua dang ky lop
nay!'); RETURN;
ENDIF;
-- Luu diem cu
SELECT finalgrade INTO v_old_grade FROM enrollment
WHEREstudentid = p_studentid AND classid = p_classid;
-- Cap nhat
ENROLLMENT
UPDATEenrollment
SET finalgrade = p_grade,
modifiedby = USER, modifieddate = SYSDATE
WHEREstudentid = p_studentid AND classid = p_classid;-- Dong bo sang bang GRADE bang MERGE INTO
MERGEINTOgradeg
USING(SELECT p_studentid AS sid, p_classid AS cid FROM DUAL)
src ON (g.studentid = src.sid AND g.classid = src.cid)
WHENMATCHEDTHEN
UPDATESETg.grade = p_grade,
g.modifiedby = USER, g.modifieddate = SYSDATE
WHENNOTMATCHEDTHEN
INSERT (studentid, classid, grade, createdby, createddate,
modifiedby, modifieddate)
VALUES(p_studentid, p_classid, p_grade,
USER, SYSDATE, USER, SYSDATE);
COMMIT;
DBMS_OUTPUT.PUT_LINE('[OK] Da cap nhat diem SV ' |
p_studentid | ' lop ' | p_classid
| ': Cu=' | NVL(TO_CHAR(v_old_grade),'NULL') | '->
Moi=' | p_grade);
EXCEPTION
WHENOTHERSTHEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE('[LOI] ' | SQLERRM);
ENDupdate_final_grade;

-- Câu 2.3: Thủ tục transfer_student- chuyển lớp cho sinh viên
CREATEORREPLACEPROCEDUREtransfer_student
(p_studentid IN NUMBER,
p_old_classid IN NUMBER,
p_new_classid IN NUMBER)
IS
v_check NUMBER;
v_capacity NUMBER;
v_enrolled NUMBER;
BEGIN-- DK1: Sinh vien dang hoc o lop cu
SELECT COUNT(*) INTO v_check FROMenrollment
WHEREstudentid = p_studentid AND classid =
p_old_classid; IF v_check = 0 THEN
DBMS_OUTPUT.PUT_LINE('[LOI] Sinh vien khong dang hoc lop '
| p_old_classid);
RETURN;
ENDIF;-- DK2: Lop moi con cho trong
SELECT capacity INTO v_capacity FROM class WHERE
classid = p_new_classid;
SELECT COUNT(*) INTO v_enrolled FROM enrollment WHERE
classid = p_new_classid;
IF v_enrolled >= v_capacity THEN
DBMS_OUTPUT.PUT_LINE('[LOI] Lop moi ' | p_new_classid | '
da day!');
RETURN;
ENDIF;
-- DK3: Sinh vien chua dang ky lop moi
SELECT COUNT(*) INTO v_check FROM
enrollment WHERE studentid = p_studentid AND classid =
p_new_classid; IF v_check > 0 THEN
DBMS_OUTPUT.PUT_LINE('[LOI] Sinh vien da o trong lop moi
roi!'); RETURN;
ENDIF;-- Tat ca OK: thuc hien chuyen lop
SAVEPOINT sp_truoc_chuyen;-- Buoc 1: Xoa khoi lop cu
DELETE FROMenrollment
WHEREstudentid = p_studentid AND classid =
p_old_classid; SAVEPOINT sp_sau_xoa;-- Buoc 2: Them vao lop moi
INSERT INTOenrollment
(studentid, classid, enrolldate, createdby,
createddate, modifiedby, modifieddate)
VALUES
(p_studentid, p_new_classid, SYSDATE, USER, SYSDATE,
USER, SYSDATE);
COMMIT;
DBMS_OUTPUT.PUT_LINE('[OK] Da chuyen SV ' |
p_studentid | ' tu lop ' | p_old_classid
| ' sang lop ' | p_new_classid);
EXCEPTION
WHENOTHERSTHEN
ROLLBACKTOsp_truoc_chuyen;
DBMS_OUTPUT.PUT_LINE('[LOI] Chuyen lop that bai: ' |
SQLERRM); DBMS_OUTPUT.PUT_LINE('Da rollback ve trang thai ban
dau.'); END transfer_student;
/

-- Câu 2.4: Thủ tục report_class_detail — in báo cáo chi tiết lớp học
CREATEORREPLACEPROCEDUREreport_class_detail
(p_classid IN NUMBER)
IS
v_check NUMBER;
v_course VARCHAR2(50);
v_courseno NUMBER;
v_gv VARCHAR2(50);
v_loc VARCHAR2(50);
v_cap NUMBER;
v_stt NUMBER := 0;
v_tong NUMBER := 0;
v_sum_d NUMBER:= 0;
v_co_d NUMBER:=0;
v_grade_txt VARCHAR2(15);
BEGIN-- Kiem tra lop ton tai
SELECT COUNT(*) INTO v_check FROM classWHERE
classid = p_classid;
IF v_check = 0 THEN
DBMS_OUTPUT.PUT_LINE('Lop hoc ' | p_classid | ' khong ton tai!');
RETURN;
ENDIF;-- Lay thong tin lop
SELECT co.description, co.courseno,
i.firstname | ' ' | i.lastname,
cl.location, cl.capacity
INTO v_course, v_courseno, v_gv, v_loc, v_cap
FROMclass cl
JOIN course co ON cl.courseno = co.courseno
JOIN instructor i ON cl.instructorid =
i.instructorid WHERE cl.classid = p_classid;
-- In header bao cao
DBMS_OUTPUT.PUT_LINE('=== BAO CAOLOP HOC: ' | p_classid
| ' ===');
DBMS_OUTPUT.PUT_LINE('Mon hoc : ' | v_courseno | '- ' |
v_course); DBMS_OUTPUT.PUT_LINE('Giao vien: ' | v_gv);
DBMS_OUTPUT.PUT_LINE('Phong hoc: ' | NVL(v_loc, 'Chua
xep phong'));
DBMS_OUTPUT.PUT_LINE('Suc chua : ' | v_cap | '
cho'); DBMS_OUTPUT.PUT_LINE(RPAD('-',50,'-'));
DBMS_OUTPUT.PUT_LINE('DANH SACHSINH
VIEN:'); DBMS_OUTPUT.PUT_LINE(RPAD('STT',4) | ' | ' |
RPAD('Ho Ten',20) | ' | ' | LPAD('Diem TK',8) | ' | Xep loai');
DBMS_OUTPUT.PUT_LINE(RPAD('-',50,'-'));-- Duyet danh sach sinh vien
FORrec IN (
SELECT s.firstname | ' ' | s.lastname AS ho_ten,
e.finalgrade
FROMenrollment e
JOIN student s ON e.studentid =
s.studentid WHERE e.classid = p_classid
ORDERBYs.lastname, s.firstname
) LOOP
v_stt := v_stt + 1;
v_tong := v_tong + 1;-- Xep loai
IF rec.finalgrade IS NULL THEN
v_grade_txt := 'Chua co diem';
ELSIF rec.finalgrade >= 90 THEN
v_grade_txt := 'A';
v_sum_d := v_sum_d + rec.finalgrade; v_co_d := v_co_d +
1; ELSIF rec.finalgrade >= 80 THEN
v_grade_txt := 'B';
v_sum_d := v_sum_d + rec.finalgrade; v_co_d := v_co_d +
1; ELSIF rec.finalgrade >= 70 THEN
v_grade_txt := 'C';
v_sum_d := v_sum_d + rec.finalgrade; v_co_d := v_co_d +
1; ELSIF rec.finalgrade >= 50 THEN
v_grade_txt := 'D';
v_sum_d := v_sum_d + rec.finalgrade; v_co_d := v_co_d +
1; ELSE
v_grade_txt := 'F';
v_sum_d := v_sum_d + rec.finalgrade; v_co_d := v_co_d +
1; ENDIF;
DBMS_OUTPUT.PUT_LINE(
LPAD(v_stt, 3) | ' | '
RPAD(rec.ho_ten, 20) | ' | '
| LPAD(NVL(TO_CHAR(rec.finalgrade),'NULL'), 7) | ' | ' |
v_grade_txt
);
ENDLOOP;-- In footer bao cao
DBMS_OUTPUT.PUT_LINE(RPAD('-',50,'-'));
DBMS_OUTPUT.PUT_LINE('Tong so sinh vien : ' | v_tong);
IF v_co_d > 0 THEN
DBMS_OUTPUT.PUT_LINE('Diem trung binh lop: '
| ROUND(v_sum_d / v_co_d, 2));
ELSE
DBMS_OUTPUT.PUT_LINE('Diem trung binh lop: Chua co
diem'); END IF;
ENDreport_class_detail;
/-- Goi thu tuc:
BEGIN
report_class_detail(1);
END;
/

-- Câu 2.5: Thủ tục sync_grade_from_enrollment- đồng bộ điểm từ ENROLLMENT sangGRADE
CREATEORREPLACEPROCEDURE
sync_grade_from_enrollment IS
v_check NUMBER;
v_dem_insert NUMBER := 0;
v_dem_update NUMBER := 0;
BEGIN
FORrec IN (
SELECT studentid, classid, finalgrade
FROMenrollment
WHEREfinalgrade IS NOT NULL
) LOOP-- Kiem tra trong GRADE da co chua
SELECT COUNT(*) INTO v_check FROMgrade
WHEREstudentid = rec.studentid AND classid = rec.classid;
IF v_check = 0 THEN-- Chua co-> INSERT moi
INSERT INTOgrade
(studentid, classid, grade, createdby, createddate,
modifiedby, modifieddate)
VALUES
(rec.studentid, rec.classid, rec.finalgrade,
USER, SYSDATE, USER, SYSDATE);
v_dem_insert := v_dem_insert + 1;
ELSE-- Da co-> UPDATE
UPDATEgrade
rec.finalgrade,
modifiedby = USER, modifieddate = SYSDATE
WHEREstudentid = rec.studentid AND classid =
rec.classid; v_dem_update := v_dem_update + 1;
ENDIF;
ENDLOOP;
COMMIT;
DBMS_OUTPUT.PUT_LINE('[OK] Dong bo hoan tat!');
DBMS_OUTPUT.PUT_LINE(' So ban ghi INSERT moi : '
| v_dem_insert);
DBMS_OUTPUT.PUT_LINE(' So ban ghi UPDATE : ' |
v_dem_update);
EXCEPTION
WHENOTHERSTHEN
ROLLBACK;
DBMS_OUTPUT.PUT_LINE('[LOI] ' | SQLERRM);
ENDsync_grade_from_enrollment;
/
BEGINsync_grade_from_enrollment; END; /

-- Câu 3.1: Trigger trg_check_capacity- kiểm tra sức chứa khi đăng ký
CREATEORREPLACETRIGGERtrg_check_capacity
BEFOREINSERT ONenrollment
FOREACHROW
DECLARE
v_capacity NUMBER;
v_enrolled NUMBER;
BEGIN-- Lay suc chua lop hoc
SELECT capacity INTO v_capacity
FROMclass WHERE classid = :NEW.classid;-- Dem so SV hien da dang ky
SELECT COUNT(*) INTO v_enrolled
FROMenrollment WHERE classid = :NEW.classid;-- Tu choi neu lop da day
IF v_enrolled >= v_capacity THEN
RAISE_APPLICATION_ERROR(-20010,
'LOI: Lop ' | :NEW.classid | ' da day! ('
| v_enrolled | '/' | v_capacity | ' cho)'
);
ENDIF;
ENDtrg_check_capacity;
/
-- Kiem tra trigger (dang ky vao lop da day):
INSERT INTO enrollment
(studentid, classid, enrolldate, createdby, createddate,
modifiedby, modifieddate)
VALUES(999, 1, SYSDATE, USER, SYSDATE, USER, SYSDATE);

-- Câu 3.2: Trigger trg_grade_audit_log- ghi nhật ký thay đổi điểm
CREATETABLEgrade_audit_log (
log_id NUMBER GENERATED ALWAYSAS
IDENTITY, studentid NUMBER(8),
classid NUMBER(8),
grade_cu NUMBER(3),
grade_moi NUMBER(3),
nguoi_sua VARCHAR2(30),
thoi_gian DATE
);
/
CREATEORREPLACETRIGGERtrg_grade_audit_log
AFTERUPDATEOFfinalgrade ON enrollment
FOREACHROW
BEGIN-- Chi ghi log khi diem THUC SU thay doi
IF (:OLD.finalgrade IS NULL AND :NEW.finalgrade IS NOT
NULL) OR(:OLD.finalgrade IS NOT NULL AND :NEW.finalgrade
IS NULL)
OR(:OLD.finalgrade != :NEW.finalgrade)
THEN
INSERT INTOgrade_audit_log
(studentid, classid, grade_cu, grade_moi, nguoi_sua,
thoi_gian) VALUES
(:OLD.studentid, :OLD.classid, :OLD.finalgrade,
:NEW.finalgrade, USER, SYSDATE);
ENDIF;
ENDtrg_grade_audit_log;
/-- Kiem tra trigger:
UPDATEenrollment SET finalgrade = 85
WHEREstudentid = 101 AND classid = 1;
COMMIT;
SELECT *FROMgrade_audit_log;

-- Câu 3.3: Trigger trg_prevent_course_delete- ngăn xóa môn học đang có lớp
CREATEORREPLACETRIGGERtrg_prevent_course_delete
BEFOREDELETEONcourse
FOREACHROW
DECLARE
v_so_lop NUMBER;
BEGIN
SELECT COUNT(*) INTO v_so_lop
FROMclass WHERE courseno = :OLD.courseno;
IF v_so_lop > 0 THEN
RAISE_APPLICATION_ERROR(-20020,
'Khong the xoa mon hoc ' | :OLD.courseno |
' (' | :OLD.description | ') ' |
'vi con ' | v_so_lop | ' lop hoc dang ton tai!'
);
ENDIF;-- Neu v_so_lop = 0: trigger ket thuc binh thuong, Oracle tien hanh
xoa END trg_prevent_course_delete;
/-- Kiem tra: xoa mon co lop (se bao loi)
DELETE FROMcourseWHEREcourseno = 10;-- Kiem tra: xoa mon khong co lop (thanh cong)
DELETE FROMcourseWHEREcourseno = 999;-- Mon khong co
lop nao ROLLBACK;

-- Câu 3.4: Trigger trg_update_grade_summary- cập nhật bảng thống kê tự động
CREATETABLEclass_grade_summary (
classid NUMBER(8) PRIMARY KEY,
so_sv NUMBER,
diem_tb NUMBER(5,2),
diem_cao_nhat NUMBER(3),
diem_thap_nhat NUMBER(3),
cap_nhat_luc DATE
);
/
CREATEORREPLACETRIGGER
trg_update_grade_summary AFTER INSERT OR
UPDATEORDELETEONenrollment FOREACHROW
DECLARE
v_classid NUMBER;
v_so_sv NUMBER;
v_diem_tb NUMBER;
v_max_d NUMBER;
v_min_d NUMBER;
BEGIN-- Lay ClassID dua tren loai su kien
IF INSERTING OR UPDATINGTHEN
v_classid := :NEW.classid;
ELSE-- DELETING
v_classid := :OLD.classid;
ENDIF;-- Tinh lai thong ke cho lop bi anh huong
SELECT COUNT(finalgrade),
ROUND(AVG(finalgrade), 2),
MAX(finalgrade),
MIN(finalgrade)
INTO v_so_sv, v_diem_tb, v_max_d,
v_min_d FROMenrollment
WHERE
classid = v_classid AND finalgrade IS NOT NULL;-- MERGEINTOcapnhat hoac them moi
MERGEINTOclass_grade_summary cgs
USING(SELECT v_classid AS cid FROM DUAL) src
ON(cgs.classid = src.cid)
WHENMATCHEDTHEN
UPDATESET
so_sv = v_so_sv,
diem_tb = v_diem_tb,
diem_cao_nhat = v_max_d,
diem_thap_nhat = v_min_d,
cap_nhat_luc = SYSDATE
WHENNOTMATCHEDTHEN
INSERT (classid, so_sv, diem_tb, diem_cao_nhat,
diem_thap_nhat, cap_nhat_luc)
VALUES(v_classid, v_so_sv, v_diem_tb, v_max_d,
v_min_d, SYSDATE);
ENDtrg_update_grade_summary;
/-- Kiem tra trigger:
UPDATEenrollment SET finalgrade = 90 WHERE studentid=101
AND classid=1;
COMMIT;
SELECT *FROMclass_grade_summary WHERE classid = 1;

-- Câu 4.1: Hệ thống báo cáo hoàn chỉnh- View + Procedure + Cursor
CREATEORREPLACEVIEWvw_instructor_workload AS
SELECT i.instructorid,
i.firstname | ' ' | i.lastname AS ho_ten,
COUNT(DISTINCT cl.classid) AS so_lop,
COUNT(e.studentid) AS tong_sv,
ROUND(AVG(e.finalgrade), 2) AS
diem_tb_chung, CASE
WHENCOUNT(DISTINCTcl.classid) >= 3 THEN 'Ban
nhieu' WHEN COUNT(DISTINCT cl.classid) = 2 THEN 'Binh
thuong' ELSE 'Nhe nhang'
ENDASmuc_ban
FROMinstructor i
LEFT JOIN class cl ON i.instructorid = cl.instructorid
LEFT JOIN enrollment e ON cl.classid = e.classid
GROUPBYi.instructorid, i.firstname, i.lastname
ORDERBYso_lop DESC;
SELECT *FROMvw_instructor_workload;

CREATEORREPLACEPROCEDUREprint_system_report
IS
v_so_mon NUMBER;
v_so_lop NUMBER;
v_so_sv NUMBER;
v_so_gv NUMBER;
BEGIN-- Lay so lieu tong the
SELECT COUNT(*) INTO v_so_mon FROMcourse;
SELECT COUNT(*) INTO v_so_lop FROM class;
SELECT COUNT(*) INTO v_so_sv FROM student;
SELECT COUNT(*) INTO v_so_gv FROM instructor;-- In header
DBMS_OUTPUT.PUT_LINE('==============================
==== ==========');
DBMS_OUTPUT.PUT_LINE(' BAO CAOTOAN HETHONGQUAN
LY KHOAHOC');
DBMS_OUTPUT.PUT_LINE('==============================
==== ==========');
DBMS_OUTPUT.PUT_LINE('Tong so mon hoc : ' |
v_so_mon); DBMS_OUTPUT.PUT_LINE('Tong so lop hoc : '
| v_so_lop); DBMS_OUTPUT.PUT_LINE('Tong so sinh vien:
' | v_so_sv); DBMS_OUTPUT.PUT_LINE('Tong so giao vien:
' | v_so_gv); DBMS_OUTPUT.PUT_LINE(RPAD('-',50,'-'));-- Phan 1: Thong ke giao vien (dung view
vw_instructor_workload) DBMS_OUTPUT.PUT_LINE('THON
GKEGIAOVIEN:'); FORrec IN (SELECT * FROM
vw_instructor_workload)
LOOP DBMS_OUTPUT.PUT_LINE(
' ' | RPAD(rec.ho_ten, 25)
| ' | ' | LPAD(rec.so_lop, 2) | ' lop'
| ' | ' | LPAD(rec.tong_sv, 3) | ' SV'
| ' | DTB: ' | NVL(TO_CHAR(rec.diem_tb_chung),'--')
rec.muc_ban
);
ENDLOOP;
DBMS_OUTPUT.PUT_LINE(RPAD('-',50,'-'));-- Phan 2: Top 3 mon hoc (dung view vw_top_courses)
DBMS_OUTPUT.PUT_LINE('TOP 3 MONHOCDUOCDANG
KY NHIEUNHAT:');
FORrec IN (SELECT * FROMvw_top_courses WHERE hang <= 3)
LOOP DBMS_OUTPUT.PUT_LINE(
' ' | rec.hang | '. '
| RPAD(rec.description, 30)
| '- ' | rec.tong_dk | ' luot dang ky'
);
ENDLOOP;
DBMS_OUTPUT.PUT_LINE('==============================
==============');
ENDprint_system_report;
/--Chaybaocao:
SETSERVEROUTPUTONSIZE1000000;
BEGINprint_system_report;END;
/

