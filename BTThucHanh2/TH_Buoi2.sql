-- 1. Nhân viên có lương > 12000
SELECT TENNV, LUONG
FROM NHANVIEN
WHERE LUONG > 12000;
 
-- 2. Nhân viên có lương < 5000 hoặc > 12000
SELECT TENNV, LUONG
FROM NHANVIEN
WHERE LUONG < 5000 OR LUONG > 12000;
 
-- 3. Nhân viên được thuê (ngày sinh dùng minh hoạ) từ 20/02/1978 đến 01/05/1985
--    (Thay hire_date bằng NGAYSINH vì schema A2 không có cột hire_date)
SELECT TENNV, MAPHONG, NGAYSINH
FROM NHANVIEN
WHERE NGAYSINH BETWEEN TO_DATE('20/02/1978', 'DD/MM/YYYY')
                   AND TO_DATE('01/05/1985', 'DD/MM/YYYY')
ORDER BY NGAYSINH ASC;
 
-- 4. Nhân viên thuộc phòng 1 và 2, sắp xếp theo tên
SELECT TENNV, MAPHONG
FROM NHANVIEN
WHERE MAPHONG IN (1, 2)
ORDER BY TENNV ASC;
 
-- 5. Nhân viên sinh năm 1982
SELECT *
FROM NHANVIEN
WHERE TO_CHAR(NGAYSINH, 'YYYY') = '1982';
 
-- 6. Nhân viên không có người quản lý
SELECT TENNV, MAPHONG
FROM NHANVIEN
WHERE MA_NQL IS NULL;
 
-- 7. Nhân viên có phân công (tương đương commission), sắp xếp giảm dần theo lương
SELECT nv.MANV, nv.TENNV, nv.LUONG, pc.THOIGIAN
FROM NHANVIEN nv
JOIN PHANCONG pc ON nv.MANV = pc.MANV
ORDER BY nv.LUONG DESC, pc.THOIGIAN DESC;
 
-- 8. Nhân viên có ký tự thứ 3 trong tên (TENNV) là 'a'
SELECT TENNV
FROM NHANVIEN
WHERE SUBSTR(TENNV, 3, 1) = 'a';
 
-- 9. Nhân viên trong tên có chứa chữ 'a' và chữ 'e'
SELECT TENNV
FROM NHANVIEN
WHERE TENNV LIKE '%a%' AND TENNV LIKE '%e%';
 
-- 10. Nhân viên làm đề án có mã 1 hoặc 2
--     và giờ làm việc không thuộc 10, 20, 40
SELECT nv.TENNV, pc.MADA, nv.LUONG
FROM NHANVIEN nv
JOIN PHANCONG pc ON nv.MANV = pc.MANV
WHERE pc.MADA IN (1, 2)
  AND pc.THOIGIAN NOT IN (10, 20, 40);
 
-- 11. Lương sau khi tăng 15%, làm tròn đến hàng đơn vị, đặt tên cột "Luong Moi"
SELECT MANV,
       TENNV,
       LUONG,
       ROUND(LUONG * 1.15, 0) AS "Luong Moi"
FROM NHANVIEN;
 
-- 12. Nhân viên có tên bắt đầu bằng 'H','A','L','M'
--     Hiển thị tên (INITCAP) và chiều dài tên; sắp xếp tăng dần
SELECT INITCAP(TENNV)    AS TENNV,
       LENGTH(TENNV)     AS CHIEU_DAI
FROM NHANVIEN
WHERE SUBSTR(UPPER(TENNV), 1, 1) IN ('H', 'A', 'L', 'M')
ORDER BY TENNV ASC;
 
-- 13. Số tháng nhân viên đã làm việc (tính từ NGAYSINH đến nay - minh hoạ)
SELECT TENNV,
       ROUND(MONTHS_BETWEEN(SYSDATE, NGAYSINH), 0) AS SO_THANG
FROM NHANVIEN
ORDER BY SO_THANG ASC;
 
-- 14. Định dạng: <TENNV> earns <LUONG> monthly but wants <3*LUONG>
SELECT TENNV
       || ' earns '
       || TO_CHAR(LUONG)
       || ' monthly but wants '
       || TO_CHAR(3 * LUONG) AS "Dream Salaries"
FROM NHANVIEN;
 
-- 15. Giờ làm việc của nhân viên; nếu chưa được phân công thì hiển thị 'Chua phan cong'
SELECT nv.TENNV,
       NVL(TO_CHAR(pc.THOIGIAN), 'Chua phan cong') AS GIO_LAM
FROM NHANVIEN nv
LEFT JOIN PHANCONG pc ON nv.MANV = pc.MANV;
 
-- 16. Phân loại nhân viên theo phòng ban (tương đương GRADE theo JOB_ID)
SELECT MANV, TENNV, MAPHONG,
       DECODE(MAPHONG,
              1, 'A',
              2, 'B',
              3, 'C',
              4, 'D',
              5, 'E',
                 '0') AS GRADE
FROM NHANVIEN;
 
-- 17. Nhân viên làm việc ở địa điểm 'TP.HCM'
SELECT nv.TENNV,
       nv.MAPHONG,
       pb.TENPHONG
FROM   NHANVIEN     nv
JOIN   PHONGBAN     pb ON nv.MAPHONG  = pb.MAPHONG
JOIN   DIADIEM_PHG  dd ON pb.MAPHONG  = dd.MAPHONG
WHERE  dd.DIADIEM = N'TP.HCM';
 
-- 18. Thông tin nhân viên cùng người quản lý
SELECT nv.MANV      AS "Ma NV",
       nv.TENNV     AS "Ten NV",
       nv.MA_NQL    AS "Ma QL",
       ql.TENNV     AS "Ten QL"
FROM   NHANVIEN nv
JOIN   NHANVIEN ql ON nv.MA_NQL = ql.MANV;
 
-- 19. Danh sách nhân viên làm việc cùng phòng (tự join)
SELECT a.TENNV        AS nhanvien,
       b.TENNV        AS cung_phong,
       a.MAPHONG
FROM   NHANVIEN a
JOIN   NHANVIEN b ON  a.MAPHONG   = b.MAPHONG
                  AND a.MANV      < b.MANV
ORDER BY a.MAPHONG, a.TENNV;
 
-- 20. Nhân viên có LUONG cao hơn nhân viên tên 'Lan'
SELECT TENNV, LUONG
FROM   NHANVIEN
WHERE  LUONG > (
           SELECT LUONG
           FROM   NHANVIEN
           WHERE  TENNV = N'Lan'
       );
 
-- 21. Nhân viên có LUONG thấp hơn người quản lý của họ
SELECT nv.TENNV   AS nhanvien,
       nv.LUONG   AS luong_nv,
       ql.TENNV   AS quan_ly,
       ql.LUONG   AS luong_ql
FROM   NHANVIEN nv
JOIN   NHANVIEN ql ON nv.MA_NQL = ql.MANV
WHERE  nv.LUONG < ql.LUONG;
 
-- 22. Lương min, max, trung bình, tổng theo từng phòng ban
SELECT MAPHONG,
       MIN(LUONG)            AS LUONG_MIN,
       MAX(LUONG)            AS LUONG_MAX,
       ROUND(AVG(LUONG), 2)  AS LUONG_TB,
       SUM(LUONG)            AS TONG_LUONG
FROM   NHANVIEN
GROUP BY MAPHONG
ORDER BY MAPHONG;
 
-- 23. Mã phòng, tên phòng, số lượng nhân viên của từng phòng ban
SELECT pb.MAPHONG,
       pb.TENPHONG,
       COUNT(nv.MANV) AS SO_NHANVIEN
FROM   PHONGBAN pb
LEFT JOIN NHANVIEN nv ON pb.MAPHONG = nv.MAPHONG
GROUP BY pb.MAPHONG, pb.TENPHONG
ORDER BY pb.MAPHONG;
 
-- 24. Tổng nhân viên và số nhân viên sinh từng năm 1975-1990
SELECT COUNT(*) AS TONG_NV,
       SUM(CASE WHEN TO_CHAR(NGAYSINH,'YYYY') = '1975' THEN 1 ELSE 0 END) AS "1975",
       SUM(CASE WHEN TO_CHAR(NGAYSINH,'YYYY') = '1978' THEN 1 ELSE 0 END) AS "1978",
       SUM(CASE WHEN TO_CHAR(NGAYSINH,'YYYY') = '1982' THEN 1 ELSE 0 END) AS "1982",
       SUM(CASE WHEN TO_CHAR(NGAYSINH,'YYYY') = '1985' THEN 1 ELSE 0 END) AS "1985"
FROM   NHANVIEN;
 
-- 25. Tên, địa chỉ của nhân viên làm cùng phòng với nhân viên 'Lan'
SELECT TENNV, DIACHI
FROM   NHANVIEN
WHERE  MAPHONG = (
           SELECT MAPHONG
           FROM   NHANVIEN
           WHERE  TENNV = N'Lan'
       )
  AND TENNV <> N'Lan';
 
-- 26. Nhân viên làm việc cho phòng ban đặt tại địa điểm 'Hà Nội'
SELECT nv.TENNV,
       nv.MAPHONG,
       nv.PHAI
FROM   NHANVIEN    nv
JOIN   DIADIEM_PHG dd ON nv.MAPHONG = dd.MAPHONG
WHERE  dd.DIADIEM = N'Hà Nội';
 
-- 27. Nhân viên có người quản lý tên 'Hùng'
SELECT TENNV, MANV
FROM   NHANVIEN
WHERE  MA_NQL IN (
           SELECT MANV
           FROM   NHANVIEN
           WHERE  TENNV = N'Hùng'
       );
 
-- 28. Nhân viên có lương > lương TB toàn công ty
--     và làm cùng phòng với nhân viên có tên kết thúc bằng 'n'
SELECT TENNV, LUONG, MAPHONG
FROM   NHANVIEN
WHERE  LUONG > (SELECT AVG(LUONG) FROM NHANVIEN)
  AND  MAPHONG IN (
           SELECT MAPHONG
           FROM   NHANVIEN
           WHERE  TENNV LIKE '%n'
       );
 
-- 29. Phòng ban có ít hơn 3 nhân viên
SELECT pb.MAPHONG,
       pb.TENPHONG,
       COUNT(nv.MANV) AS SO_NV
FROM   PHONGBAN pb
LEFT JOIN NHANVIEN nv ON pb.MAPHONG = nv.MAPHONG
GROUP BY pb.MAPHONG, pb.TENPHONG
HAVING COUNT(nv.MANV) < 3
ORDER BY SO_NV;
 
-- 30. Phòng ban có đông nhất và ít nhân viên nhất
SELECT MAPHONG,
       COUNT(*) AS SO_NV
FROM   NHANVIEN
GROUP BY MAPHONG
HAVING COUNT(*) = (SELECT MAX(cnt) FROM (SELECT COUNT(*) AS cnt FROM NHANVIEN GROUP BY MAPHONG))
    OR COUNT(*) = (SELECT MIN(cnt) FROM (SELECT COUNT(*) AS cnt FROM NHANVIEN GROUP BY MAPHONG))
ORDER BY SO_NV DESC;
 
-- 31. Nhân viên sinh vào ngày trong tuần có số lượng đông nhất
SELECT TENNV,
       NGAYSINH,
       TO_CHAR(NGAYSINH, 'Day') AS NGAY_TRONG_TUAN
FROM   NHANVIEN
WHERE  TRIM(TO_CHAR(NGAYSINH, 'Day')) = (
           SELECT TRIM(ngay)
           FROM (
               SELECT TO_CHAR(NGAYSINH, 'Day') AS ngay,
                      COUNT(*)                 AS so_luong
               FROM   NHANVIEN
               GROUP BY TO_CHAR(NGAYSINH, 'Day')
               ORDER BY so_luong DESC
           )
           WHERE ROWNUM = 1
       );
 
-- 32. 3 nhân viên có lương cao nhất
SELECT TENNV, LUONG
FROM (
    SELECT TENNV, LUONG
    FROM   NHANVIEN
    ORDER BY LUONG DESC
)
WHERE ROWNUM <= 3;
 
-- 33. Nhân viên làm việc ở địa điểm 'Đà Nẵng'
SELECT nv.TENNV,
       dd.DIADIEM,
       nv.MAPHONG
FROM   NHANVIEN    nv
JOIN   PHONGBAN    pb ON nv.MAPHONG  = pb.MAPHONG
JOIN   DIADIEM_PHG dd ON pb.MAPHONG  = dd.MAPHONG
WHERE  dd.DIADIEM = N'Đà Nẵng';
 
-- 34. Cập nhật tên nhân viên có MANV = 333445555 thành 'Drexler'
UPDATE NHANVIEN
SET    TENNV = N'Drexler'
WHERE  MANV = 333445555;
COMMIT;
 
-- 35. Nhân viên có lương thấp hơn lương trung bình của phòng mình
SELECT TENNV, LUONG, MAPHONG
FROM   NHANVIEN nv
WHERE  LUONG < (
           SELECT AVG(LUONG)
           FROM   NHANVIEN
           WHERE  MAPHONG = nv.MAPHONG
       )
ORDER BY MAPHONG;
 
-- 36. Tăng thêm 100 cho nhân viên có lương < 38000
UPDATE NHANVIEN
SET    LUONG = LUONG + 100
WHERE  LUONG < 38000;
COMMIT;
 
-- 37. Xóa phòng ban số 5
DELETE FROM PHONGBAN
WHERE  MAPHONG = 5;
COMMIT;
 
-- 38. Xóa phòng ban chưa có nhân viên
DELETE FROM PHONGBAN
WHERE  MAPHONG NOT IN (
           SELECT DISTINCT MAPHONG
           FROM   NHANVIEN
           WHERE  MAPHONG IS NOT NULL
       );
COMMIT;