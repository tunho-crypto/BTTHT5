-- ============================================================
--  BÀI THỰC HÀNH ORACLE BUỔI 1
--  Lược đồ CSDL: s_region, s_dept, s_emp, s_customer,
--                 s_product, s_ord, s_item, s_inventory,
--                 s_warehouse, s_title, s_image, s_longtext
-- ============================================================

-- Bước 1: Kiểm tra user hiện tại
SHOW USER;

-- ============================================================
-- Bước 2: XÓA BẢNG CŨ (nếu đã tồn tại) - thứ tự ngược lại
-- ============================================================
DROP TABLE s_inventory   CASCADE CONSTRAINTS PURGE;
DROP TABLE s_item        CASCADE CONSTRAINTS PURGE;
DROP TABLE s_ord         CASCADE CONSTRAINTS PURGE;
DROP TABLE s_warehouse   CASCADE CONSTRAINTS PURGE;
DROP TABLE s_inventory   CASCADE CONSTRAINTS PURGE;
DROP TABLE s_customer    CASCADE CONSTRAINTS PURGE;
DROP TABLE s_emp         CASCADE CONSTRAINTS PURGE;
DROP TABLE s_product     CASCADE CONSTRAINTS PURGE;
DROP TABLE s_longtext    CASCADE CONSTRAINTS PURGE;
DROP TABLE s_image       CASCADE CONSTRAINTS PURGE;
DROP TABLE s_dept        CASCADE CONSTRAINTS PURGE;
DROP TABLE s_title       CASCADE CONSTRAINTS PURGE;
DROP TABLE s_region      CASCADE CONSTRAINTS PURGE;

-- ============================================================
-- Bước 3: TẠO BẢNG (thứ tự: bảng cha trước bảng con)
-- ============================================================

-- 1. s_region (bảng gốc, không có FK)
CREATE TABLE s_region (
    id   NUMBER(7)    CONSTRAINT s_region_id_pk PRIMARY KEY,
    name VARCHAR2(50) CONSTRAINT s_region_name_nn NOT NULL
);

-- 2. s_title (bảng độc lập)
CREATE TABLE s_title (
    title VARCHAR2(25) CONSTRAINT s_title_pk PRIMARY KEY
);

-- 3. s_image (bảng độc lập)
CREATE TABLE s_image (
    id           NUMBER(7)    CONSTRAINT s_image_id_pk PRIMARY KEY,
    format       VARCHAR2(10),
    use_filename VARCHAR2(1),
    filename     VARCHAR2(30),
    image        LONG RAW
);

-- 4. s_longtext (bảng độc lập)
CREATE TABLE s_longtext (
    id           NUMBER(7)    CONSTRAINT s_longtext_id_pk PRIMARY KEY,
    use_filename VARCHAR2(1),
    filename     VARCHAR2(30),
    text         LONG
);

-- 5. s_dept (FK → s_region)
CREATE TABLE s_dept (
    id        NUMBER(7)    CONSTRAINT s_dept_id_pk PRIMARY KEY,
    name      VARCHAR2(25) CONSTRAINT s_dept_name_nn NOT NULL,
    region_id NUMBER(7)    CONSTRAINT s_dept_region_id_fk
                               REFERENCES s_region(id)
);

-- 6. s_emp (FK → s_dept, s_title, self-ref manager_id)
CREATE TABLE s_emp (
    id             NUMBER(7)      CONSTRAINT s_emp_id_pk PRIMARY KEY,
    last_name      VARCHAR2(25)   CONSTRAINT s_emp_last_name_nn NOT NULL,
    first_name     VARCHAR2(25),
    userid         VARCHAR2(8)    CONSTRAINT s_emp_userid_uk UNIQUE,
    start_date     DATE,
    comments       VARCHAR2(255),
    manager_id     NUMBER(7)      CONSTRAINT s_emp_manager_id_fk
                                      REFERENCES s_emp(id),
    title          VARCHAR2(25)   CONSTRAINT s_emp_title_fk
                                      REFERENCES s_title(title),
    dept_id        NUMBER(7)      CONSTRAINT s_emp_dept_id_fk
                                      REFERENCES s_dept(id),
    salary         NUMBER(11, 2),
    commission_pct NUMBER(4, 2)   CONSTRAINT s_emp_commission_pct_ck
                                      CHECK (commission_pct IN (10, 12.5, 15, 17.5, 20))
);

-- 7. s_customer (FK → s_region, s_emp)
CREATE TABLE s_customer (
    id            NUMBER(7)    CONSTRAINT s_customer_id_pk PRIMARY KEY,
    name          VARCHAR2(50) CONSTRAINT s_customer_name_nn NOT NULL,
    phone         VARCHAR2(25),
    address       VARCHAR2(400),
    city          VARCHAR2(30),
    state         VARCHAR2(20),
    country       VARCHAR2(30),
    zip_code      VARCHAR2(75),
    credit_rating VARCHAR2(9)  CONSTRAINT s_customer_credit_ck
                                   CHECK (credit_rating IN ('EXCELLENT','GOOD','POOR')),
    sales_rep_id  NUMBER(7)    CONSTRAINT s_customer_sales_rep_fk
                                   REFERENCES s_emp(id),
    region_id     NUMBER(7)    CONSTRAINT s_customer_region_id_fk
                                   REFERENCES s_region(id),
    comments      VARCHAR2(255)
);

-- 8. s_product (FK → s_longtext, s_image)
CREATE TABLE s_product (
    id                    NUMBER(7)      CONSTRAINT s_product_id_pk PRIMARY KEY,
    name                  VARCHAR2(50)   CONSTRAINT s_product_name_nn NOT NULL,
    short_desc            VARCHAR2(255),
    longtext_id           NUMBER(7)      CONSTRAINT s_product_longtext_fk
                                             REFERENCES s_longtext(id),
    image_id              NUMBER(7)      CONSTRAINT s_product_image_fk
                                             REFERENCES s_image(id),
    suggested_whlsl_price NUMBER(11, 2)  CONSTRAINT s_product_price_ck
                                             CHECK (suggested_whlsl_price > 0),
    whlsl_units           VARCHAR2(30)
);

-- 9. s_warehouse (FK → s_region, s_emp)
CREATE TABLE s_warehouse (
    id         NUMBER(7)    CONSTRAINT s_warehouse_id_pk PRIMARY KEY,
    region_id  NUMBER(7)    CONSTRAINT s_warehouse_region_fk
                                REFERENCES s_region(id),
    address    VARCHAR2(400),
    city       VARCHAR2(30),
    state      VARCHAR2(20),
    country    VARCHAR2(30),
    zip_code   VARCHAR2(75),
    phone      VARCHAR2(25),
    manager_id NUMBER(7)    CONSTRAINT s_warehouse_manager_fk
                                REFERENCES s_emp(id)
);

-- 10. s_ord (FK → s_customer, s_emp)
CREATE TABLE s_ord (
    id           NUMBER(7)      CONSTRAINT s_ord_id_pk PRIMARY KEY,
    customer_id  NUMBER(7)      CONSTRAINT s_ord_customer_id_nn NOT NULL
                                    CONSTRAINT s_ord_customer_id_fk
                                    REFERENCES s_customer(id),
    date_ordered DATE           DEFAULT SYSDATE,
    date_shipped DATE,
    sales_rep_id NUMBER(7)      CONSTRAINT s_ord_sales_rep_fk
                                    REFERENCES s_emp(id),
    total        NUMBER(11, 2),
    payment_type VARCHAR2(6)    CONSTRAINT s_ord_payment_type_ck
                                    CHECK (payment_type IN ('CASH','CHECK','CREDIT')),
    order_filled VARCHAR2(1)    DEFAULT 'N'
                                    CONSTRAINT s_ord_order_filled_ck
                                    CHECK (order_filled IN ('Y','N'))
);

-- 11. s_item (FK → s_ord, s_product)
CREATE TABLE s_item (
    ord_id           NUMBER(7)  CONSTRAINT s_item_ord_id_nn NOT NULL,
    item_id          NUMBER(7)  CONSTRAINT s_item_item_id_nn NOT NULL,
    product_id       NUMBER(7)  CONSTRAINT s_item_product_id_fk
                                    REFERENCES s_product(id),
    price            NUMBER(11, 2),
    quantity         NUMBER(9),
    quantity_shipped NUMBER(9),
    CONSTRAINT s_item_pk PRIMARY KEY (ord_id, item_id),
    CONSTRAINT s_item_ord_id_fk FOREIGN KEY (ord_id)
        REFERENCES s_ord(id)
);

-- 12. s_inventory (FK → s_product, s_warehouse)
CREATE TABLE s_inventory (
    product_id              NUMBER(7)  CONSTRAINT s_inventory_product_id_nn NOT NULL,
    warehouse_id            NUMBER(7)  CONSTRAINT s_inventory_warehouse_id_nn NOT NULL,
    amount_in_stock         NUMBER(9),
    reorder_point           NUMBER(9),
    max_in_stock            NUMBER(9),
    out_of_stock_explanation VARCHAR2(255),
    restock_date            DATE,
    CONSTRAINT s_inventory_pk PRIMARY KEY (product_id, warehouse_id),
    CONSTRAINT s_inventory_product_fk FOREIGN KEY (product_id)
        REFERENCES s_product(id),
    CONSTRAINT s_inventory_warehouse_fk FOREIGN KEY (warehouse_id)
        REFERENCES s_warehouse(id)
);

-- ============================================================
-- Bước 4: KIỂM TRA CẤU TRÚC BẢNG
-- ============================================================
DESC s_region;
DESC s_dept;
DESC s_emp;
DESC s_customer;
DESC s_product;
DESC s_ord;
DESC s_item;
DESC s_inventory;
DESC s_warehouse;

-- Xem danh sách tất cả bảng của user hiện tại
SELECT table_name FROM user_tables ORDER BY table_name;

-- ============================================================
-- Bước 5: NHẬP DỮ LIỆU MẪU
-- ============================================================

-- s_region
INSERT INTO s_region VALUES (1, 'North America');
INSERT INTO s_region VALUES (2, 'South America');
INSERT INTO s_region VALUES (3, 'Africa / Middle East');
INSERT INTO s_region VALUES (4, 'Asia');
INSERT INTO s_region VALUES (5, 'Europe');
COMMIT;

-- s_title
INSERT INTO s_title VALUES ('President');
INSERT INTO s_title VALUES ('VP, Operations');
INSERT INTO s_title VALUES ('VP, Sales');
INSERT INTO s_title VALUES ('VP, Finance');
INSERT INTO s_title VALUES ('Administration');
INSERT INTO s_title VALUES ('Warehouse Manager');
INSERT INTO s_title VALUES ('Sales Representative');
INSERT INTO s_title VALUES ('Stock Clerk');
INSERT INTO s_title VALUES ('Shipping Clerk');
INSERT INTO s_title VALUES ('Account Manager');
COMMIT;

-- s_dept
INSERT INTO s_dept VALUES (10, 'Finance',       1);
INSERT INTO s_dept VALUES (31, 'Sales',         1);
INSERT INTO s_dept VALUES (32, 'Sales',         2);
INSERT INTO s_dept VALUES (33, 'Sales',         3);
INSERT INTO s_dept VALUES (34, 'Sales',         4);
INSERT INTO s_dept VALUES (35, 'Sales',         5);
INSERT INTO s_dept VALUES (41, 'Operations',    1);
INSERT INTO s_dept VALUES (42, 'Operations',    2);
INSERT INTO s_dept VALUES (43, 'Operations',    3);
INSERT INTO s_dept VALUES (44, 'Operations',    4);
INSERT INTO s_dept VALUES (45, 'Operations',    5);
INSERT INTO s_dept VALUES (50, 'Administration',1);
COMMIT;

-- s_emp (nhân viên cấp cao không có manager trước)
INSERT INTO s_emp VALUES (1,'Velasquez','Carmen','cvelasqu',TO_DATE('03-03-1990','DD-MM-YYYY'),NULL,NULL,'President',50,2500,NULL);
INSERT INTO s_emp VALUES (2,'Ngao','LaDoris','lngao',TO_DATE('08-08-1990','DD-MM-YYYY'),NULL,1,'VP, Operations',41,1450,NULL);
INSERT INTO s_emp VALUES (3,'Nagayama','Midori','mnagayam',TO_DATE('17-06-1991','DD-MM-YYYY'),NULL,1,'VP, Sales',31,1400,NULL);
INSERT INTO s_emp VALUES (4,'Quick-To-See','Mark','mquidkto',TO_DATE('07-02-1990','DD-MM-YYYY'),NULL,1,'VP, Finance',10,1450,NULL);
INSERT INTO s_emp VALUES (5,'Ropeburn','Audry','aropebur',TO_DATE('04-03-1990','DD-MM-YYYY'),NULL,1,'Administration',50,1300,NULL);
INSERT INTO s_emp VALUES (6,'Urguhart','Molly','murguhar',TO_DATE('18-01-1991','DD-MM-YYYY'),NULL,2,'Warehouse Manager',41,750,NULL);
INSERT INTO s_emp VALUES (7,'Menchu','Roberta','rmenchu',TO_DATE('07-06-1991','DD-MM-YYYY'),NULL,2,'Warehouse Manager',42,800,NULL);
INSERT INTO s_emp VALUES (8,'Biri','Ben','bbiri',TO_DATE('07-08-1991','DD-MM-YYYY'),NULL,2,'Warehouse Manager',43,1100,NULL);
INSERT INTO s_emp VALUES (9,'Catchpole','Antoinette','acatchpo',TO_DATE('27-02-1992','DD-MM-YYYY'),NULL,2,'Warehouse Manager',44,1300,NULL);
INSERT INTO s_emp VALUES (10,'Havel','Marta','mhavel',TO_DATE('07-02-1993','DD-MM-YYYY'),NULL,2,'Warehouse Manager',45,1307,NULL);
INSERT INTO s_emp VALUES (11,'Magee','Colin','cmagee',TO_DATE('18-05-1990','DD-MM-YYYY'),NULL,3,'Sales Representative',31,1400,10);
INSERT INTO s_emp VALUES (12,'Giljum','Henry','hgiljum',TO_DATE('18-01-1992','DD-MM-YYYY'),NULL,3,'Sales Representative',32,1490,12.5);
INSERT INTO s_emp VALUES (13,'Sedeghi','Yasmin','ysedeghi',TO_DATE('18-10-1991','DD-MM-YYYY'),NULL,3,'Sales Representative',33,1515,NULL);
INSERT INTO s_emp VALUES (14,'Nguyen','Mai','mnguyen',TO_DATE('08-02-1994','DD-MM-YYYY'),NULL,3,'Sales Representative',34,1525,17.5);
INSERT INTO s_emp VALUES (15,'Dumas','Andre','adumas',TO_DATE('09-10-1987','DD-MM-YYYY'),NULL,3,'Sales Representative',35,1450,17.5);
INSERT INTO s_emp VALUES (16,'Maduro','Elena','emaduro',TO_DATE('07-02-1992','DD-MM-YYYY'),NULL,6,'Stock Clerk',41,1400,NULL);
INSERT INTO s_emp VALUES (17,'Smith','George','gsmith',TO_DATE('08-03-1990','DD-MM-YYYY'),NULL,6,'Stock Clerk',41,940,NULL);
INSERT INTO s_emp VALUES (18,'Nozaki','Akira','anozaki',TO_DATE('10-02-1991','DD-MM-YYYY'),NULL,7,'Stock Clerk',42,1200,NULL);
INSERT INTO s_emp VALUES (19,'Patel','Vikram','vpatel',TO_DATE('06-08-1991','DD-MM-YYYY'),NULL,7,'Stock Clerk',42,795,NULL);
INSERT INTO s_emp VALUES (20,'Newman','Chad','cnewman',TO_DATE('11-11-1991','DD-MM-YYYY'),NULL,8,'Stock Clerk',43,750,NULL);
INSERT INTO s_emp VALUES (21,'Markarian','Alexander','amarkari',TO_DATE('26-07-1991','DD-MM-YYYY'),NULL,8,'Stock Clerk',43,850,NULL);
INSERT INTO s_emp VALUES (22,'Chang','Eddie','echang',TO_DATE('30-01-1993','DD-MM-YYYY'),NULL,9,'Stock Clerk',44,800,NULL);
INSERT INTO s_emp VALUES (23,'Patel','Radha','rpatel',TO_DATE('04-10-1993','DD-MM-YYYY'),NULL,9,'Stock Clerk',44,795,NULL);
INSERT INTO s_emp VALUES (24,'Dancs','Bela','bdancs',TO_DATE('17-02-1994','DD-MM-YYYY'),NULL,10,'Stock Clerk',45,860,NULL);
INSERT INTO s_emp VALUES (25,'Schwartz','Sylvie','sschwart',TO_DATE('09-05-1993','DD-MM-YYYY'),NULL,10,'Stock Clerk',45,1100,NULL);
COMMIT;

-- s_customer (mẫu)
INSERT INTO s_customer VALUES (201,'Unisports','55-2066101','72 Via Bahia','Sao Paulo',NULL,'Brazil','00219',  'EXCELLENT',12,2,NULL);
INSERT INTO s_customer VALUES (202,'Simms Athletics','1-612-555-2739','4328 36th Ave','Minneapolis','MN','USA','55441',    'GOOD',11,1,NULL);
INSERT INTO s_customer VALUES (203,'Delhi Sports','011-351-6401','11368 Chanakya','New Delhi',NULL,'India','110001',       'POOR',14,4,NULL);
INSERT INTO s_customer VALUES (204,'Womansport','01-539-6433','Stationsplein 47','Amsterdam',NULL,'Netherlands','1002BL', 'EXCELLENT',15,5,NULL);
INSERT INTO s_customer VALUES (205,'Kam's Sporting','57-3598','2nd Street','Tainan',NULL,'Taiwan','60600',                'EXCELLENT',14,4,NULL);
INSERT INTO s_customer VALUES (206,'Sportique','33-1-47-23-06-39','97 Avenue Parmentier','Paris','94',       'France','75541','EXCELLENT',15,5,NULL);
INSERT INTO s_customer VALUES (207,'Tall Stadiums','673-7646','98 Skyline Dr.','Makati City',NULL,'Philippines','3117',  'GOOD',14,4,NULL);
INSERT INTO s_customer VALUES (208,'Muench Sports','49-441-4400','4 Hannoversche Str.','Kaiserslautern',NULL,'Germany','67663','GOOD',15,5,NULL);
INSERT INTO s_customer VALUES (209,'Beisbol Si!','809-683-5555','Avenue Duarte 622','Santo Domingo',NULL,'Dominican Republic','null','EXCELLENT',12,2,NULL);
INSERT INTO s_customer VALUES (210,'Futbol Sonora','83-49-25','44 Morelos','Nogales','Sonora','Mexico','84000','EXCELLENT',12,2,NULL);
COMMIT;

-- s_longtext (mẫu)
INSERT INTO s_longtext VALUES (1,'N',NULL,'Climbing Harness Safety System');
INSERT INTO s_longtext VALUES (2,'N',NULL,'Professional Climbing Boots');
INSERT INTO s_longtext VALUES (3,'N',NULL,'Folding Bicycle Frame');
COMMIT;

-- s_image (mẫu - không có binary data)
INSERT INTO s_image (id, format, use_filename, filename) VALUES (1,'GIF','N','climbing_harness');
INSERT INTO s_image (id, format, use_filename, filename) VALUES (2,'GIF','N','climbing_boots');
INSERT INTO s_image (id, format, use_filename, filename) VALUES (3,'GIF','N','folding_bike');
COMMIT;

-- s_product (mẫu)
INSERT INTO s_product VALUES (10001,'Harnais D''escalade','Super confort',1,1,  2500,NULL);
INSERT INTO s_product VALUES (10002,'Chaussures Pro Climb','Semelle adhérente',2,2,1200,NULL);
INSERT INTO s_product VALUES (10003,'Vélo Pliant','Léger et robuste',3,3,    5000,NULL);
COMMIT;

-- s_warehouse (mẫu)
INSERT INTO s_warehouse VALUES (1,1,'Warehouse District','Ashtabula',   'OH','USA','44004','800-555-0001',6);
INSERT INTO s_warehouse VALUES (2,2,'Zona Industrial','Sao Paulo',NULL, 'Brazil','06120','55-011-512-5432',7);
INSERT INTO s_warehouse VALUES (3,4,'Yoido P.O.Box','Seoul',NULL,       'Korea','150010','82-2-552-4242',8);
INSERT INTO s_warehouse VALUES (4,4,'Block 5 Queensway','Singapore',    NULL,'Singapore','','65-533-6648',9);
INSERT INTO s_warehouse VALUES (5,5,'Rijnsburgstraat','Amsterdam',NULL, 'Netherlands','1059AT','31-20-617-2826',10);
COMMIT;

-- s_ord (mẫu)
INSERT INTO s_ord VALUES (100,204,TO_DATE('31-08-1992','DD-MM-YYYY'),TO_DATE('07-09-1992','DD-MM-YYYY'),15,601.20,'CREDIT','Y');
INSERT INTO s_ord VALUES (101,207,TO_DATE('01-09-1992','DD-MM-YYYY'),TO_DATE('08-09-1992','DD-MM-YYYY'),14,8056.00,'CASH','Y');
INSERT INTO s_ord VALUES (102,206,TO_DATE('02-09-1992','DD-MM-YYYY'),TO_DATE('09-09-1992','DD-MM-YYYY'),15,6400.00,'CREDIT','Y');
INSERT INTO s_ord VALUES (103,208,TO_DATE('03-09-1992','DD-MM-YYYY'),TO_DATE('10-09-1992','DD-MM-YYYY'),15,4800.00,'CREDIT','N');
COMMIT;

-- s_item (mẫu)
INSERT INTO s_item VALUES (100,1,10001,2500,1,1);
INSERT INTO s_item VALUES (101,1,10002,1200,4,4);
INSERT INTO s_item VALUES (102,1,10003,5000,1,1);
INSERT INTO s_item VALUES (103,1,10001,2500,2,0);
COMMIT;

-- s_inventory (mẫu)
INSERT INTO s_inventory VALUES (10001,1,10,5,50,NULL,NULL);
INSERT INTO s_inventory VALUES (10001,2,5, 3,30,NULL,NULL);
INSERT INTO s_inventory VALUES (10002,3,20,8,80,NULL,NULL);
INSERT INTO s_inventory VALUES (10003,4,15,5,60,NULL,NULL);
COMMIT;

-- ============================================================
-- Bước 6: KIỂM TRA DỮ LIỆU ĐÃ NHẬP
-- ============================================================
SELECT * FROM s_region;
SELECT * FROM s_dept;
SELECT * FROM s_title;
SELECT * FROM s_emp;
SELECT * FROM s_customer;
SELECT * FROM s_product;
SELECT * FROM s_warehouse;
SELECT * FROM s_ord;
SELECT * FROM s_item;
SELECT * FROM s_inventory;

-- ============================================================
-- KẾT THÚC BÀI THỰC HÀNH BUỔI 1
-- ============================================================
