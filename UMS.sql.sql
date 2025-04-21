create database university_db;
use university_db;
create table students(
student_id int primary key ,
name varchar(50),
age int,
gender varchar(50),
email varchar(50) unique,
phone varchar(100)unique,
department_id int
);
insert into students()
values(1,"travis",20,"male","travis@gmail.com",9878989878,1),
(2,"abi",20,"male","abi@gmail.com",9876543267,2),
(3,"nithish",20,"male","nithish@gmail.com",9878232378,3),
(4,"klassen",20,"male","klassen@gmail.com",9878232378,4),
(5,"ishan",20,"male","ishan@gmail.com",9878232378,5);
create table departments(
department_id int primary key ,
department_name varchar(50),
HOD_id int
);

create table professors(
professor_id int primary key ,
name varchar(50),
email varchar(50) unique,
phone varchar(100) unique,
department_id int
);

create database courses_db;
use courses_db;
create table courses(
course_id int primary key,
course_name varchar(50),
credits varchar(50),
department_id int);

insert into courses()
values(101,"full stack",3,1),(102,"machine learning",4,1),(103,"network security",5,3),
(104,"operating system",4,2),(105," computer networks",4,2);
create table enrollment(
enrollment_id int primary key,
student_id int,
course_id int,
semester int,
grade varchar(50));
insert into enrollment()
values(1,1,101,1,"A"),(2,2,102,1,"B"),(3,3,103,1,"A"),(4,4,104,1,"A"),(5,5,105,1,"A");

create table teaching(
teaching_id int primary key,
professor_id int,
course_id int,
semester int );

insert into teaching()
values(1,1,101,1),(2,2,102,1),(3,3,103,1),(4,4,104,1),(5,5,105,1);

create database finance_db;
use finance_db;

create table fees(
fee_id int primary key,
student_id int,
amount varchar(100),
due_date date,
status varchar(50) default 'pending' );

insert into fees(fee_id,student_id,amount,due_date)
values(1001,1,6000,"2025-01-20"),(1002,2,4999,"2024-12-30"),(1003,3,7888,"2024-09-14"),(1004,4,8000,"2024-12-12"),
(1005,5,8000,"2025-02-02");
create table salaries(
salary_id int primary key,
professor_id int,
amount varchar(50),
pay_date date );

insert into salaries()
values(1,1,15000,"2024-01-15"),(2,2,15000,"2024-02-15"),
(3,3,13000,"2024-04-15"),(4,4,14000,"2024-05-15"),(5,5,15000,"2024-03-04");

create table scholarship(
scholarship_id int primary key,
student_id int,
amount varchar(50),
type varchar(50),
eligibility_criteria varchar(50));

insert into scholarship()
values(101,1,8000,"commmunity scholarship", "depends upon community"),
(102,2,8000,"sports scholarship","national sports recors"),
(103,3,8000,"commmunity scholarship", "depends upon community"),
(104,4,8000,"need based scholarship", "family income below 10000"),
(105,5,10000,"merit scholarship","GPA above 4");


#1-------retrive name of students enrolled in specific course

select name from university_db.students join courses_db.courses
on university_db.students.department_id = courses_db.courses.department_id
where course_name = "full stack" and course_id in ( select course_id from courses_db.enrollment);


#2------find total number of student in each department

select count(student_id) as total_student,department_id
from university_db.students 
group by department_id;

#3---- professors teaching more than one courses

select university_db.professors.name,courses_db.teaching.professor_id, count(course_id) as teaches_more_than_one_course  
from courses_db.teaching join university_db.professors on
university_db.professors.professor_id = courses_db.teaching.professor_id
group by professor_id ,semester
having count(course_id)>1;

#4-----------students  who unpaid fees

select university_db.students.name from university_db.students join finance_db.fees
on university_db.students.student_id = finance_db.fees.student_id
where finance_db.fees.status="pending";

#5---------------show the student who receive scholarship >5000

select university_db.students.name from university_db.students join finance_db.scholarship
on university_db.students.student_id = finance_db.scholarship.student_id
where finance_db.scholarship.amount>5000;

#6---------- show the students who has GPA>3.5

select university_db.students.name from university_db.students
where GPA>3.5;

#7 ---- find professor earn more than 5000 salary

select name from university_db.professors join
finance_db.salaries on university_db.professors.professor_id=finance_db.salaries.professor_id
where finance_db.salaries.amount >5000;

#8--------- get list of course taught by specific professor

select courses_db.courses.course_name,university_db.professors.name from courses_db.courses
join courses_db.teaching on courses.course_id = teaching.course_id
join university_db.professors on courses_db.teaching.professor_id = university_db.professors.professor_id;

#9----------- departments with most students

select university_db.departments.department_id, department_name,count(student_id) as total_students
from university_db.students join university_db.departments on 
university_db.students.department_id=university_db.departments.department_id
group by department_id 
order by  total_students desc
limit 1 ;

#10-----------retrive students who have not enrolled in any courses

select students.student_id,name from university_db.students
 left join courses_db.enrollment on
university_db.students.student_id = courses_db.enrollment.student_id
where courses_db.enrollment.student_id is null;

#11------------ get total revenue from student fee per semester

select semester, sum(amount) as total_revenue from finance_db.fees,courses_db.enrollment
group by semester ;

#12-------------- find students who taken more than 5 course in a semester

select name,semester,count(course_id) as TOTAL_COURSE
from courses_db.enrollment join university_db.students on
courses_db.enrollment.student_id= university_db.students.student_id
group by name,semester
having count(course_id)>1;

#13--------------------- identify professor who are also HOD

select professors.professor_id,name from professors
join departments on professors.professor_id =departments.HOD_id;

#14----------show number of students per course in desc order
select courses.course_name, courses.course_id, count(student_id) as no_of_students
from courses_db.courses join courses_db.enrollment on
courses_db.courses.course_id = courses_db.enrollment.course_id
group by courses.course_id
order by no_of_students desc;

#15-------------- find who have failed a couse (grade<"C")

select courses_db.enrollment.student_id, course_id,university_db.students.name from courses_db.enrollment
join university_db.students on courses_db.enrollment.student_id=university_db.students.student_id
where grade="C";

#16------retrive student who fees are overdue

select finance_db.fees.student_id,name from finance_db.fees join university_db.students
on finance_db.fees.student_id= university_db.students.student_id
where due_date < current_date();

#17----find department with highest number of course

select university_db.students.department_id,university_db.departments.department_name,
count(course_id) as total_course
from university_db.students join courses_db.enrollment on
students.department_id=enrollment.enrollment_id
join university_db.departments on departments.department_id = students.department_id
group by  department_id;

#18------show the student who has same name
select * from students where name in(select name from students
group by name
having count(*)>1);

#19-----average salary of professor in each department

select professors.professor_id,university_db.departments.department_id,university_db.departments.department_name,avg(amount)
from university_db.departments join professors on
departments.department_id=professors.professor_id
join finance_db.salaries on salaries.salary_id=professors.professor_id
group by department_id;

#20------- retrive student who enrolled in at least one course in every semester

select distinct university_db.students.student_id,university_db.students.name from university_db.students
join courses_db.enrollment on university_db.students.student_id=courses_db.enrollment.student_id;

