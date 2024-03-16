--Human Resource data
select top 5 *
from dbo.[Human Resources]

--changing the data type and format of birthdate column
update dbo.[Human Resources]
set birthdate = case 
when birthdate like '%-%' then convert(date,try_cast(birthdate as date),103)
when birthdate like '%/%' then convert(date,try_cast(birthdate as date),103)
else null
end

--changing the data type and format of hiredate column
update dbo.[Human Resources]
set hire_date = case 
when hire_date like '%-%' then convert(date,try_cast(hire_date as date),103)
when hire_date like '%/%' then convert(date,try_cast(hire_date as date),103)
else null
end

-- addition of a calculated column named age ( Age of the employees ) 
alter table dbo.[Human Resources] add age int 
update dbo.[Human Resources]
set age = 2024-year(birthdate)

--checking whether we have employees less than 18 years of age 
select *
from dbo.[Human Resources]
where age<18
--we have none

--## Questions
--1. What is the gender breakdown of employees in the company?
select gender,count(*) as no_of_people
from dbo.[Human Resources]
group by gender

--2. What is the race/ethnicity breakdown of employees in the company?
select race,count(*) as no_of_people
from dbo.[Human Resources]
group by race

--3. What is the age distribution of employees in the company?
select (case 
when age>=18 and age<=25 then '18-25'
when age>25 and age<=35 then '26-35'
when age>35 and age<=45 then '36-45'
when age>45 and age<=55 then '45-55'
when age>55 and age<=60 then '55-60'
else '60+'
end) as age_group,count(*) as number_of_people
from dbo.[Human Resources]
group by (case 
when age>=18 and age<=25 then '18-25'
when age>25 and age<=35 then '26-35'
when age>35 and age<=45 then '36-45'
when age>45 and age<=55 then '45-55'
when age>55 and age<=60 then '55-60'
else '60+'
end)
order by age_group

--4. How many employees work at headquarters versus remote locations?
select location,count(*) as number_of_people
from dbo.[Human Resources]
group by location

--5. What is the average length of employment for employees who have been terminated?
select avg(DATEDIFF(year,hire_date,try_cast(SUBSTRING(termdate,1,19) as datetime))) as average_length_of_employment_in_years
from dbo.[Human Resources]
where termdate is not null

--6. How does the gender distribution vary across departments and job titles?
select department,jobtitle,gender,count(gender) no_of_people
from dbo.[Human Resources]
group by department,jobtitle,gender

--7. What is the distribution of job titles across the company?
select jobtitle,count(*) as number_of_employees
from dbo.[Human Resources]
group by jobtitle

--8. What is the distribution of employees across locations by state?
select location_state,count(*) as number_of_employees
from dbo.[Human Resources]
group by location_state

--9. How has the company's employee count changed over time based on hire and term dates?
select *,sum(number_of_hires_per_year-terminations_per_year) over (order by sno rows between unbounded preceding and current row )as net_change_in_number_of_employees
from
(select ROW_NUMBER() over (order by year_of_hiring) as Sno, *
from
(select year(hire_date) as year_of_hiring,
count(*) as number_of_hires_per_year,
SUM(CASE WHEN termdate is not null AND datediff(day,try_cast(substring(termdate,1,11)as date), getdate()) <=0 then 1 else 0 end) as terminations_per_year
from dbo.[Human Resources]
group by year(hire_date)) as t1) as t2
order by year_of_hiring

--10. What is the tenure distribution for each department?
select department, avg(DATEDIFF(year,hire_date,try_cast(SUBSTRING(termdate,1,19) as datetime))) as avg_tenure
from dbo.[Human Resources]
where termdate is not null
group by department



