-- BUILDING A SCHEMA OF EMPLOYEE AS IN ERD --

-- CREATE TABLE Employee (
-- emp_id INT PRIMARY KEY,
-- First_Name VARCHAR(40),
-- Last_Name VARCHAR(40),
-- Birth_Date DATE,
-- Sex VARCHAR(1),
-- Salary INT,
-- super_id INT,
-- branch_id INT)

-- CREATE TABLE Branch (
-- branch_id INT PRIMARY KEY,
-- Branch_Name varchar(40),
-- mgr_id iNT,
-- mgr_start_date DATE,
-- FOREIGN KEY(mgr_id) REFERENCES Employee(emp_id) ON DELETE SET NULL
-- )

-- ALTER TABLE Employee
-- ADD FOREIGN KEY(branch_id) REFERENCES Branch(branch_id) ON DELETE SET NULL;

-- ALTER TABLE Employee
-- ADD FOREIGN KEY(super_id) REFERENCES Employee(emp_id) ON DELETE SET NULL;

-- CREATE TABLE Client (
-- client_id INT PRIMARY KEY,
-- Client_Name VARCHAR(40),
-- branch_id INT,
-- FOREIGN KEY(branch_id) REFERENCES Branch(branch_id) ON DELETE SET NULL
-- )

-- CREATE TABLE Work_With (
-- emp_id INT,
-- client_id INT,
-- total_sales INT,
-- PRIMARY KEY(emp_id,client_id),
-- FOREIGN KEY(EMP_ID) REFERENCES Employee(emp_id),
-- FOREIGN KEY(Client_id) REFERENCES Client(client_id))

-- CREATE TABLE Branch_Supplier (
-- branch_id INT,
-- Supplier_Name VARCHAR(40),
-- Supply_Type Varchar(40),
--  PRIMARY KEY(branch_id, Supplier_Name),
-- FOREIGN KEY(branch_id) REFERENCES Branch(branch_id)
-- );

-- CORPORATE BRANCH
-- INSERT INTO Employee values(100,'David','Wallace','1967-11-17','M',250000,NULL,NUll);
-- Insert INTO Branch VALUES(1, 'Corporate',100,'2006-02-09');

-- UPDATE Employee
-- SET branch_id = 1 WHERE emp_id = 100;

-- INSERT INTO Employee values(101,'Jan','Levinson','1961-05-11','F',110000,100,1);

-- SCRANTON BRANCH
-- INSERT INTO Employee VALUES(102,'Micheal','Scott','1964-03-15', 'M', 75000, 100, NULL);
-- INSERT INTO Branch VALUES(2,'SCRANTON', 102, '1992-04-06');

-- UPDATE Employee
-- SET branch_id = 2 where emp_id = 102;

-- INSERT INTO Employee VALUES(103,'Angela','Martin','1971-06-25','F', 63000, 102, 2);
-- INSERT INTO Employee VALUES(104,'Kelly','Kapoor','1980-02-05','F',55000,102,2 );
-- INSERT INTO Employee VALUES(105,'Stanley','Hudson','1958-02-05','M',50000,102,2);

-- STAMFORD BRANCH
-- INSERT INTO Employee VALUES(106,'Josh','Porter','1969-09-05','M',78000,100,NULL);
-- INSERT INTO Branch VALUES(3,'Stamford',106,'1908-02-13');
-- UPDATE EMPLOYEE
-- SET branch_id = 3 WHERE emp_id = 106;

-- INSERT INTO Employee VALUES(107,'Andy','Bernard','1973-07-22','M',65000,106,3);
-- INSERT INTO Employee VALUES(108,'Jim','Halpert','1978-10-01','M',71000,106,3);

-- INSERT VALUES IN CLIENT TABLE --
-- INSERT INTO Client VALUES(400,'Dunmore Highschool',2);
-- INSERT INTO Client VALUES(401,'Lackawana Country',2);
-- INSERT INTO Client VALUES(402,'Fedx',3);
-- INSERT INTO Client VALUES(403,'John Daly Law, LLC',3);
-- INSERT INTO Client VALUES(404,'Scranton Whitepages',2);
-- INSERT INTO Client VALUES(405,'Times Newspaper',3);
-- INSERT INTO Client VALUES(406,'Fedx',2);

-- INSERT VALUES IN BRANCH SUPPLIER -- 
-- INSERT INTO Branch_Supplier VALUES(2,'Hammer Mill','Paper');
-- INSERT INTO Branch_Supplier VALUES(2,'Uni-ball','Writing Utensils');
-- INSERT INTO Branch_Supplier VALUES(3,'Patriot Paper','Paper');
-- INSERT INTO Branch_Supplier VALUES(2,'J.T. Forms Lables','Custom Forms');
-- INSERT INTO Branch_Supplier VALUES(3,'Hammer Mill','Paper');
-- INSERT INTO Branch_Supplier VALUES(3,'Uni-ball','Writing Utensils');
-- INSERT INTO Branch_Supplier VALUES(3,'Stamford Labels','Custom Forms');

-- INSERT VALUES INTO WORKS WITH TABLE --
-- INSERT INTO Works_with VALUES(105,400,55000);
-- INSERT INTO Works_with VALUES(102,401,267000);
-- INSERT INTO Works_with VALUES(108,402,22500);
-- INSERT INTO Works_with VALUES(107,403,5000);
-- INSERT INTO Works_with VALUES(108,403,12000);
-- INSERT INTO Works_with VALUES(105,404,33000);
-- INSERT INTO Works_with VALUES(107,405,26000);
-- INSERT INTO Works_with VALUES(102,406,15000);
-- INSERT INTO Works_with VALUES(105,406,13000);

-- LETS DO SOME QUERIES TO PLAY WITH DATA --

-- AVG SALARY OF EMPLOYEES IN EACH BRANCH --
SELECT Branch_Name,
e.Branch_id, ROUND(AVG(SALARY),0) avg_salary
FROM Employee e JOIN Branch b
ON e.branch_id = b.branch_id
GROUP BY e.Branch_id;

-- Name of the employee who has worked with the most clients in each branch AND their salary WITH AVG SALARY OF BRANCH--
WITH CTE AS (SELECT CONCAT_WS(' ',e.First_name,e.Last_name) Name,
Branch_Name,COUNT(Client_id) NC, Salary,
ROUND(AVG(Salary) OVER(PARTITION BY branch_name),0) Avg_Salary_Branch
FROM employee e LEFT JOIN Works_With w
ON e.emp_id = w.emp_id LEFT JOIN Branch b
ON e.branch_id = b.branch_id 
WHERE e.branch_id <> 1
GROUP BY CONCAT_WS(' ',e.First_name,e.Last_name),Branch_Name,Salary
ORDER BY NC DESC, SALARY DESC)

SELECT * FROM CTE t1
WHERE NC = (SELECT MAX(NC) FROM CTE t2 WHERE t1.branch_name = t2.branch_name);


-- Full Name, branch, salary of the employee who has generated the most sales in each branch -- 

WITH CTE AS (SELECT CONCAT_WS(' ',e.First_name,e.Last_name) Name,
b.Branch_name,e.salary,
ROUND(MAX(Salary) OVER(PARTITION BY branch_name),0) Max_Salary_Branch,
SUM(w.total_sales) TotalSales,
MAX(SUM(w.total_sales)) OVER(PARTITION BY b.branch_name) sm
FROM Employee e 
LEFT JOIN Works_with w ON e.emp_id = w.emp_id
LEFT JOIN CLIENT c ON c.client_id = w.client_id
LEFT JOIN BRANCH b ON e.branch_id = b.branch_id
GROUP BY Name, b.Branch_name, e.salary
ORDER BY TotalSales DESC)

SELECT Name, Branch_Name, TotalSales, salary, Max_Salary_Branch FROM CTE t1
WHERE TotalSales = sm;

-- 




