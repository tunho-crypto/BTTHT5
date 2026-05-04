-- Bài 2
-- Câu 1 - Hiện thị tên, mã khách hàng - đặt alias cho cột, sắp xếp giảm dần theo mã
select name as "Ten khach hang",
    id as "Ma khach hang"
from s_customer
order by id desc;

-- Câu 2 - Họ, tên và mã phòng nhân viên phòng 10 và 50 - nối họ tên thành cột 'Employees', sắp theo tên
select first_name ||''|| last_name as "Employees",
    dept_id
from s_emp
where dept_id IN(10, 50)
order by first_name;

-- Câu 3 - Hiển thị tất cả nhân viên có chứa chữ 'S'
select last_name, first_name
from s_emp
where first_name like '%S%'
    or last_name like '%S%';
    
-- Câu 4 - Tên truy cập và ngày bắt đầu làm việc từ 14/5/1990 đến 26/5/1991
select userid, start_date
from s_emp
where start_date between to_date('14/05/1990','dd/mm/yyyy')
    and to_date('26/05/1991','dd/mm/yyyy');
    
-- Câu 5 - Tên và lương nhân viên nhận lương từ 1000 đến 2000/tháng
select last_name, salary
from s_emp
where salary between 1000 and 2000;

-- Câu 6 - Nhân viên phòng 31, 42, 50 nhận lương trên 1350 - đặt alias 'Employee Name' và 'Monthly Salary'
SELECT last_name || ' ' || first_name AS "Employee Name",
salary AS "Monthly Salary"
FROM s_emp
WHERE dept_id IN (31, 42, 50)
AND salary > 1350;

-- Câu 7 - Tên và ngày bắt đầu làm việc của nhân viên được tuyển trong năm 1991
select last_name, start_date
from s_emp
where to_char(start_date, 'yyyy') = '1991';

-- Câu 8 - Họ tên tất cả nhân viên không phải là người quản lý
select last_name, first_name
from s_emp
where id not in (select distinct manager_id
    from s_emp
    where manager_id is not null);
    
-- Câu 9 - Sản phẩm có tên bắt đầu với từ 'Pro', hiển thị theo thứ tự abc
SELECT name
FROM s_product
WHERE name LIKE 'Pro%'
ORDER BY name ASC;

-- Câu 10 - Tên và short decs của sản phẩm có mô tả chứa từ 'bicycle'
SELECT name, short_desc
FROM s_product
WHERE LOWER(short_desc) LIKE '%bicycle%';

-- Câu 11 - Hiển thị tất cả short_desc
SELECT short_desc
FROM s_product;

-- Câu 12 - Tên nhân viên và chức vụ trong ngoặc đơn 
SELECT last_name || ' ' || first_name || ' (' || title || ')' AS "Nhan vien"
FROM s_emp;

-- Bài 3
-- Câu 1 - Mã nhân viên, tên và mức lương được tăng thêm 15%
select id,
    last_name,
    round(salary * 1.15, 2) as "Luong moi"
from s_emp;

-- Câu 2 - Tên nhân viên, ngày tuyển dụng và ngày xét tăng lương
SELECT last_name,
start_date,
TO_CHAR(
NEXT_DAY(ADD_MONTHS(start_date, 6), 'MONDAY'),'Ddspth "of" Month YYYY') AS "Ngay xet tang luong"
FROM s_emp;

-- Câu 3 - Tên sản phẩm của tất cả sản phẩm có chữ 'ski'
SELECT name
FROM s_product
WHERE LOWER(name) LIKE '%ski%';

-- Câu 4 - Tính số tháng thâm niên của mỗi nhân viên (làm tròn), sắp tăng dần
SELECT last_name,
ROUND(MONTHS_BETWEEN(SYSDATE, start_date)) AS "So thang thamnien"
FROM s_emp
ORDER BY MONTHS_BETWEEN(SYSDATE, start_date) ASC;
    
-- Câu 5 - Có bao nhiêu người quản lý
SELECT COUNT(DISTINCT manager_id) AS "So nguoi quan ly"
FROM s_emp
WHERE manager_id IS NOT NULL;

-- Câu 6 - Mức cao nhất và thấp nhất của đơn hàng trong s_ord — đặt alias là 'Highest' và 'Lowest'
SELECT MAX(total) AS "Highest",
MIN(total) AS "Lowest"
FROM s_ord;

-- Bài 4
-- Câu 1 - Tên sản phẩm, mã sản phẩm và số lượng trong đơn hàng mã 101 — cột số lượng đặt tên 'ORDERED'
SELECT p.name,
p.id,
i.quantity AS "ORDERED"
FROM s_product p, s_item i
WHERE p.id = i.product_id
AND i.ord_id = 101;

-- Câu 2 - Mã khách hàng và mã đơn đặt hàng của TẤT CẢ khách hàng (kể cả chưa đặt hàng), sắp theo mã KH
SELECT c.id AS "Ma khach hang",
    o.id AS "Ma don hang"
FROM s_customer c, s_ord o
WHERE c.id = o.customer_id(+)
ORDER BY c.id;

-- Câu 3 - Mã khách hàng, mã sản phẩm và số lượng đặt hàng của đơn hàng có trị giá trên 100000
SELECT o.customer_id,
    i.product_id,
    i.quantity
FROM s_ord o, s_item i
WHERE o.id = i.ord_id
AND o.total > 100000;

-- Bài 5
-- Câu 1 - Với từng người quản lý: mã người quản lý và số nhân viên họ quản lý
SELECT manager_id AS "Ma quan ly",
    COUNT(id) AS "So nhan vien"
FROM s_emp
WHERE manager_id IS NOT NULL
GROUP BY manager_id
ORDER BY manager_id;

--  Câu 2 - Người quản lý quản lý từ 20 nhân viên trở lên
SELECT manager_id AS "Ma quan ly",
    COUNT(id) AS "So nhan vien"
FROM s_emp
WHERE manager_id IS NOT NULL
GROUP BY manager_id
HAVING COUNT(id) >= 20;

-- Câu 3 - Mã vùng, tên vùng và số phòng ban trực thuộc trong mỗi vùng
SELECT r.id AS "Ma vung",
    r.name AS "Ten vung",
    COUNT(d.id) AS "So phong ban"
FROM s_region r, s_dept d
WHERE r.id = d.region_id
GROUP BY r.id, r.name
ORDER BY r.id;

-- Câu 4 - Tên khách hàng và số lượng đơn đặt hàng của mỗi khách
SELECT c.name AS "Ten khach hang",
    COUNT(o.id) AS "So don dat hang"
FROM s_customer c, s_ord o
WHERE c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY c.name;

-- Câu 5 - Khách hàng có số đơn đặt hàng nhiều nhất
SELECT c.name, COUNT(o.id) AS "So don hang"
FROM s_customer c, s_ord o
WHERE c.id = o.customer_id
GROUP BY c.id, c.name
HAVING COUNT(o.id) = (
    SELECT MAX(COUNT(id))
    FROM s_ord
    GROUP BY customer_id
);

-- Câu 6 - Khách hàng có tổng tiền mua hàng lớn nhất
SELECT c.name, SUM(o.total) AS "Tong tien"
FROM s_customer c, s_ord o
WHERE c.id = o.customer_id
GROUP BY c.id, c.name
HAVING SUM(o.total) = (
    SELECT MAX(SUM(total))
    FROM s_ord
    GROUP BY customer_id
);

-- Bài 6
-- Câu 1 - Họ, tên và ngày tuyển dụng của nhân viên cùng phòng với 'Lan'
SELECT last_name, first_name, start_date
FROM s_emp
WHERE dept_id = (
    SELECT dept_id
    FROM s_emp
    WHERE first_name = 'Lan'
)
AND first_name != 'Lan';

-- Câu 2 - Mã nhân viên, họ, tên và mã truy cập của nhân viên có lương trên mức lương trung bình
SELECT id, last_name, first_name, userid
FROM s_emp
WHERE salary > (SELECT AVG(salary) FROM s_emp);

-- Câu 3 - Mã, họ, tên của nhân viên có lương trên trung bình VÀ tên chứa ký tự 'L'
SELECT id, last_name, first_name
FROM s_emp
WHERE salary > (SELECT AVG(salary) FROM s_emp)
    AND (UPPER(first_name) LIKE '%L%'
    OR UPPER(last_name) LIKE '%L%');
    
-- Câu 4 - Những khách hàng chưa bao giờ đặt hàng
SELECT name
FROM s_customer
WHERE id NOT IN (
    SELECT DISTINCT customer_id
    FROM s_ord
    WHERE customer_id IS NOT NULL
);

