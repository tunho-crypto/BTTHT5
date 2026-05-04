-- ============================================================
-- HE THONG QUAN LY CUA HANG - ORACLE SQL HOAN CHINH
-- Schema: thuchanh3.sql (DANH_MUC, SAN_PHAM, KHACH_HANG,
--         NHAN_VIEN, DON_HANG, CHI_TIET_DON_HANG,
--         NHA_CUNG_CAP, NHAP_KHO)
-- ============================================================

-- ============================================================
-- PHAN 1: VIEWS
-- ============================================================

-- Cau 1.1: View tong quan san pham theo danh muc
--   Tuong duong: vw_course_summary -> tong quan mon hoc
--   Anh xa: DANH_MUC ~ course | SAN_PHAM ~ class | CHI_TIET_DON_HANG ~ enrollment
CREATE OR REPLACE VIEW vw_sanpham_summary AS
SELECT
    dm.ma_danh_muc,
    dm.ten_danh_muc,
    dm.mo_ta,
    COUNT(DISTINCT sp.ma_sp)            AS so_san_pham,
    SUM(sp.so_luong_ton)                AS tong_ton_kho,
    ROUND(AVG(sp.gia_ban), 0)           AS gia_ban_tb
FROM DANH_MUC dm
LEFT JOIN SAN_PHAM sp ON dm.ma_danh_muc = sp.ma_danh_muc
GROUP BY dm.ma_danh_muc, dm.ten_danh_muc, dm.mo_ta
ORDER BY so_san_pham DESC;

-- Kiem tra:
SELECT * FROM vw_sanpham_summary;


-- Cau 1.2: View thong tin khach hang va tinh trang mua hang
--   Tuong duong: vw_student_status -> thong tin sinh vien
--   Anh xa: KHACH_HANG ~ student | DON_HANG ~ enrollment | CHI_TIET_DON_HANG ~ grade
CREATE OR REPLACE VIEW vw_khachhang_status AS
SELECT
    kh.ma_kh,
    kh.ho_ten,
    kh.tinh_thanh,
    kh.diem_tich_luy,
    COUNT(DISTINCT dh.ma_dh)            AS so_don_hang,
    NVL(SUM(dh.tong_tien), 0)          AS tong_chi_tieu,
    ROUND(AVG(dh.tong_tien), 0)        AS don_hang_tb
FROM KHACH_HANG kh
LEFT JOIN DON_HANG dh ON kh.ma_kh = dh.ma_kh
GROUP BY kh.ma_kh, kh.ho_ten, kh.tinh_thanh, kh.diem_tich_luy
ORDER BY tong_chi_tieu DESC;

-- Kiem tra:
SELECT * FROM vw_khachhang_status;


-- Cau 1.3: View san pham con hang (con ton kho)
--   Tuong duong: vw_class_availability -> lop hoc con cho trong
--   Anh xa: SAN_PHAM ~ class | DANH_MUC ~ course | NHA_CUNG_CAP ~ instructor
CREATE OR REPLACE VIEW vw_sanpham_conhang AS
SELECT
    sp.ma_sp,
    sp.ten_sp,
    dm.ten_danh_muc,
    ncc.ten_ncc                         AS nha_cung_cap,
    sp.don_vi_tinh,
    sp.gia_ban,
    sp.gia_nhap,
    sp.gia_ban - sp.gia_nhap           AS loi_nhuan_don_vi,
    sp.so_luong_ton,
    CASE
        WHEN sp.so_luong_ton > 100 THEN 'Du hang'
        WHEN sp.so_luong_ton > 0   THEN 'Con it'
        ELSE 'Het hang'
    END                                 AS trang_thai_kho
FROM SAN_PHAM sp
JOIN DANH_MUC      dm  ON sp.ma_danh_muc = dm.ma_danh_muc
JOIN NHA_CUNG_CAP  ncc ON sp.ma_ncc      = ncc.ma_ncc
WHERE sp.so_luong_ton > 0
ORDER BY sp.so_luong_ton DESC;

-- Kiem tra:
SELECT * FROM vw_sanpham_conhang;


-- Cau 1.4: View top 5 san pham ban chay nhat (chi doc)
--   Tuong duong: vw_top_courses -> top 5 mon duoc dang ky nhieu nhat
--   Anh xa: SAN_PHAM ~ course | CHI_TIET_DON_HANG ~ enrollment
CREATE OR REPLACE VIEW vw_top_sanpham AS
SELECT ma_sp, ten_sp, gia_ban, tong_so_luong_ban, tong_doanh_thu, hang
FROM (
    SELECT
        sp.ma_sp,
        sp.ten_sp,
        sp.gia_ban,
        SUM(ct.so_luong)                                        AS tong_so_luong_ban,
        SUM(ct.thanh_tien)                                      AS tong_doanh_thu,
        RANK() OVER (ORDER BY SUM(ct.so_luong) DESC)           AS hang
    FROM SAN_PHAM sp
    LEFT JOIN CHI_TIET_DON_HANG ct ON sp.ma_sp = ct.ma_sp
    GROUP BY sp.ma_sp, sp.ten_sp, sp.gia_ban
)
WHERE hang <= 5
ORDER BY hang
WITH READ ONLY;

-- Kiem tra:
SELECT * FROM vw_top_sanpham;

-- Thu INSERT vao view chi doc (se bao loi ORA-42399):
-- INSERT INTO vw_top_sanpham (ma_sp, ten_sp, gia_ban)
-- VALUES (999, 'San pham test', 10000);


-- Cau 1.5: View don hang chua co tong tien (tong_tien = 0) voi WITH CHECK OPTION
--   Tuong duong: vw_pending_enrollment -> dang ky chua co diem
--   Anh xa: DON_HANG ~ enrollment | tong_tien = 0 ~ finalgrade IS NULL
CREATE OR REPLACE VIEW vw_donhang_chuathanhtoan AS
SELECT
    ma_dh, ma_kh, ma_nv, ngay_dat,
    tong_tien, phuong_thuc_tt, ghi_chu
FROM DON_HANG
WHERE tong_tien = 0
WITH CHECK OPTION;

-- Kiem tra:
SELECT * FROM vw_donhang_chuathanhtoan;

-- INSERT hop le (tong_tien = 0 -> thoa dieu kien):
-- INSERT INTO vw_donhang_chuathanhtoan (ma_dh, ma_kh, ma_nv, ngay_dat, tong_tien, phuong_thuc_tt)
-- VALUES (seq_don_hang.NEXTVAL, 1001, 2, SYSDATE, 0, 'Tien mat');

-- INSERT vi pham (tong_tien > 0 -> loi ORA-01402):
-- INSERT INTO vw_donhang_chuathanhtoan (ma_dh, ma_kh, ma_nv, ngay_dat, tong_tien, phuong_thuc_tt)
-- VALUES (seq_don_hang.NEXTVAL, 1001, 2, SYSDATE, 500000, 'Tien mat');


-- ============================================================
-- PHAN 2: STORED PROCEDURES
-- ============================================================

-- Cau 2.1: Thu tuc dat don hang cho khach hang
--   Tuong duong: enroll_student -> dang ky sinh vien vao lop
--   Anh xa: KHACH_HANG ~ student | DON_HANG ~ enrollment | SAN_PHAM ~ class
CREATE OR REPLACE PROCEDURE dat_don_hang (
    p_ma_kh  IN NUMBER,
    p_ma_nv  IN NUMBER,
    p_ma_sp  IN NUMBER,
    p_sl     IN NUMBER,
    p_pttt   IN VARCHAR2 DEFAULT 'Tien mat'
) IS
    v_check    NUMBER;
    v_ton_kho  NUMBER;
    v_gia_ban  NUMBER;
    v_ma_dh    NUMBER;
    v_thanh_tien NUMBER;
BEGIN
    -- DK1: Khach hang phai ton tai (neu khong phai khach vang lai)
    IF p_ma_kh IS NOT NULL THEN
        SELECT COUNT(*) INTO v_check FROM KHACH_HANG WHERE ma_kh = p_ma_kh;
        IF v_check = 0 THEN
            DBMS_OUTPUT.PUT_LINE('[LOI] Khach hang ' || p_ma_kh || ' khong ton tai!');
            RETURN;
        END IF;
    END IF;

    -- DK2: Nhan vien phai ton tai
    SELECT COUNT(*) INTO v_check FROM NHAN_VIEN WHERE ma_nv = p_ma_nv;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Nhan vien ' || p_ma_nv || ' khong ton tai!');
        RETURN;
    END IF;

    -- DK3: San pham phai ton tai
    SELECT COUNT(*) INTO v_check FROM SAN_PHAM WHERE ma_sp = p_ma_sp;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] San pham ' || p_ma_sp || ' khong ton tai!');
        RETURN;
    END IF;

    -- DK4: Kiem tra ton kho du de ban
    SELECT so_luong_ton, gia_ban
    INTO v_ton_kho, v_gia_ban
    FROM SAN_PHAM WHERE ma_sp = p_ma_sp;

    IF v_ton_kho < p_sl THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] San pham ' || p_ma_sp
            || ' chi con ' || v_ton_kho || ' ' || ' don vi, khong du ' || p_sl || '!');
        RETURN;
    END IF;

    -- DK5: So luong phai > 0
    IF p_sl <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] So luong phai lon hon 0!');
        RETURN;
    END IF;

    -- Tinh thanh tien
    v_thanh_tien := p_sl * v_gia_ban;

    -- Lay ma don hang moi
    SELECT seq_don_hang.NEXTVAL INTO v_ma_dh FROM DUAL;

    -- Them don hang
    INSERT INTO DON_HANG (ma_dh, ma_kh, ma_nv, ngay_dat, tong_tien, phuong_thuc_tt)
    VALUES (v_ma_dh, p_ma_kh, p_ma_nv, SYSDATE, 0, p_pttt);

    -- Them chi tiet don hang (trigger se tu tinh thanh_tien va tru ton kho)
    INSERT INTO CHI_TIET_DON_HANG (ma_dh, ma_sp, so_luong, don_gia, giam_gia_pct)
    VALUES (v_ma_dh, p_ma_sp, p_sl, v_gia_ban, 0);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] Dat hang thanh cong! Don hang ' || v_ma_dh
        || ' - KH: ' || NVL(TO_CHAR(p_ma_kh), 'Vang lai')
        || ' - SP: ' || p_ma_sp
        || ' x' || p_sl
        || ' = ' || v_thanh_tien || ' VND');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('[LOI HE THONG] ' || SQLERRM);
END dat_don_hang;
/

-- Kiem tra:
SET SERVEROUTPUT ON;
BEGIN
    dat_don_hang(1001, 2, 101, 3, 'Tien mat');  -- Hop le
    dat_don_hang(9999, 2, 101, 1, 'Tien mat');  -- KH khong ton tai
    dat_don_hang(1001, 2, 999, 1, 'Tien mat');  -- SP khong ton tai
    dat_don_hang(1001, 2, 101, 9999, 'Tien mat'); -- Het hang
END;
/


-- Cau 2.2: Thu tuc cap nhat gia ban san pham
--   Tuong duong: update_final_grade -> cap nhat diem tong ket
--   Anh xa: SAN_PHAM ~ enrollment | gia_ban ~ finalgrade
CREATE OR REPLACE PROCEDURE cap_nhat_gia_ban (
    p_ma_sp    IN NUMBER,
    p_gia_moi  IN NUMBER
) IS
    v_check   NUMBER;
    v_gia_cu  NUMBER;
BEGIN
    -- Kiem tra gia hop le
    IF p_gia_moi <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Gia ban phai lon hon 0!');
        RETURN;
    END IF;

    -- Kiem tra san pham ton tai
    SELECT COUNT(*) INTO v_check FROM SAN_PHAM WHERE ma_sp = p_ma_sp;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] San pham ' || p_ma_sp || ' khong ton tai!');
        RETURN;
    END IF;

    -- Luu gia cu
    SELECT gia_ban INTO v_gia_cu FROM SAN_PHAM WHERE ma_sp = p_ma_sp;

    -- Kiem tra gia moi khac gia cu
    IF p_gia_moi = v_gia_cu THEN
        DBMS_OUTPUT.PUT_LINE('[CANH BAO] Gia moi trung voi gia hien tai. Khong cap nhat.');
        RETURN;
    END IF;

    -- Cap nhat gia ban
    UPDATE SAN_PHAM
    SET gia_ban = p_gia_moi
    WHERE ma_sp = p_ma_sp;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] Da cap nhat gia ban SP ' || p_ma_sp
        || ': Cu=' || v_gia_cu
        || ' -> Moi=' || p_gia_moi || ' VND');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('[LOI] ' || SQLERRM);
END cap_nhat_gia_ban;
/

-- Kiem tra:
BEGIN
    cap_nhat_gia_ban(101, 42000);  -- Hop le
    cap_nhat_gia_ban(101, 0);      -- Gia khong hop le
    cap_nhat_gia_ban(999, 10000);  -- SP khong ton tai
END;
/


-- Cau 2.3: Thu tuc chuyen san pham sang danh muc khac
--   Tuong duong: transfer_student -> chuyen lop cho sinh vien
--   Anh xa: SAN_PHAM ~ enrollment | DANH_MUC ~ class
CREATE OR REPLACE PROCEDURE chuyen_danh_muc (
    p_ma_sp          IN NUMBER,
    p_danh_muc_cu    IN NUMBER,
    p_danh_muc_moi   IN NUMBER
) IS
    v_check  NUMBER;
BEGIN
    -- DK1: San pham phai thuoc danh muc cu
    SELECT COUNT(*) INTO v_check FROM SAN_PHAM
    WHERE ma_sp = p_ma_sp AND ma_danh_muc = p_danh_muc_cu;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] San pham ' || p_ma_sp
            || ' khong thuoc danh muc ' || p_danh_muc_cu);
        RETURN;
    END IF;

    -- DK2: Danh muc moi phai ton tai
    SELECT COUNT(*) INTO v_check FROM DANH_MUC WHERE ma_danh_muc = p_danh_muc_moi;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Danh muc moi ' || p_danh_muc_moi || ' khong ton tai!');
        RETURN;
    END IF;

    -- DK3: Danh muc moi khac danh muc cu
    IF p_danh_muc_cu = p_danh_muc_moi THEN
        DBMS_OUTPUT.PUT_LINE('[LOI] Danh muc moi trung voi danh muc cu!');
        RETURN;
    END IF;

    -- Thuc hien chuyen danh muc
    SAVEPOINT sp_truoc_chuyen;

    UPDATE SAN_PHAM
    SET ma_danh_muc = p_danh_muc_moi
    WHERE ma_sp = p_ma_sp;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] Da chuyen SP ' || p_ma_sp
        || ' tu danh muc ' || p_danh_muc_cu
        || ' sang danh muc ' || p_danh_muc_moi);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_truoc_chuyen;
        DBMS_OUTPUT.PUT_LINE('[LOI] Chuyen danh muc that bai: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Da rollback ve trang thai ban dau.');
END chuyen_danh_muc;
/

-- Kiem tra:
BEGIN
    chuyen_danh_muc(101, 1, 2);  -- Chuyen hop le
    chuyen_danh_muc(101, 5, 2);  -- SP khong thuoc danh muc 5
    chuyen_danh_muc(999, 1, 2);  -- SP khong ton tai
END;
/


-- Cau 2.4: Thu tuc in bao cao chi tiet don hang
--   Tuong duong: report_class_detail -> bao cao chi tiet lop hoc
--   Anh xa: DON_HANG ~ class | CHI_TIET_DON_HANG ~ enrollment | SAN_PHAM ~ student
CREATE OR REPLACE PROCEDURE report_donhang_detail (
    p_ma_dh IN NUMBER
) IS
    v_check    NUMBER;
    v_ma_kh    NUMBER;
    v_ten_kh   VARCHAR2(100);
    v_ten_nv   VARCHAR2(100);
    v_ngay_dat DATE;
    v_pttt     VARCHAR2(30);
    v_ghi_chu  VARCHAR2(300);
    v_stt      NUMBER := 0;
    v_tong     NUMBER := 0;
    v_tong_tt  NUMBER := 0;
BEGIN
    -- Kiem tra don hang ton tai
    SELECT COUNT(*) INTO v_check FROM DON_HANG WHERE ma_dh = p_ma_dh;
    IF v_check = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Don hang ' || p_ma_dh || ' khong ton tai!');
        RETURN;
    END IF;

    -- Lay thong tin don hang
    SELECT dh.ma_kh,
           NVL(kh.ho_ten, 'Khach vang lai'),
           nv.ho_ten,
           dh.ngay_dat,
           dh.phuong_thuc_tt,
           dh.ghi_chu
    INTO v_ma_kh, v_ten_kh, v_ten_nv, v_ngay_dat, v_pttt, v_ghi_chu
    FROM DON_HANG dh
    LEFT JOIN KHACH_HANG kh ON dh.ma_kh = kh.ma_kh
    JOIN  NHAN_VIEN  nv ON dh.ma_nv = nv.ma_nv
    WHERE dh.ma_dh = p_ma_dh;

    -- In header bao cao
    DBMS_OUTPUT.PUT_LINE('=== BAO CAO DON HANG: ' || p_ma_dh || ' ===');
    DBMS_OUTPUT.PUT_LINE('Khach hang : ' || v_ten_kh);
    DBMS_OUTPUT.PUT_LINE('Nhan vien  : ' || v_ten_nv);
    DBMS_OUTPUT.PUT_LINE('Ngay dat   : ' || TO_CHAR(v_ngay_dat, 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('Thanh toan : ' || v_pttt);
    IF v_ghi_chu IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Ghi chu    : ' || v_ghi_chu);
    END IF;
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 65, '-'));
    DBMS_OUTPUT.PUT_LINE(
        RPAD('STT', 4) || ' | ' ||
        RPAD('Ten san pham', 30) || ' | ' ||
        LPAD('SL', 4) || ' | ' ||
        LPAD('Don gia', 10) || ' | ' ||
        LPAD('GG%', 4) || ' | ' ||
        LPAD('Thanh tien', 12)
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 65, '-'));

    -- Duyet chi tiet don hang
    FOR rec IN (
        SELECT sp.ten_sp,
               ct.so_luong,
               ct.don_gia,
               ct.giam_gia_pct,
               ct.thanh_tien
        FROM CHI_TIET_DON_HANG ct
        JOIN SAN_PHAM sp ON ct.ma_sp = sp.ma_sp
        WHERE ct.ma_dh = p_ma_dh
        ORDER BY sp.ten_sp
    ) LOOP
        v_stt     := v_stt + 1;
        v_tong    := v_tong + 1;
        v_tong_tt := v_tong_tt + NVL(rec.thanh_tien, 0);

        DBMS_OUTPUT.PUT_LINE(
            LPAD(v_stt, 3) || ' | ' ||
            RPAD(rec.ten_sp, 30) || ' | ' ||
            LPAD(rec.so_luong, 4) || ' | ' ||
            LPAD(TO_CHAR(rec.don_gia, '999,999,999'), 10) || ' | ' ||
            LPAD(rec.giam_gia_pct || '%', 4) || ' | ' ||
            LPAD(TO_CHAR(NVL(rec.thanh_tien, 0), '999,999,999,999'), 12)
        );
    END LOOP;

    -- In footer
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 65, '-'));
    DBMS_OUTPUT.PUT_LINE('Tong so mat hang : ' || v_tong);
    DBMS_OUTPUT.PUT_LINE('TONG TIEN THANH TOAN: ' || TO_CHAR(v_tong_tt, '999,999,999,999') || ' VND');
    DBMS_OUTPUT.PUT_LINE(RPAD('=', 65, '='));
END report_donhang_detail;
/

-- Goi thu tuc:
SET SERVEROUTPUT ON SIZE 1000000;
BEGIN
    report_donhang_detail(10001);
    report_donhang_detail(10002);
END;
/


-- Cau 2.5: Thu tuc dong bo ton kho tu NHAP_KHO sang SAN_PHAM
--   Tuong duong: sync_grade_from_enrollment -> dong bo diem
--   Anh xa: NHAP_KHO ~ enrollment | SAN_PHAM.so_luong_ton ~ GRADE.grade
CREATE OR REPLACE PROCEDURE sync_tonkho_from_nhapkho IS
    v_dem_cap_nhat NUMBER := 0;
    v_tong_nhap    NUMBER := 0;
BEGIN
    -- Duyet tat ca phieu nhap kho, tinh lai ton kho cho tung san pham
    FOR rec IN (
        SELECT ma_sp, SUM(so_luong_nhap) AS tong_nhap
        FROM NHAP_KHO
        GROUP BY ma_sp
    ) LOOP
        -- Cap nhat so_luong_ton dua tren tong nhap - tong da ban
        UPDATE SAN_PHAM sp
        SET so_luong_ton = (
            -- Tong nhap kho
            (SELECT NVL(SUM(nk.so_luong_nhap), 0)
             FROM NHAP_KHO nk
             WHERE nk.ma_sp = rec.ma_sp)
            -
            -- Tong da ban qua chi tiet don hang
            (SELECT NVL(SUM(ct.so_luong), 0)
             FROM CHI_TIET_DON_HANG ct
             WHERE ct.ma_sp = rec.ma_sp)
        )
        WHERE sp.ma_sp = rec.ma_sp;

        v_dem_cap_nhat := v_dem_cap_nhat + 1;
        v_tong_nhap    := v_tong_nhap + rec.tong_nhap;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] Dong bo ton kho hoan tat!');
    DBMS_OUTPUT.PUT_LINE('  So san pham cap nhat: ' || v_dem_cap_nhat);
    DBMS_OUTPUT.PUT_LINE('  Tong so luong nhap  : ' || v_tong_nhap);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('[LOI] ' || SQLERRM);
END sync_tonkho_from_nhapkho;
/

-- Chay:
BEGIN sync_tonkho_from_nhapkho; END;
/


-- ============================================================
-- PHAN 3: TRIGGERS
-- ============================================================

-- Cau 3.1: Trigger kiem tra ton kho truoc khi them chi tiet don hang
--   Tuong duong: trg_check_capacity -> kiem tra suc chua khi dang ky
--   Anh xa: CHI_TIET_DON_HANG ~ enrollment | so_luong_ton ~ capacity
CREATE OR REPLACE TRIGGER trg_check_tonkho
BEFORE INSERT ON CHI_TIET_DON_HANG
FOR EACH ROW
DECLARE
    v_ton_kho NUMBER;
    v_ten_sp  VARCHAR2(200);
BEGIN
    -- Lay so luong ton kho hien tai
    SELECT so_luong_ton, ten_sp
    INTO v_ton_kho, v_ten_sp
    FROM SAN_PHAM WHERE ma_sp = :NEW.ma_sp;

    -- Tu choi neu khong du hang
    IF :NEW.so_luong > v_ton_kho THEN
        RAISE_APPLICATION_ERROR(-20010,
            'LOI: San pham "' || v_ten_sp || '" (ma ' || :NEW.ma_sp || ') '
            || 'chi con ' || v_ton_kho || ' don vi, '
            || 'khong du so luong yeu cau: ' || :NEW.so_luong
        );
    END IF;
END trg_check_tonkho;
/

-- Kiem tra trigger (them khi het hang):
-- INSERT INTO CHI_TIET_DON_HANG (ma_dh, ma_sp, so_luong, don_gia, giam_gia_pct)
-- VALUES (10001, 104, 9999, 5000, 0);


-- Cau 3.2: Tao bang log va trigger ghi nhat ky thay doi gia ban
--   Tuong duong: trg_grade_audit_log -> ghi nhat ky thay doi diem
--   Anh xa: SAN_PHAM.gia_ban ~ enrollment.finalgrade
CREATE TABLE gia_ban_audit_log (
    log_id        NUMBER GENERATED ALWAYS AS IDENTITY,
    ma_sp         NUMBER(8),
    ten_sp        VARCHAR2(200),
    gia_ban_cu    NUMBER(12),
    gia_ban_moi   NUMBER(12),
    nguoi_sua     VARCHAR2(30),
    thoi_gian     DATE
);
/

CREATE OR REPLACE TRIGGER trg_giaban_audit_log
AFTER UPDATE OF gia_ban ON SAN_PHAM
FOR EACH ROW
BEGIN
    -- Chi ghi log khi gia thuc su thay doi
    IF :OLD.gia_ban != :NEW.gia_ban THEN
        INSERT INTO gia_ban_audit_log
            (ma_sp, ten_sp, gia_ban_cu, gia_ban_moi, nguoi_sua, thoi_gian)
        VALUES
            (:OLD.ma_sp, :OLD.ten_sp, :OLD.gia_ban, :NEW.gia_ban, USER, SYSDATE);
    END IF;
END trg_giaban_audit_log;
/

-- Kiem tra:
UPDATE SAN_PHAM SET gia_ban = 40000 WHERE ma_sp = 101;
COMMIT;
SELECT * FROM gia_ban_audit_log;


-- Cau 3.3: Trigger ngan xoa danh muc dang co san pham
--   Tuong duong: trg_prevent_course_delete -> ngan xoa mon hoc dang co lop
--   Anh xa: DANH_MUC ~ course | SAN_PHAM ~ class
CREATE OR REPLACE TRIGGER trg_prevent_danhmuc_delete
BEFORE DELETE ON DANH_MUC
FOR EACH ROW
DECLARE
    v_so_sp NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_so_sp
    FROM SAN_PHAM WHERE ma_danh_muc = :OLD.ma_danh_muc;

    IF v_so_sp > 0 THEN
        RAISE_APPLICATION_ERROR(-20020,
            'Khong the xoa danh muc ' || :OLD.ma_danh_muc
            || ' (' || :OLD.ten_danh_muc || ') '
            || 'vi con ' || v_so_sp || ' san pham thuoc danh muc nay!'
        );
    END IF;
    -- Neu v_so_sp = 0: trigger ket thuc binh thuong, Oracle tien hanh xoa
END trg_prevent_danhmuc_delete;
/

-- Kiem tra: xoa danh muc co san pham (se bao loi)
-- DELETE FROM DANH_MUC WHERE ma_danh_muc = 1;

-- Kiem tra: xoa danh muc khong co san pham (thanh cong)
-- DELETE FROM DANH_MUC WHERE ma_danh_muc = 6;
-- ROLLBACK;


-- Cau 3.4: Tao bang thong ke va trigger cap nhat tu dong theo danh muc
--   Tuong duong: trg_update_grade_summary -> cap nhat bang thong ke tu dong
--   Anh xa: SAN_PHAM ~ enrollment | DANH_MUC ~ class | CHI_TIET_DON_HANG ~ grade
CREATE TABLE danhmuc_doanhthu_summary (
    ma_danh_muc     NUMBER(5) PRIMARY KEY,
    ten_danh_muc    VARCHAR2(100),
    so_san_pham     NUMBER,
    tong_ton_kho    NUMBER,
    gia_ban_tb      NUMBER(12, 0),
    gia_ban_cao     NUMBER(12, 0),
    gia_ban_thap    NUMBER(12, 0),
    cap_nhat_luc    DATE
);
/

CREATE OR REPLACE TRIGGER trg_update_danhmuc_summary
AFTER INSERT OR UPDATE OR DELETE ON SAN_PHAM
FOR EACH ROW
DECLARE
    v_ma_dm      NUMBER;
    v_ten_dm     VARCHAR2(100);
    v_so_sp      NUMBER;
    v_ton_kho    NUMBER;
    v_gia_tb     NUMBER;
    v_gia_cao    NUMBER;
    v_gia_thap   NUMBER;
BEGIN
    -- Lay ma danh muc bi anh huong
    IF INSERTING OR UPDATING THEN
        v_ma_dm := :NEW.ma_danh_muc;
    ELSE -- DELETING
        v_ma_dm := :OLD.ma_danh_muc;
    END IF;

    -- Lay ten danh muc
    SELECT ten_danh_muc INTO v_ten_dm FROM DANH_MUC WHERE ma_danh_muc = v_ma_dm;

    -- Tinh lai thong ke cho danh muc bi anh huong
    SELECT COUNT(*),
           NVL(SUM(so_luong_ton), 0),
           ROUND(AVG(gia_ban), 0),
           MAX(gia_ban),
           MIN(gia_ban)
    INTO v_so_sp, v_ton_kho, v_gia_tb, v_gia_cao, v_gia_thap
    FROM SAN_PHAM
    WHERE ma_danh_muc = v_ma_dm;

    -- MERGE de cap nhat hoac them moi
    MERGE INTO danhmuc_doanhthu_summary dds
    USING (SELECT v_ma_dm AS cid FROM DUAL) src
    ON (dds.ma_danh_muc = src.cid)
    WHEN MATCHED THEN
        UPDATE SET
            ten_danh_muc  = v_ten_dm,
            so_san_pham   = v_so_sp,
            tong_ton_kho  = v_ton_kho,
            gia_ban_tb    = v_gia_tb,
            gia_ban_cao   = v_gia_cao,
            gia_ban_thap  = v_gia_thap,
            cap_nhat_luc  = SYSDATE
    WHEN NOT MATCHED THEN
        INSERT (ma_danh_muc, ten_danh_muc, so_san_pham,
                tong_ton_kho, gia_ban_tb, gia_ban_cao, gia_ban_thap, cap_nhat_luc)
        VALUES (v_ma_dm, v_ten_dm, v_so_sp,
                v_ton_kho, v_gia_tb, v_gia_cao, v_gia_thap, SYSDATE);
END trg_update_danhmuc_summary;
/

-- Kiem tra:
UPDATE SAN_PHAM SET gia_ban = 45000 WHERE ma_sp = 101;
COMMIT;
SELECT * FROM danhmuc_doanhthu_summary WHERE ma_danh_muc = 1;


-- ============================================================
-- PHAN 4: BAO CAO TONG HOP
-- ============================================================

-- Cau 4.1: View hieu suat nhan vien ban hang
--   Tuong duong: vw_instructor_workload -> tai trong giao vien
--   Anh xa: NHAN_VIEN ~ instructor | DON_HANG ~ class | CHI_TIET_DON_HANG ~ enrollment
CREATE OR REPLACE VIEW vw_nhanvien_hieusuat AS
SELECT
    nv.ma_nv,
    nv.ho_ten,
    nv.chuc_vu,
    COUNT(DISTINCT dh.ma_dh)            AS so_don_hang,
    NVL(SUM(dh.tong_tien), 0)          AS tong_doanh_thu,
    ROUND(AVG(dh.tong_tien), 0)        AS doanh_thu_tb_don,
    CASE
        WHEN COUNT(DISTINCT dh.ma_dh) >= 3 THEN 'Xuat sac'
        WHEN COUNT(DISTINCT dh.ma_dh) = 2  THEN 'Kha'
        WHEN COUNT(DISTINCT dh.ma_dh) = 1  THEN 'Trung binh'
        ELSE 'Chua co don'
    END                                 AS xep_loai
FROM NHAN_VIEN nv
LEFT JOIN DON_HANG dh ON nv.ma_nv = dh.ma_nv
GROUP BY nv.ma_nv, nv.ho_ten, nv.chuc_vu
ORDER BY tong_doanh_thu DESC;

-- Kiem tra:
SELECT * FROM vw_nhanvien_hieusuat;


-- Thu tuc in bao cao toan he thong cua hang
--   Tuong duong: print_system_report -> bao cao toan he thong
CREATE OR REPLACE PROCEDURE print_cuahang_report IS
    v_so_dm   NUMBER;
    v_so_sp   NUMBER;
    v_so_kh   NUMBER;
    v_so_nv   NUMBER;
    v_so_dh   NUMBER;
    v_doanh_thu NUMBER;
BEGIN
    -- Lay so lieu tong the
    SELECT COUNT(*) INTO v_so_dm  FROM DANH_MUC;
    SELECT COUNT(*) INTO v_so_sp  FROM SAN_PHAM;
    SELECT COUNT(*) INTO v_so_kh  FROM KHACH_HANG;
    SELECT COUNT(*) INTO v_so_nv  FROM NHAN_VIEN;
    SELECT COUNT(*) INTO v_so_dh  FROM DON_HANG;
    SELECT NVL(SUM(tong_tien), 0) INTO v_doanh_thu FROM DON_HANG;

    -- In header
    DBMS_OUTPUT.PUT_LINE('================================================');
    DBMS_OUTPUT.PUT_LINE('      BAO CAO TONG HOP HE THONG CUA HANG');
    DBMS_OUTPUT.PUT_LINE('================================================');
    DBMS_OUTPUT.PUT_LINE('Tong so danh muc    : ' || v_so_dm);
    DBMS_OUTPUT.PUT_LINE('Tong so san pham    : ' || v_so_sp);
    DBMS_OUTPUT.PUT_LINE('Tong so khach hang  : ' || v_so_kh);
    DBMS_OUTPUT.PUT_LINE('Tong so nhan vien   : ' || v_so_nv);
    DBMS_OUTPUT.PUT_LINE('Tong so don hang    : ' || v_so_dh);
    DBMS_OUTPUT.PUT_LINE('Tong doanh thu      : ' || TO_CHAR(v_doanh_thu, '999,999,999,999') || ' VND');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 55, '-'));

    -- Phan 1: Hieu suat nhan vien (dung view vw_nhanvien_hieusuat)
    DBMS_OUTPUT.PUT_LINE('HIEU SUAT NHAN VIEN:');
    FOR rec IN (SELECT * FROM vw_nhanvien_hieusuat) LOOP
        DBMS_OUTPUT.PUT_LINE(
            '  ' || RPAD(rec.ho_ten, 25)
            || ' | ' || LPAD(rec.so_don_hang, 3) || ' don'
            || ' | ' || LPAD(TO_CHAR(rec.tong_doanh_thu, '999,999,999'), 12) || ' VND'
            || ' | ' || rec.xep_loai
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 55, '-'));

    -- Phan 2: Top 5 san pham ban chay (dung view vw_top_sanpham)
    DBMS_OUTPUT.PUT_LINE('TOP 5 SAN PHAM BAN CHAY NHAT:');
    FOR rec IN (SELECT * FROM vw_top_sanpham) LOOP
        DBMS_OUTPUT.PUT_LINE(
            '  ' || rec.hang || '. '
            || RPAD(rec.ten_sp, 35)
            || ' - ' || rec.tong_so_luong_ban || ' sp ban'
            || ' | ' || TO_CHAR(rec.tong_doanh_thu, '999,999,999') || ' VND'
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 55, '-'));

    -- Phan 3: Tong quan ton kho theo danh muc (dung view vw_sanpham_summary)
    DBMS_OUTPUT.PUT_LINE('TON KHO THEO DANH MUC:');
    FOR rec IN (SELECT * FROM vw_sanpham_summary) LOOP
        DBMS_OUTPUT.PUT_LINE(
            '  ' || RPAD(rec.ten_danh_muc, 25)
            || ' | ' || LPAD(rec.so_san_pham, 3) || ' SP'
            || ' | Ton kho: ' || LPAD(rec.tong_ton_kho, 6)
            || ' | Gia TB: ' || TO_CHAR(rec.gia_ban_tb, '999,999') || ' VND'
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('================================================');
END print_cuahang_report;
/

-- Chay bao cao:
SET SERVEROUTPUT ON SIZE 1000000;
BEGIN print_cuahang_report; END;
/
