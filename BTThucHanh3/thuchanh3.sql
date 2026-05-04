DROP TABLE DANH_MUC   CASCADE CONSTRAINTS PURGE;
DROP TABLE NHA_CUNG_CAP        CASCADE CONSTRAINTS PURGE;
DROP TABLE SAN_PHAM         CASCADE CONSTRAINTS PURGE;
DROP TABLE KHACH_HANG   CASCADE CONSTRAINTS PURGE;
DROP TABLE NHAN_VIEN   CASCADE CONSTRAINTS PURGE;
DROP TABLE DON_HANG    CASCADE CONSTRAINTS PURGE;
DROP TABLE CHI_TIET_DON_HANG         CASCADE CONSTRAINTS PURGE;
DROP TABLE NHAP_KHO     CASCADE CONSTRAINTS PURGE;

-- Bảng COURSE
CREATE TABLE COURSE (
    CourseNo        NUMBER(8,0)     NOT NULL,
    Description     VARCHAR2(50),
    Cost            NUMBER(9,2),
    Prerequisite    NUMBER(8,0),
    CreatedBy       VARCHAR2(30)    NOT NULL,
    CreatedDate     DATE            NOT NULL,
    ModifiedBy      VARCHAR2(30)    NOT NULL,
    ModifiedDate    DATE            NOT NULL,
    CONSTRAINT PK_COURSE PRIMARY KEY (CourseNo),
    CONSTRAINT FK_COURSE_PRE FOREIGN KEY (Prerequisite) REFERENCES COURSE(CourseNo)
);
 
-- Bảng INSTRUCTOR
CREATE TABLE INSTRUCTOR (
    InstructorID    NUMBER(8)       NOT NULL,
    Salutation      VARCHAR2(5),
    FirstName       VARCHAR2(25),
    LastName        VARCHAR2(25),
    Address         VARCHAR2(50),
    Phone           VARCHAR2(15),
    CreatedBy       VARCHAR2(30)    NOT NULL,
    CreatedDate     DATE            NOT NULL,
    ModifiedBy      VARCHAR2(30)    NOT NULL,
    ModifiedDate    DATE            NOT NULL,
    CONSTRAINT PK_INSTRUCTOR PRIMARY KEY (InstructorID)
);
 
-- Bảng CLASS
CREATE TABLE CLASS (
    ClassID         NUMBER(8,0)     NOT NULL,
    CourseNo        NUMBER(8,0)     NOT NULL,
    ClassNo         NUMBER(3)       NOT NULL,
    StartDateTime   DATE,
    Location        VARCHAR2(50),
    InstructorID    NUMBER(8,0)     NOT NULL,
    Capacity        NUMBER(3,0),
    CreatedBy       VARCHAR2(30)    NOT NULL,
    CreatedDate     DATE            NOT NULL,
    ModifiedBy      VARCHAR2(30)    NOT NULL,
    ModifiedDate    DATE            NOT NULL,
    CONSTRAINT PK_CLASS PRIMARY KEY (ClassID),
    CONSTRAINT FK_CLASS_COURSE     FOREIGN KEY (CourseNo)     REFERENCES COURSE(CourseNo),
    CONSTRAINT FK_CLASS_INSTRUCTOR FOREIGN KEY (InstructorID) REFERENCES INSTRUCTOR(InstructorID)
);
 
-- Bảng STUDENT
CREATE TABLE STUDENT (
    StudentID           NUMBER(8,0)     NOT NULL,
    Salutation          VARCHAR2(5),
    FirstName           VARCHAR2(25),
    LastName            VARCHAR2(25)    NOT NULL,
    Address             VARCHAR2(50),
    Phone               VARCHAR2(15),
    Employer            VARCHAR2(50),
    RegistrationDate    DATE            NOT NULL,
    CreatedBy           VARCHAR2(30)    NOT NULL,
    CreatedDate         DATE            NOT NULL,
    ModifiedBy          VARCHAR2(30)    NOT NULL,
    ModifiedDate        DATE            NOT NULL,
    CONSTRAINT PK_STUDENT PRIMARY KEY (StudentID)
);
 
-- Bảng ENROLLMENT
CREATE TABLE ENROLLMENT (
    StudentID           NUMBER(8,0)     NOT NULL,
    ClassID             NUMBER(8,0)     NOT NULL,
    EnrollDate          DATE            NOT NULL,
    FinalGrade          NUMBER(3,0),
    RegistrationDate    DATE            NOT NULL,
    CreatedBy           VARCHAR2(30)    NOT NULL,
    CreatedDate         DATE            NOT NULL,
    ModifiedBy          VARCHAR2(30)    NOT NULL,
    ModifiedDate        DATE            NOT NULL,
    CONSTRAINT PK_ENROLLMENT PRIMARY KEY (StudentID, ClassID),
    CONSTRAINT FK_ENROLL_STUDENT FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID),
    CONSTRAINT FK_ENROLL_CLASS   FOREIGN KEY (ClassID)   REFERENCES CLASS(ClassID)
);
 
-- Bảng GRADE
CREATE TABLE GRADE (
    StudentID       NUMBER(8)       NOT NULL,
    ClassID         NUMBER(8)       NOT NULL,
    Grade           NUMBER(3)       NOT NULL,
    Comments        VARCHAR2(2000),
    CreatedBy       VARCHAR2(30)    NOT NULL,
    CreatedDate     DATE            NOT NULL,
    ModifiedBy      VARCHAR2(30)    NOT NULL,
    ModifiedDate    DATE            NOT NULL,
    CONSTRAINT PK_GRADE PRIMARY KEY (StudentID, ClassID),
    CONSTRAINT FK_GRADE_STUDENT FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID),
    CONSTRAINT FK_GRADE_CLASS   FOREIGN KEY (ClassID)   REFERENCES CLASS(ClassID)
);

-- COURSE: Các môn học phổ biến tại các trường ĐH Việt Nam
INSERT INTO COURSE VALUES (10,  'Co So Du Lieu',             3500000, NULL, USER, SYSDATE, USER, SYSDATE);
INSERT INTO COURSE VALUES (20,  'Lap Trinh Huong Doi Tuong', 3500000, NULL, USER, SYSDATE, USER, SYSDATE);
INSERT INTO COURSE VALUES (25,  'Cau Truc Du Lieu & giai thuat',     3500000, 20,   USER, SYSDATE, USER, SYSDATE);
INSERT INTO COURSE VALUES (30,  'Mang May Tinh',             3500000, NULL, USER, SYSDATE, USER, SYSDATE);
INSERT INTO COURSE VALUES (40,  'Tri Tue Nhan Tao',          4000000, 25,   USER, SYSDATE, USER, SYSDATE);
INSERT INTO COURSE VALUES (50,  'Phat Trien Ung Dung Web',   4000000, 20,   USER, SYSDATE, USER, SYSDATE);
INSERT INTO COURSE VALUES (60,  'He Dieu Hanh',              3000000, NULL, USER, SYSDATE, USER, SYSDATE);
 
-- INSTRUCTOR: Giảng viên Việt Nam
INSERT INTO INSTRUCTOR VALUES (101, 'ThS.', 'Nguyen Van',  'An',     '12 Nguyen Hue, Q1, TP.HCM',      '0901234567', USER, SYSDATE, USER, SYSDATE);
INSERT INTO INSTRUCTOR VALUES (102, 'TS.',  'Tran Thi',    'Bich',   '45 Le Loi, Q3, TP.HCM',           '0912345678', USER, SYSDATE, USER, SYSDATE);
INSERT INTO INSTRUCTOR VALUES (103, 'PGS.', 'Le Van',      'Cuong',  '78 Hai Ba Trung, Hoan Kiem, HN',   '0923456789', USER, SYSDATE, USER, SYSDATE);
INSERT INTO INSTRUCTOR VALUES (104, 'ThS.', 'Pham Thi',    'Dung',   '22 Phan Chu Trinh, Hai Chau, DN',  '0934567890', USER, SYSDATE, USER, SYSDATE);
INSERT INTO INSTRUCTOR VALUES (105, 'TS.',  'Hoang Van',   'Em',     '99 Tran Phu, Nha Trang, KH',       '0945678901', USER, SYSDATE, USER, SYSDATE);
 
-- CLASS: Lớp học
INSERT INTO CLASS VALUES (1, 10,  1, TO_DATE('2024-09-02','YYYY-MM-DD'), 'Phong B101 - DHBK HCM',  101, 50, USER, SYSDATE, USER, SYSDATE);
INSERT INTO CLASS VALUES (2, 10,  2, TO_DATE('2024-09-02','YYYY-MM-DD'), 'Phong B102 - DHBK HCM',  102, 50, USER, SYSDATE, USER, SYSDATE);
INSERT INTO CLASS VALUES (3, 20,  1, TO_DATE('2024-09-03','YYYY-MM-DD'), 'Phong C201 - DHKHTN',    103, 45, USER, SYSDATE, USER, SYSDATE);
INSERT INTO CLASS VALUES (4, 20,  2, TO_DATE('2024-09-03','YYYY-MM-DD'), 'Phong C202 - DHKHTN',    104, 45, USER, SYSDATE, USER, SYSDATE);
INSERT INTO CLASS VALUES (5, 25,  1, TO_DATE('2024-09-04','YYYY-MM-DD'), 'Phong A301 - DHBK HN',   101, 40, USER, SYSDATE, USER, SYSDATE);
INSERT INTO CLASS VALUES (6, 30,  1, TO_DATE('2024-09-05','YYYY-MM-DD'), 'Phong D401 - DHCNTT',    102, 50, USER, SYSDATE, USER, SYSDATE);
INSERT INTO CLASS VALUES (7, 40,  1, TO_DATE('2024-09-06','YYYY-MM-DD'), 'Phong E501 - DHKHTN',    103, 35, USER, SYSDATE, USER, SYSDATE);
INSERT INTO CLASS VALUES (8, 50,  1, TO_DATE('2024-09-07','YYYY-MM-DD'), 'Phong F601 - DHCNTT',    104, 40, USER, SYSDATE, USER, SYSDATE);
INSERT INTO CLASS VALUES (9, 60,  1, TO_DATE('2024-09-08','YYYY-MM-DD'), 'Phong G701 - DHBK HCM',  105, 50, USER, SYSDATE, USER, SYSDATE);
 
-- STUDENT: Sinh viên Việt Nam
INSERT INTO STUDENT VALUES (2001, 'Anh', 'Nguyen Van',  'An',      '15 Le Thanh Ton, Q1, TP.HCM',       '0901112233', 'FPT Software',     TO_DATE('2022-09-01','YYYY-MM-DD'), USER, SYSDATE, USER, SYSDATE);
INSERT INTO STUDENT VALUES (2002, 'Chi', 'Tran Thi',    'Bao',     '23 Nguyen Dinh Chieu, Q3, TP.HCM',  '0912223344', 'Viettel',          TO_DATE('2022-09-01','YYYY-MM-DD'), USER, SYSDATE, USER, SYSDATE);
INSERT INTO STUDENT VALUES (2003, 'Anh', 'Le Van',      'Cuong',   '56 Dien Bien Phu, Binh Thanh, HCM', '0923334455', 'VinGroup',         TO_DATE('2022-09-01','YYYY-MM-DD'), USER, SYSDATE, USER, SYSDATE);
INSERT INTO STUDENT VALUES (2004, 'Chi', 'Pham Thi',    'Diem',    '88 Hoang Dieu, Hai Chau, DN',        '0934445566', 'VNG Corporation',  TO_DATE('2023-09-01','YYYY-MM-DD'), USER, SYSDATE, USER, SYSDATE);
INSERT INTO STUDENT VALUES (2005, 'Anh', 'Hoang Van',   'Duong',   '33 Tran Hung Dao, Hoan Kiem, HN',   '0945556677', 'VNPT',             TO_DATE('2023-09-01','YYYY-MM-DD'), USER, SYSDATE, USER, SYSDATE);
INSERT INTO STUDENT VALUES (2006, 'Chi', 'Vu Thi',      'Giang',   '12 Bach Dang, Son Tra, DN',          '0956667788', 'Momo',             TO_DATE('2023-09-01','YYYY-MM-DD'), USER, SYSDATE, USER, SYSDATE);
INSERT INTO STUDENT VALUES (2007, 'Anh', 'Dang Van',    'Hieu',    '77 Nguyen Hue, Nha Trang, KH',      '0967778899', 'Tiki',             TO_DATE('2023-09-01','YYYY-MM-DD'), USER, SYSDATE, USER, SYSDATE);
INSERT INTO STUDENT VALUES (2008, 'Chi', 'Bui Thi',     'Huong',   '45 Ly Thuong Kiet, Hoan Kiem, HN',  '0978889900', 'Shopee',           TO_DATE('2024-09-01','YYYY-MM-DD'), USER, SYSDATE, USER, SYSDATE);
INSERT INTO STUDENT VALUES (2009, 'Anh', 'Do Van',      'Khanh',   '19 Pham Van Dong, Son Tra, DN',      '0989990011', 'Lazada',           TO_DATE('2024-09-01','YYYY-MM-DD'), USER, SYSDATE, USER, SYSDATE);
INSERT INTO STUDENT VALUES (2010, 'Chi', 'Ngo Thi',     'Lan',     '66 Vo Thi Sau, Q3, TP.HCM',         '0990001122', 'Grab Vietnam',     TO_DATE('2024-09-01','YYYY-MM-DD'), USER, SYSDATE, USER, SYSDATE);
 
-- ENROLLMENT: Đăng kí môn học (mỗi sinh viên tối đa 3 môn)
INSERT INTO ENROLLMENT VALUES (2001, 1, SYSDATE, 85, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2001, 3, SYSDATE, 90, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2001, 5, SYSDATE, 78, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2002, 3, SYSDATE, 88, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2002, 4, SYSDATE, 92, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2002, 6, SYSDATE, 75, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2003, 1, SYSDATE, 70, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2003, 6, SYSDATE, 80, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2004, 2, SYSDATE, 65, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2004, 7, SYSDATE, 88, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2005, 3, SYSDATE, 95, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2005, 8, SYSDATE, 72, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2006, 4, SYSDATE, 83, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2007, 5, SYSDATE, 91, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2007, 9, SYSDATE, 77, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2008, 6, SYSDATE, 68, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2009, 7, SYSDATE, 55, SYSDATE, USER, SYSDATE, USER, SYSDATE);
INSERT INTO ENROLLMENT VALUES (2010, 8, SYSDATE, 96, SYSDATE, USER, SYSDATE, USER, SYSDATE);
 
-- GRADE
INSERT INTO GRADE VALUES (2001, 1, 85, 'Hoc tot, can phat huy',          USER, SYSDATE, USER, SYSDATE);
INSERT INTO GRADE VALUES (2001, 3, 90, 'Xuat sac',                        USER, SYSDATE, USER, SYSDATE);
INSERT INTO GRADE VALUES (2001, 5, 78, 'Kha',                             USER, SYSDATE, USER, SYSDATE);
INSERT INTO GRADE VALUES (2002, 3, 88, 'Tot, can co gang them',           USER, SYSDATE, USER, SYSDATE);
INSERT INTO GRADE VALUES (2002, 4, 92, 'Xuat sac, tiep tuc duy tri',      USER, SYSDATE, USER, SYSDATE);
INSERT INTO GRADE VALUES (2003, 1, 70, 'Trung binh kha',                  USER, SYSDATE, USER, SYSDATE);
INSERT INTO GRADE VALUES (2004, 2, 65, 'Can co gang hon',                 USER, SYSDATE, USER, SYSDATE);
INSERT INTO GRADE VALUES (2005, 3, 95, 'Xuat sac nhat lop',               USER, SYSDATE, USER, SYSDATE);
INSERT INTO GRADE VALUES (2007, 5, 91, 'Rat tot',                         USER, SYSDATE, USER, SYSDATE);
INSERT INTO GRADE VALUES (2010, 8, 96, 'Xuat sac, co nang khieu tot',     USER, SYSDATE, USER, SYSDATE);
 
COMMIT;

-- Câu 1a,b: Tạo bảng Cau1 và sequence Cau1Seq
CREATE TABLE Cau1 (
    ID      NUMBER,
    NAME    VARCHAR2(20)
);
 
CREATE SEQUENCE Cau1Seq
    START WITH 1
    INCREMENT BY 5
    NOCACHE;
 
-- Câu 1c -> 1j: Khối PL/SQL chính
DECLARE
    v_name  VARCHAR2(50);
    v_id    NUMBER;
BEGIN
    -- (d) Sinh viên đăng kí nhiều môn học nhất
    SELECT s.FirstName || ' ' || s.LastName
      INTO v_name
      FROM STUDENT s
     WHERE s.StudentID = (
               SELECT StudentID
                 FROM ENROLLMENT
                GROUP BY StudentID
                ORDER BY COUNT(*) DESC
                FETCH FIRST 1 ROWS ONLY
           );
    INSERT INTO Cau1 (ID, NAME) VALUES (Cau1Seq.NEXTVAL, v_name);
    SAVEPOINT A;
    DBMS_OUTPUT.PUT_LINE('(d) Da them SV nhieu mon nhat: ' || v_name);
 
    -- (e) Sinh viên đăng kí ít môn học nhất
    SELECT s.FirstName || ' ' || s.LastName
      INTO v_name
      FROM STUDENT s
     WHERE s.StudentID = (
               SELECT StudentID
                 FROM ENROLLMENT
                GROUP BY StudentID
                ORDER BY COUNT(*) ASC
                FETCH FIRST 1 ROWS ONLY
           );
    INSERT INTO Cau1 (ID, NAME) VALUES (Cau1Seq.NEXTVAL, v_name);
    SAVEPOINT B;
    DBMS_OUTPUT.PUT_LINE('(e) Da them SV it mon nhat: ' || v_name);
 
    -- (f) Giáo viên dạy nhiều môn học nhất
    SELECT i.FirstName || ' ' || i.LastName
      INTO v_name
      FROM INSTRUCTOR i
     WHERE i.InstructorID = (
               SELECT InstructorID
                 FROM CLASS
                GROUP BY InstructorID
                ORDER BY COUNT(DISTINCT CourseNo) DESC
                FETCH FIRST 1 ROWS ONLY
           );
    INSERT INTO Cau1 (ID, NAME) VALUES (Cau1Seq.NEXTVAL, v_name);
    SAVEPOINT C;
    DBMS_OUTPUT.PUT_LINE('(f) Da them GV nhieu mon nhat: ' || v_name);
 
    -- (g) SELECT INTO lấy ID giáo viên có tên tương ứng v_name
    SELECT i.InstructorID
      INTO v_id
      FROM INSTRUCTOR i
     WHERE i.FirstName || ' ' || i.LastName = v_name
       AND ROWNUM = 1;
    DBMS_OUTPUT.PUT_LINE('(g) ID cua giao vien ' || v_name || ' la: ' || v_id);
 
    -- (h) Rollback giáo viên vừa thêm về Savepoint B
    ROLLBACK TO SAVEPOINT B;
    DBMS_OUTPUT.PUT_LINE('(h) Da rollback giao vien ve Savepoint B');
 
    -- (i) Thêm giáo viên dạy ít môn nhất, dùng v_id (ID bị rollback trước đó)
    SELECT i.FirstName || ' ' || i.LastName
      INTO v_name
      FROM INSTRUCTOR i
     WHERE i.InstructorID = (
               SELECT InstructorID
                 FROM CLASS
                GROUP BY InstructorID
                ORDER BY COUNT(DISTINCT CourseNo) ASC
                FETCH FIRST 1 ROWS ONLY
           );
    INSERT INTO Cau1 (ID, NAME) VALUES (v_id, v_name);
    DBMS_OUTPUT.PUT_LINE('(i) Da them GV it mon nhat voi ID cu: ' || v_id || ' - ' || v_name);
 
    -- (j) Thêm lại giáo viên nhiều môn nhất với ID từ sequence
    SELECT i.FirstName || ' ' || i.LastName
      INTO v_name
      FROM INSTRUCTOR i
     WHERE i.InstructorID = (
               SELECT InstructorID
                 FROM CLASS
                GROUP BY InstructorID
                ORDER BY COUNT(DISTINCT CourseNo) DESC
                FETCH FIRST 1 ROWS ONLY
           );
    INSERT INTO Cau1 (ID, NAME) VALUES (Cau1Seq.NEXTVAL, v_name);
    DBMS_OUTPUT.PUT_LINE('(j) Da them lai GV nhieu mon nhat voi ID tu sequence: ' || v_name);
 
    COMMIT;
END;
/
 
-- Câu 2: Nhập mã sinh viên - tìm hoặc thêm mới
DECLARE
    v_studentid     STUDENT.StudentID%TYPE      := &p_studentid;
    v_firstname     STUDENT.FirstName%TYPE;
    v_lastname      STUDENT.LastName%TYPE;
    v_address       STUDENT.Address%TYPE;
    v_count_class   NUMBER;
BEGIN
    SELECT FirstName, LastName
      INTO v_firstname, v_lastname
      FROM STUDENT
     WHERE StudentID = v_studentid;
 
    SELECT COUNT(*)
      INTO v_count_class
      FROM ENROLLMENT
     WHERE StudentID = v_studentid;
 
    DBMS_OUTPUT.PUT_LINE('Ho ten sinh vien: ' || v_firstname || ' ' || v_lastname);
    DBMS_OUTPUT.PUT_LINE('So lop dang hoc : ' || v_count_class);
 
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        v_lastname  := '&p_lastname';
        v_firstname := '&p_firstname';
        v_address   := '&p_address';
 
        INSERT INTO STUDENT (StudentID, FirstName, LastName, Address,
                             RegistrationDate, CreatedBy, CreatedDate,
                             ModifiedBy, ModifiedDate)
        VALUES (v_studentid, v_firstname, v_lastname, v_address,
                SYSDATE, USER, SYSDATE, USER, SYSDATE);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Sinh vien chua ton tai. Da them moi: '
                             || v_firstname || ' ' || v_lastname);
END;
/
 
-- ============================================================
-- BÀI 2: CẤU TRÚC ĐIỀU KHIỂN
-- ============================================================
 
-- Câu 1: Kiểm tra số lớp giáo viên đang dạy
DECLARE
    v_instructorid  CLASS.InstructorID%TYPE := &p_instructorid;
    v_count_class   NUMBER;
    v_ten_gv        VARCHAR2(60);
BEGIN
    SELECT COUNT(*), MAX(i.LastName || ' ' || i.FirstName)
      INTO v_count_class, v_ten_gv
      FROM CLASS cl
      JOIN INSTRUCTOR i ON cl.InstructorID = i.InstructorID
     WHERE cl.InstructorID = v_instructorid;
 
    IF v_count_class >= 5 THEN
        DBMS_OUTPUT.PUT_LINE('Giao vien ' || v_ten_gv || ' nen nghi ngoi!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Giao vien ' || v_ten_gv
                             || ' dang day ' || v_count_class || ' lop.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Khong tim thay giao vien co ma: ' || v_instructorid);
END;
/
 
-- Câu 2: Điểm chữ sinh viên theo lớp (dùng CASE)
DECLARE
    v_studentid ENROLLMENT.StudentID%TYPE := &p_studentid;
    v_classid   ENROLLMENT.ClassID%TYPE   := &p_classid;
    v_grade     ENROLLMENT.FinalGrade%TYPE;
    v_letter    VARCHAR2(2);
    v_ten_sv    VARCHAR2(60);
BEGIN
    SELECT e.FinalGrade, s.LastName || ' ' || s.FirstName
      INTO v_grade, v_ten_sv
      FROM ENROLLMENT e
      JOIN STUDENT s ON e.StudentID = s.StudentID
     WHERE e.StudentID = v_studentid
       AND e.ClassID   = v_classid;
 
    v_letter := CASE
                    WHEN v_grade BETWEEN 90 AND 100 THEN 'A'
                    WHEN v_grade BETWEEN 80 AND 89  THEN 'B'
                    WHEN v_grade BETWEEN 70 AND 79  THEN 'C'
                    WHEN v_grade BETWEEN 50 AND 69  THEN 'D'
                    ELSE 'F'
                END;
 
    DBMS_OUTPUT.PUT_LINE('Sinh vien: ' || v_ten_sv);
    DBMS_OUTPUT.PUT_LINE('Ma lop   : ' || v_classid);
    DBMS_OUTPUT.PUT_LINE('Diem so  : ' || v_grade);
    DBMS_OUTPUT.PUT_LINE('Diem chu : ' || v_letter);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Loi: Ma sinh vien (' || v_studentid
                             || ') hoac ma lop (' || v_classid || ') khong ton tai!');
END;
/
 
-- ============================================================
-- BÀI 3: CURSOR
-- ============================================================
 
DECLARE
    CURSOR cur_course IS
        SELECT CourseNo, Description
          FROM COURSE
         ORDER BY CourseNo;
 
    CURSOR cur_class (p_courseno COURSE.CourseNo%TYPE) IS
        SELECT c.ClassID, COUNT(e.StudentID) AS so_sv
          FROM CLASS c
          LEFT JOIN ENROLLMENT e ON c.ClassID = e.ClassID
         WHERE c.CourseNo = p_courseno
         GROUP BY c.ClassID
         ORDER BY c.ClassID;
 
    v_courseno  COURSE.CourseNo%TYPE;
    v_desc      COURSE.Description%TYPE;
    v_classid   CLASS.ClassID%TYPE;
    v_count     NUMBER;
BEGIN
    OPEN cur_course;
    LOOP
        FETCH cur_course INTO v_courseno, v_desc;
        EXIT WHEN cur_course%NOTFOUND;
 
        DBMS_OUTPUT.PUT_LINE(v_courseno || ' ' || v_desc);
 
        OPEN cur_class(v_courseno);
        LOOP
            FETCH cur_class INTO v_classid, v_count;
            EXIT WHEN cur_class%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('  Lop: ' || v_classid
                                 || ' co so luong sinh vien dang ki: ' || v_count);
        END LOOP;
        CLOSE cur_class;
    END LOOP;
    CLOSE cur_course;
END;
/
 
-- ============================================================
-- BÀI 4: THỦ TỤC VÀ HÀM
-- ============================================================
 
-- 4.1a: Thủ tục find_sname
CREATE OR REPLACE PROCEDURE find_sname (
    i_student_id  IN  STUDENT.StudentID%TYPE,
    o_first_name  OUT STUDENT.FirstName%TYPE,
    o_last_name   OUT STUDENT.LastName%TYPE
)
IS
BEGIN
    SELECT FirstName, LastName
      INTO o_first_name, o_last_name
      FROM STUDENT
     WHERE StudentID = i_student_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        o_first_name := NULL;
        o_last_name  := NULL;
        DBMS_OUTPUT.PUT_LINE('Khong tim thay sinh vien co ma: ' || i_student_id);
END find_sname;
/
 
-- 4.1b: Thủ tục print_student_name
CREATE OR REPLACE PROCEDURE print_student_name (
    i_student_id IN STUDENT.StudentID%TYPE
)
IS
    v_first STUDENT.FirstName%TYPE;
    v_last  STUDENT.LastName%TYPE;
BEGIN
    find_sname(i_student_id, v_first, v_last);
    IF v_first IS NOT NULL OR v_last IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Ten sinh vien [' || i_student_id || ']: '
                             || v_last || ' ' || v_first);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Sinh vien ma ' || i_student_id || ' khong ton tai.');
    END IF;
END print_student_name;
/
 
-- Test thủ tục
BEGIN
    print_student_name(2001);
    print_student_name(9999);
END;
/
 
-- 4.2: Thủ tục Discount - giảm 5% học phí môn có > 15 sinh viên đăng kí
CREATE OR REPLACE PROCEDURE Discount
IS
    CURSOR cur_discount IS
        SELECT c.CourseNo, c.Description, COUNT(e.StudentID) AS so_sv
          FROM COURSE c
          JOIN CLASS cl      ON c.CourseNo  = cl.CourseNo
          JOIN ENROLLMENT e  ON cl.ClassID  = e.ClassID
         GROUP BY c.CourseNo, c.Description
        HAVING COUNT(e.StudentID) > 15;
BEGIN
    FOR rec IN cur_discount LOOP
        UPDATE COURSE
           SET Cost         = Cost * 0.95,
               ModifiedBy   = USER,
               ModifiedDate = SYSDATE
         WHERE CourseNo = rec.CourseNo;
 
        DBMS_OUTPUT.PUT_LINE('Da giam gia 5% mon: ' || rec.Description
                             || '  (So SV dang ki: ' || rec.so_sv || ')');
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Hoan tat giam gia hoc phi.');
END Discount;
/
 
-- 4.3: Hàm Total_cost_for_student
CREATE OR REPLACE FUNCTION Total_cost_for_student (
    i_student_id IN STUDENT.StudentID%TYPE
)
RETURN NUMBER
IS
    v_total NUMBER := 0;
    v_check NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_check
      FROM STUDENT WHERE StudentID = i_student_id;
 
    IF v_check = 0 THEN
        RETURN NULL;
    END IF;
 
    SELECT NVL(SUM(c.Cost), 0)
      INTO v_total
      FROM ENROLLMENT e
      JOIN CLASS cl  ON e.ClassID   = cl.ClassID
      JOIN COURSE c  ON cl.CourseNo = c.CourseNo
     WHERE e.StudentID = i_student_id;
 
    RETURN v_total;
END Total_cost_for_student;
/
 
-- Test hàm
BEGIN
    DBMS_OUTPUT.PUT_LINE('Tong hoc phi SV 2001 (Nguyen Van An): '
        || NVL(TO_CHAR(Total_cost_for_student(2001),'FM999,999,999'), 'NULL') || ' VND');
    DBMS_OUTPUT.PUT_LINE('Tong hoc phi SV 9999 (khong ton tai): '
        || NVL(TO_CHAR(Total_cost_for_student(9999)), 'NULL - Sinh vien khong ton tai'));
END;
/
 
-- ============================================================
-- BÀI 5: TRIGGER
-- ============================================================
 
-- 5.1a: Trigger bảng COURSE
CREATE OR REPLACE TRIGGER trg_course_audit
BEFORE INSERT OR UPDATE ON COURSE
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :NEW.CreatedBy   := USER;
        :NEW.CreatedDate := SYSDATE;
    END IF;
    :NEW.ModifiedBy   := USER;
    :NEW.ModifiedDate := SYSDATE;
END trg_course_audit;
/
 
-- 5.1b: Trigger bảng CLASS
CREATE OR REPLACE TRIGGER trg_class_audit
BEFORE INSERT OR UPDATE ON CLASS
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :NEW.CreatedBy   := USER;
        :NEW.CreatedDate := SYSDATE;
    END IF;
    :NEW.ModifiedBy   := USER;
    :NEW.ModifiedDate := SYSDATE;
END trg_class_audit;
/
 
-- 5.1c: Trigger bảng STUDENT
CREATE OR REPLACE TRIGGER trg_student_audit
BEFORE INSERT OR UPDATE ON STUDENT
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :NEW.CreatedBy   := USER;
        :NEW.CreatedDate := SYSDATE;
    END IF;
    :NEW.ModifiedBy   := USER;
    :NEW.ModifiedDate := SYSDATE;
END trg_student_audit;
/
 
-- 5.1d: Trigger bảng ENROLLMENT
CREATE OR REPLACE TRIGGER trg_enrollment_audit
BEFORE INSERT OR UPDATE ON ENROLLMENT
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :NEW.CreatedBy   := USER;
        :NEW.CreatedDate := SYSDATE;
    END IF;
    :NEW.ModifiedBy   := USER;
    :NEW.ModifiedDate := SYSDATE;
END trg_enrollment_audit;
/
 
-- 5.1e: Trigger bảng INSTRUCTOR
CREATE OR REPLACE TRIGGER trg_instructor_audit
BEFORE INSERT OR UPDATE ON INSTRUCTOR
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :NEW.CreatedBy   := USER;
        :NEW.CreatedDate := SYSDATE;
    END IF;
    :NEW.ModifiedBy   := USER;
    :NEW.ModifiedDate := SYSDATE;
END trg_instructor_audit;
/
 
-- 5.1f: Trigger bảng GRADE
CREATE OR REPLACE TRIGGER trg_grade_audit
BEFORE INSERT OR UPDATE ON GRADE
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :NEW.CreatedBy   := USER;
        :NEW.CreatedDate := SYSDATE;
    END IF;
    :NEW.ModifiedBy   := USER;
    :NEW.ModifiedDate := SYSDATE;
END trg_grade_audit;
/
 
-- 5.2: Trigger giới hạn mỗi sinh viên không được đăng kí quá 3 môn học
CREATE OR REPLACE TRIGGER trg_enrollment_limit
BEFORE INSERT ON ENROLLMENT
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM ENROLLMENT
     WHERE StudentID = :NEW.StudentID;
 
    IF v_count >= 3 THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Sinh vien ma ' || :NEW.StudentID
            || ' da dang ki du 3 mon hoc. Khong the dang ki them!'
        );
    END IF;
END trg_enrollment_limit;
/