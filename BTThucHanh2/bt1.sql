-- A2. CSDL QUAN LY DE AN CONG TY

BEGIN EXECUTE IMMEDIATE 'DROP TABLE PHANCONG CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE THANNHAN CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE DEAN CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE NHANVIEN CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE PHONGBAN CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE DIADIEM_PHG CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

DROP TABLE PHONGBAN  CASCADE CONSTRAINTS PURGE;
DROP TABLE NHANVIEN     CASCADE CONSTRAINTS PURGE;
DROP TABLE DIADIEM_PHG     CASCADE CONSTRAINTS PURGE;
DROP TABLE DEAN         CASCADE CONSTRAINTS PURGE;
DROP TABLE PHANCONG     CASCADE CONSTRAINTS PURGE;
DROP TABLE THANNHAN     CASCADE CONSTRAINTS PURGE;

-- Tạo bảng PHONGBAN (Phòng ban)
CREATE TABLE PHONGBAN (
    MAPHONG     NUMBER(2)       NOT NULL,
    TENPHONG    NVARCHAR2(30),
    TRUONGPHONG NUMBER(9),          -- FK -> NHANVIEN (thêm sau)
    NGAYBD      DATE,               -- Ngày bắt đầu làm trưởng phòng
    CONSTRAINT PK_PHONGBAN PRIMARY KEY (MAPHONG)
);
 
-- Tạo bảng NHANVIEN (Nhân viên)
CREATE TABLE NHANVIEN (
    MANV        NUMBER(9)       NOT NULL,
    HONV        NVARCHAR2(30),
    TENLOT      NVARCHAR2(15),
    TENNV       NVARCHAR2(10),
    NGAYSINH    DATE,
    DIACHI      NVARCHAR2(50),
    PHAI        NVARCHAR2(3),
    LUONG       NUMBER(10,2),
    MA_NQL      NUMBER(9),          -- Mã người quản lý (tự tham chiếu)
    MAPHONG     NUMBER(2),          -- FK -> PHONGBAN
    CONSTRAINT PK_NHANVIEN PRIMARY KEY (MANV),
    CONSTRAINT FK_NV_NGUOIQL FOREIGN KEY (MA_NQL)  REFERENCES NHANVIEN(MANV),
    CONSTRAINT FK_NV_PHONGBAN FOREIGN KEY (MAPHONG) REFERENCES PHONGBAN(MAPHONG)
);
 
-- Thêm FK trưởng phòng sau khi tạo NHANVIEN
ALTER TABLE PHONGBAN
    ADD CONSTRAINT FK_PB_TRUONGPHONG FOREIGN KEY (TRUONGPHONG) REFERENCES NHANVIEN(MANV);
 
-- Tạo bảng DIADIEM_PHG (Địa điểm phòng ban)
CREATE TABLE DIADIEM_PHG (
    MAPHONG     NUMBER(2)       NOT NULL,
    DIADIEM     NVARCHAR2(30)   NOT NULL,
    CONSTRAINT PK_DIADIEM_PHG PRIMARY KEY (MAPHONG, DIADIEM),
    CONSTRAINT FK_DD_PHONGBAN FOREIGN KEY (MAPHONG) REFERENCES PHONGBAN(MAPHONG)
);
 
-- Tạo bảng DEAN (Đề án)
CREATE TABLE DEAN (
    MADA        NUMBER(5)       NOT NULL,
    TENDA       NVARCHAR2(50),
    DIADIEM     NVARCHAR2(30),
    MAPHONG     NUMBER(2),          -- Phòng phụ trách
    CONSTRAINT PK_DEAN PRIMARY KEY (MADA),
    CONSTRAINT FK_DA_PHONGBAN FOREIGN KEY (MAPHONG) REFERENCES PHONGBAN(MAPHONG)
);
 
-- Tạo bảng PHANCONG (Phân công nhân viên vào đề án)
CREATE TABLE PHANCONG (
    MANV        NUMBER(9)       NOT NULL,
    MADA        NUMBER(5)       NOT NULL,
    THOIGIAN    NUMBER(5,1),        -- Số giờ làm việc/tuần
    CONSTRAINT PK_PHANCONG PRIMARY KEY (MANV, MADA),
    CONSTRAINT FK_PC_NHANVIEN FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV),
    CONSTRAINT FK_PC_DEAN     FOREIGN KEY (MADA) REFERENCES DEAN(MADA)
);
 
-- Tạo bảng THANNHAN (Thân nhân của nhân viên)
CREATE TABLE THANNHAN (
    MANV        NUMBER(9)       NOT NULL,
    TENTN       NVARCHAR2(30)   NOT NULL,
    PHAI        NVARCHAR2(3),
    NGAYSINH    DATE,
    QUANHE      NVARCHAR2(15),      -- Vợ/Chồng/Con...
    CONSTRAINT PK_THANNHAN PRIMARY KEY (MANV, TENTN),
    CONSTRAINT FK_TN_NHANVIEN FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV)
);

-- PHONGBAN (chưa có trưởng phòng, cập nhật sau)
INSERT INTO PHONGBAN (MAPHONG, TENPHONG) VALUES (1, N'Nghiên cứu');
INSERT INTO PHONGBAN (MAPHONG, TENPHONG) VALUES (2, N'Quản lý');
INSERT INTO PHONGBAN (MAPHONG, TENPHONG) VALUES (3, N'Kinh doanh');
INSERT INTO PHONGBAN (MAPHONG, TENPHONG) VALUES (4, N'Kỹ thuật');
INSERT INTO PHONGBAN (MAPHONG, TENPHONG) VALUES (5, N'Hành chính');
 
-- NHANVIEN
INSERT INTO NHANVIEN VALUES (123456789, N'Nguyễn',  N'Văn', N'Hùng',   TO_DATE('1975-11-10','YYYY-MM-DD'), N'123 Lê Lợi, TP.HCM',    N'Nam', 55000, NULL,      1);
INSERT INTO NHANVIEN VALUES (333445555, N'Trần',    N'Thị', N'Lan',    TO_DATE('1980-06-20','YYYY-MM-DD'), N'45 Nguyễn Huệ, TP.HCM', N'Nữ',  43000, 123456789, 1);
INSERT INTO NHANVIEN VALUES (999887777, N'Lê',      N'Văn', N'Minh',   TO_DATE('1978-03-15','YYYY-MM-DD'), N'78 Hai Bà Trưng, HN',   N'Nam', 38000, 123456789, 2);
INSERT INTO NHANVIEN VALUES (987654321, N'Phạm',    N'Thị', N'Hoa',    TO_DATE('1985-09-05','YYYY-MM-DD'), N'22 Lý Thường Kiệt, HN', N'Nữ',  48000, 333445555, 3);
INSERT INTO NHANVIEN VALUES (666884444, N'Hoàng',   N'Văn', N'Đức',    TO_DATE('1990-01-25','YYYY-MM-DD'), N'99 Trần Phú, Đà Nẵng',  N'Nam', 35000, 333445555, 4);
INSERT INTO NHANVIEN VALUES (453453453, N'Vũ',      N'Thị', N'Mai',    TO_DATE('1982-12-30','YYYY-MM-DD'), N'56 Điện Biên Phủ, HCM', N'Nữ',  40000, 987654321, 3);
INSERT INTO NHANVIEN VALUES (987987987, N'Đặng',    N'Văn', N'Khoa',   TO_DATE('1976-04-10','YYYY-MM-DD'), N'33 Pasteur, TP.HCM',    N'Nam', 52000, NULL,      2);
 
-- Cập nhật trưởng phòng
UPDATE PHONGBAN SET TRUONGPHONG = 123456789, NGAYBD = TO_DATE('2010-01-01','YYYY-MM-DD') WHERE MAPHONG = 1;
UPDATE PHONGBAN SET TRUONGPHONG = 987987987, NGAYBD = TO_DATE('2012-03-15','YYYY-MM-DD') WHERE MAPHONG = 2;
UPDATE PHONGBAN SET TRUONGPHONG = 987654321, NGAYBD = TO_DATE('2015-07-01','YYYY-MM-DD') WHERE MAPHONG = 3;
UPDATE PHONGBAN SET TRUONGPHONG = 666884444, NGAYBD = TO_DATE('2018-05-20','YYYY-MM-DD') WHERE MAPHONG = 4;
UPDATE PHONGBAN SET TRUONGPHONG = 453453453, NGAYBD = TO_DATE('2020-09-10','YYYY-MM-DD') WHERE MAPHONG = 5;
 
-- DIADIEM_PHG
INSERT INTO DIADIEM_PHG VALUES (1, N'TP.HCM');
INSERT INTO DIADIEM_PHG VALUES (1, N'Hà Nội');
INSERT INTO DIADIEM_PHG VALUES (2, N'TP.HCM');
INSERT INTO DIADIEM_PHG VALUES (3, N'Đà Nẵng');
INSERT INTO DIADIEM_PHG VALUES (4, N'Hà Nội');
INSERT INTO DIADIEM_PHG VALUES (5, N'TP.HCM');
 
-- DEAN
INSERT INTO DEAN VALUES (1,  N'Tự động hóa dây chuyền sản xuất', N'TP.HCM',   1);
INSERT INTO DEAN VALUES (2,  N'Phát triển sản phẩm mới X',       N'Hà Nội',   1);
INSERT INTO DEAN VALUES (3,  N'Hệ thống quản lý nhân sự',        N'Đà Nẵng',  2);
INSERT INTO DEAN VALUES (4,  N'Mở rộng thị trường miền Bắc',     N'Hà Nội',   3);
INSERT INTO DEAN VALUES (5,  N'Nâng cấp hạ tầng mạng',           N'TP.HCM',   4);
 
-- PHANCONG
INSERT INTO PHANCONG VALUES (123456789, 1, 32.5);
INSERT INTO PHANCONG VALUES (123456789, 2, 7.5);
INSERT INTO PHANCONG VALUES (333445555, 2, 10.0);
INSERT INTO PHANCONG VALUES (333445555, 3, 10.0);
INSERT INTO PHANCONG VALUES (333445555, 5, 10.0);
INSERT INTO PHANCONG VALUES (999887777, 3, 35.0);
INSERT INTO PHANCONG VALUES (987654321, 4, 20.0);
INSERT INTO PHANCONG VALUES (987654321, 5, 20.0);
INSERT INTO PHANCONG VALUES (666884444, 5, 40.0);
INSERT INTO PHANCONG VALUES (453453453, 4, 20.0);
INSERT INTO PHANCONG VALUES (987987987, 1, 40.0);
 
-- THANNHAN
INSERT INTO THANNHAN VALUES (123456789, N'Nguyễn Thị Thanh',  N'Nữ',  TO_DATE('1978-05-20','YYYY-MM-DD'), N'Vợ');
INSERT INTO THANNHAN VALUES (123456789, N'Nguyễn Văn Nam',    N'Nam', TO_DATE('2005-03-01','YYYY-MM-DD'), N'Con');
INSERT INTO THANNHAN VALUES (333445555, N'Trần Văn Bình',     N'Nam', TO_DATE('1978-10-12','YYYY-MM-DD'), N'Chồng');
INSERT INTO THANNHAN VALUES (333445555, N'Trần Thị Cúc',      N'Nữ',  TO_DATE('2008-07-14','YYYY-MM-DD'), N'Con');
INSERT INTO THANNHAN VALUES (987654321, N'Phạm Văn Long',     N'Nam', TO_DATE('1983-02-28','YYYY-MM-DD'), N'Chồng');
INSERT INTO THANNHAN VALUES (666884444, N'Hoàng Thị Yến',     N'Nữ',  TO_DATE('1992-11-05','YYYY-MM-DD'), N'Vợ');
 
COMMIT;
-- 1. Nhân viên có lương > 12000$
SELECT last_name, salary
FROM employees
WHERE salary > 12000;
 
-- 2. Nhân viên có lương < 5000$ hoặc > 12000$
SELECT last_name, salary
FROM employees
WHERE salary < 5000 OR salary > 12000;
 
-- 3. Nhân viên được thuê từ 20/02/1998 đến 01/05/1998, sắp xếp tăng dần theo ngày thuê
SELECT last_name, job_id, hire_date
FROM employees
WHERE hire_date BETWEEN TO_DATE('20/02/1998','DD/MM/YYYY')
                    AND TO_DATE('01/05/1998','DD/MM/YYYY')
ORDER BY hire_date ASC;
 
-- 4. Nhân viên thuộc phòng 20 và 50, sắp xếp theo alphabe
SELECT last_name, department_id
FROM employees
WHERE department_id IN (20, 50)
ORDER BY last_name ASC;
 
-- 5. Nhân viên được thuê năm 1994
SELECT *
FROM employees
WHERE TO_CHAR(hire_date, 'YYYY') = '1994';
 
-- 6. Nhân viên không có người quản lý
SELECT last_name, job_id
FROM employees
WHERE manager_id IS NULL;
 
-- 7. Nhân viên được hưởng hoa hồng, sắp xếp giảm dần theo lương và hoa hồng
SELECT *
FROM employees
WHERE commission_pct IS NOT NULL
ORDER BY salary DESC, commission_pct DESC;
 
-- 8. Nhân viên có ký tự thứ 3 trong tên (last_name) là 'a'
SELECT last_name
FROM employees
WHERE SUBSTR(last_name, 3, 1) = 'a';
 
-- 9. Nhân viên trong tên có chứa chữ 'a' và chữ 'e'
SELECT last_name
FROM employees
WHERE last_name LIKE '%a%' AND last_name LIKE '%e%';
 
-- 10. Nhân viên làm 'Sales Representative' hoặc 'Stock Clerk'
--     và lương không thuộc 2500, 3500, 7000
SELECT last_name, job_id, salary
FROM employees
WHERE job_id IN ('SA_REP', 'ST_CLERK')
  AND salary NOT IN (2500, 3500, 7000);
 
-- 11. Lương sau khi tăng 15%, làm tròn đến hàng đơn vị, đặt tên cột "New Salary"
SELECT employee_id,
       last_name,
       salary,
       ROUND(salary * 1.15, 0) AS "New Salary"
FROM employees;
 
-- 12. Tên nhân viên bắt đầu bằng 'J','A','L','M', hiển thị chiều dài tên,
--     ký tự đầu hoa, các ký tự còn lại thường; sắp xếp tăng dần theo tên
SELECT INITCAP(last_name) AS last_name,
       LENGTH(last_name)  AS length
FROM employees
WHERE SUBSTR(UPPER(last_name), 1, 1) IN ('J','A','L','M')
ORDER BY last_name ASC;
 
-- 13. Số tháng nhân viên đã làm việc đến nay, sắp xếp tăng dần
SELECT last_name,
       ROUND(MONTHS_BETWEEN(SYSDATE, hire_date), 0) AS months_worked
FROM employees
ORDER BY months_worked ASC;
 
-- 14. Định dạng: <last_name> earns <salary> monthly but wants <3*salary>
SELECT last_name || ' earns ' || TO_CHAR(salary)
       || ' monthly but wants ' || TO_CHAR(3 * salary) AS "Dream Salaries"
FROM employees;
 
-- 15. Mức hoa hồng; không có hoa hồng thì hiển thị 'No commission'
SELECT last_name,
       NVL(TO_CHAR(commission_pct), 'No commission') AS commission
FROM employees;
 
-- 16. Chuyển job_id thành GRADE bằng DECODE
SELECT job_id,
       DECODE(job_id,
              'AD_PRES',  'A',
              'ST_MAN',   'B',
              'IT_PROG',  'C',
              'SA_REP',   'D',
              'ST_CLERK', 'E',
                          '0') AS GRADE
FROM employees;
 
-- (Hoặc dùng CASE)
-- SELECT job_id,
--        CASE job_id
--          WHEN 'AD_PRES'  THEN 'A'
--          WHEN 'ST_MAN'   THEN 'B'
--          WHEN 'IT_PROG'  THEN 'C'
--          WHEN 'SA_REP'   THEN 'D'
--          WHEN 'ST_CLERK' THEN 'E'
--          ELSE '0'
--        END AS GRADE
-- FROM employees;
 
-- 17. Nhân viên làm việc ở thành phố Toronto
SELECT e.last_name, e.department_id, d.department_name
FROM employees   e
JOIN departments d ON e.department_id  = d.department_id
JOIN locations   l ON d.location_id    = l.location_id
WHERE l.city = 'Toronto';
 
-- 18. Thông tin nhân viên cùng người quản lý
SELECT e.employee_id       AS "Mã NV",
       e.last_name         AS "Tên NV",
       e.manager_id        AS "Mã QL",
       m.last_name         AS "Tên QL"
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id;
 
-- 19. Danh sách nhân viên làm việc cùng phòng (tự join)
SELECT a.last_name AS nhanvien,
       b.last_name AS cung_phong,
       a.department_id
FROM employees a
JOIN employees b ON  a.department_id = b.department_id
                 AND a.employee_id   < b.employee_id
ORDER BY a.department_id, a.last_name;
 
-- 20. Nhân viên được thuê sau nhân viên 'Davies'
SELECT last_name, hire_date
FROM employees
WHERE hire_date > (
    SELECT hire_date
    FROM employees
    WHERE last_name = 'Davies'
);
 
-- 21. Nhân viên được thuê trước người quản lý của họ
SELECT e.last_name AS nhanvien, e.hire_date,
       m.last_name AS quan_ly,  m.hire_date AS hire_manager
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.hire_date < m.hire_date;
 
-- 22. Lương min, max, trung bình, tổng theo từng loại công việc
SELECT job_id,
       MIN(salary)  AS luong_min,
       MAX(salary)  AS luong_max,
       ROUND(AVG(salary), 2) AS luong_tb,
       SUM(salary)  AS tong_luong
FROM employees
GROUP BY job_id
ORDER BY job_id;
 
-- 23. Mã phòng, tên phòng, số lượng nhân viên của từng phòng ban
SELECT d.department_id,
       d.department_name,
       COUNT(e.employee_id) AS so_nhan_vien
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY d.department_id;
 
-- 24. Tổng nhân viên và tổng nhân viên được thuê từng năm 1995-1998
SELECT COUNT(*) AS tong_nhan_vien,
       SUM(CASE WHEN TO_CHAR(hire_date,'YYYY') = '1995' THEN 1 ELSE 0 END) AS "1995",
       SUM(CASE WHEN TO_CHAR(hire_date,'YYYY') = '1996' THEN 1 ELSE 0 END) AS "1996",
       SUM(CASE WHEN TO_CHAR(hire_date,'YYYY') = '1997' THEN 1 ELSE 0 END) AS "1997",
       SUM(CASE WHEN TO_CHAR(hire_date,'YYYY') = '1998' THEN 1 ELSE 0 END) AS "1998"
FROM employees;
 
-- 25. Tên, ngày thuê của nhân viên làm cùng phòng với nhân viên 'Zlotkey'
SELECT last_name, hire_date
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM employees
    WHERE last_name = 'Zlotkey'
)
AND last_name <> 'Zlotkey';
 
-- 26. Nhân viên làm việc cho phòng có location_id = 1700
SELECT e.last_name, e.department_id, e.job_id
FROM employees   e
JOIN departments d ON e.department_id = d.department_id
WHERE d.location_id = 1700;
 
-- 27. Nhân viên có người quản lý tên 'King'
SELECT e.last_name, e.employee_id
FROM employees e
WHERE e.manager_id IN (
    SELECT employee_id
    FROM employees
    WHERE last_name = 'King'
);
 
-- 28. Nhân viên có lương > lương TB và làm cùng phòng với NV có tên kết thúc bằng 'n'
SELECT last_name, salary, department_id
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
  AND department_id IN (
      SELECT department_id
      FROM employees
      WHERE last_name LIKE '%n'
  );
 
-- 29. Phòng ban có ít hơn 3 nhân viên
SELECT d.department_id, d.department_name, COUNT(e.employee_id) AS so_nv
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) < 3
ORDER BY so_nv;
 
-- 30. Phòng ban có đông nhân viên nhất và ít nhân viên nhất
SELECT department_id,
       COUNT(*) AS so_nv
FROM employees
GROUP BY department_id
HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM employees GROUP BY department_id)
    OR COUNT(*) = (SELECT MIN(COUNT(*)) FROM employees GROUP BY department_id)
ORDER BY so_nv DESC;
 
-- 31. Nhân viên được thuê vào ngày trong tuần có số lượng thuê đông nhất
SELECT last_name, hire_date,
       TO_CHAR(hire_date, 'Day') AS ngay_trong_tuan
FROM employees
WHERE TO_CHAR(hire_date, 'Day') = (
    SELECT TO_CHAR(hire_date, 'Day')
    FROM employees
    GROUP BY TO_CHAR(hire_date, 'Day')
    ORDER BY COUNT(*) DESC
    FETCH FIRST 1 ROWS ONLY
);
 
-- 32. 3 nhân viên có lương cao nhất
SELECT last_name, salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 3 ROWS ONLY;
 
-- 33. Nhân viên làm việc ở tiểu bang California (state_province)
SELECT e.last_name, l.city, l.state_province
FROM employees   e
JOIN departments d ON e.department_id = d.department_id
JOIN locations   l ON d.location_id   = l.location_id
WHERE l.state_province = 'California';
 
-- 34. Cập nhật tên nhân viên có employee_id = 3 thành 'Drexler'
UPDATE employees
SET last_name = 'Drexler'
WHERE employee_id = 3;
COMMIT;
 
-- 35. Nhân viên có lương thấp hơn lương trung bình của phòng mình
SELECT e.last_name, e.salary, e.department_id
FROM employees e
WHERE salary < (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id = e.department_id
)
ORDER BY e.department_id;
 
-- 36. Tăng thêm 100$ cho nhân viên có lương < 900$
UPDATE employees
SET salary = salary + 100
WHERE salary < 900;
COMMIT;
 
-- 37. Xóa phòng ban 500
DELETE FROM departments
WHERE department_id = 500;
COMMIT;
 
-- 38. Xóa phòng ban chưa có nhân viên
DELETE FROM departments
WHERE department_id NOT IN (
    SELECT DISTINCT department_id
    FROM employees
    WHERE department_id IS NOT NULL
);
COMMIT;