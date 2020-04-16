CREATE DATABASE students;

-- Data Insert

drop table if exists student;
create table student (
  sno integer,
	sname varchar(10),
	age integer
);
​
drop table if exists courses;
create table courses (
	cno varchar(5),
	title varchar(10),
	credits integer
);
​
drop table if exists professor;
create table professor (
	lname varchar(10),
	dept varchar(10),
	salary integer,
	age integer
);
​
drop table if exists take;
create table take (
	sno integer,
	cno varchar(5)
);
​
drop table if exists teach;
create table teach (
	lname varchar(10),
	cno varchar(5)
);
​
insert into student values (1, 'AARON', 20);
insert into student values (2, 'CHUCK', 21);
insert into student values (3, 'DOUG', 20);
insert into student values (4, 'MAGGIE', 19);
insert into student values (5, 'STEVE', 22);
insert into student values (6, 'JING', 18);
insert into student values (7, 'BRIAN', 21);
insert into student values (8, 'KAY', 20);
insert into student values (9, 'GILLIAN', 20);
insert into student values (10, 'CHAD', 21);
​
insert into courses values ('CS112', 'PHYSICS', 4);
insert into courses values ('CS113', 'CALCULUS', 4);
insert into courses values ('CS114', 'HISTORY', 4);
​
insert into professor values ('CHOI', 'SCIENCE', 400, 45);
insert into professor values ('GUNN', 'HISTORY', 300, 60);
insert into professor values ('MAYER', 'MATH', 400, 55);
insert into professor values ('POMEL', 'SCIENCE', 500, 65);
insert into professor values ('FEUER', 'MATH', 400, 40);
​
insert into take values (1, 'CS112');
insert into take values (1, 'CS113');
insert into take values (1, 'CS114');
insert into take values (2, 'CS112');
insert into take values (3, 'CS112');
insert into take values (3, 'CS114');
insert into take values (4, 'CS112');
insert into take values (4, 'CS113');
insert into take values (5, 'CS113');
insert into take values (6, 'CS113');
insert into take values (6, 'CS114');
​
insert into teach values ('CHOI', 'CS112');
insert into teach values ('CHOI', 'CS112');
insert into teach values ('CHOI', 'CS112');
insert into teach values ('POMEL', 'CS113');
insert into teach values ('MAYER', 'CS112');
insert into teach values ('MAYER', 'CS114');

-- Confirm data all in

/*
\dt
           List of relations
 Schema |   Name    | Type  |  Owner
--------+-----------+-------+----------
 public | courses   | table | postgres
 public | professor | table | postgres
 public | student   | table | postgres
 public | take      | table | postgres
 public | teach     | table | postgres
(5 rows)

                      Table "public.courses"
 Column  |         Type          | Collation | Nullable | Default
---------+-----------------------+-----------+----------+---------
 cno     | character varying(5)  |           |          |
 title   | character varying(10) |           |          |
 credits | integer               |           |          |

                    Table "public.professor"
 Column |         Type          | Collation | Nullable | Default
--------+-----------------------+-----------+----------+---------
 lname  | character varying(10) |           |          |
 dept   | character varying(10) |           |          |
 salary | integer               |           |          |
 age    | integer

                      Table "public.student"
 Column |         Type          | Collation | Nullable | Default
--------+-----------------------+-----------+----------+---------
 sno    | integer               |           |          |
 sname  | character varying(10) |           |          |
 age    | integer               |           |          |

                      Table "public.take"
 Column |         Type         | Collation | Nullable | Default
--------+----------------------+-----------+----------+---------
 sno    | integer              |           |          |
 cno    | character varying(5) |           |          |


students=# \d teach
                      Table "public.teach"
 Column |         Type          | Collation | Nullable | Default
--------+-----------------------+-----------+----------+---------
 lname  | character varying(10) |           |          |
 cno    | character varying(5)  |           |          |

*/

-- Q1: Find all student names and student numbers for students who do not take CS112.

SELECT DISTINCT sname AS student_name, sno AS student_number
FROM student
WHERE sno NOT IN (SELECT sno FROM take WHERE cNO = 'CS112');

/* 

 student_name | student_number
--------------+----------------
 KAY          |              8
 STEVE        |              5
 CHAD         |             10
 JING         |              6
 BRIAN        |              7
 GILLIAN      |              9
(6 rows)

*/

-- Q2: Find all student numbers for students who take a course other than CS112

WITH students_1_course AS (
SELECT sno, COUNT(cno) as course_count
FROM student INNER JOIN take USING(sno)
GROUP BY sno
HAVING count(cno) = 1
),
students_1_course_and_CS112 AS (
SELECT sno FROM take WHERE cno = 'CS112' AND sno IN (SELECT sno FROM students_1_course) 
)
SELECT DISTINCT sno
FROM take
WHERE sno NOT IN (SELECT sno FROM students_1_course_and_CS112);

/*
 sno
-----
   3
   5
   4
   6
   1
(5 rows)
*/

-- Q3: Which students take at least three courses?

SELECT sno, COUNT(cno) as course_count
FROM student INNER JOIN take USING(sno)
GROUP BY sno
HAVING count(cno) >=3;

/*
 sno | course_count
-----+--------------
(0 rows)
*/


-- Q4: Find students who take CS112 or CS114 but not both.

WITH students_CS112_or_CS114 AS(
SELECT DISTINCT sno 
FROM take
WHERE cno = 'CS112'
UNION 
SELECT DISTINCT sno 
FROM take
WHERE cno = 'CS114'
), 
students_CS112_and_CS114 AS (
select sno 
FROM take
WHERE sno IN (select sno FROM take WHERE cno='CS112') AND sno IN (select sno FROM take WHERE cno='CS114')
)
SELECT sno 
FROM students_CS112_or_CS114 
WHERE sno NOT IN (SELECT sno FROM students_CS112_and_CS114);

/*
 sno
-----
   1
   4
   2
   6
(4 rows)
*/

-- Q5: Find the students who take exactly 2 courses

SELECT sno, COUNT(cno) as course_count
FROM student INNER JOIN take USING(sno)
GROUP BY sno
HAVING count(cno) =2;

/*
 sno | course_count
-----+--------------
   3 |            2
   4 |            2
   6 |            2
(3 rows)
*/

-- Q6: Find the students who take at most 2 courses.

SELECT sno, COUNT(cno) as course_count
FROM student INNER JOIN take USING(sno)
GROUP BY sno
HAVING count(cno) <=2;

/*
 sno | course_count
-----+--------------
   2 |            1
   3 |            2
   4 |            2
   5 |            1
   6 |            2
(5 rows)
*/

-- Q7: Find the students who take only CS112 and nothing else.

WITH students_1_course AS (
SELECT sno, COUNT(cno) as course_count
FROM student INNER JOIN take USING(sno)
GROUP BY sno
HAVING count(cno) = 1
)
SELECT sno FROM take WHERE cno = 'CS112' AND sno IN (SELECT sno FROM students_1_course);

/*
 sno
-----
   2
(1 row)
*/

-- Q8: Q8: Find the youngest students WITHOUT using MIN() or MAX().

SELECT *
FROM student
ORDER BY age ASC
LIMIT 1;

/*
 sno | sname | age
-----+-------+-----
   6 | JING  |  18
(1 row)
*/

