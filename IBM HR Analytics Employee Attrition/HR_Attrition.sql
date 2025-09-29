CREATE TABLE HR_Employee (
    EmployeeID SERIAL PRIMARY KEY,
    Age INT,
    Attrition VARCHAR(3),
    BusinessTravel VARCHAR(50),
    Department VARCHAR(50),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(50),
    EnvironmentSatisfaction INT,
    Gender VARCHAR(10),
    JobInvolvement INT,
    JobLevel INT,
    JobRole VARCHAR(50),
    JobSatisfaction INT,
    MaritalStatus VARCHAR(20),
    MonthlyIncome NUMERIC,
    NumCompaniesWorked INT,
    OverTime VARCHAR(3),
    PercentSalaryHike NUMERIC,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT,
    AgeGroup VARCHAR(10)
);



COPY HR_Employee(Age, Attrition, BusinessTravel, Department, DistanceFromHome, Education, 
EducationField, EnvironmentSatisfaction, Gender, JobInvolvement, JobLevel, JobRole, 
JobSatisfaction, MaritalStatus, MonthlyIncome, NumCompaniesWorked, OverTime, 
PercentSalaryHike, PerformanceRating, RelationshipSatisfaction, StockOptionLevel, 
TotalWorkingYears, TrainingTimesLastYear, WorkLifeBalance, YearsAtCompany, YearsInCurrentRole, 
YearsSinceLastPromotion, YearsWithCurrManager, AgeGroup)
FROM 'C:\IBM HR Analytics Employee Attrition\attrition_by_role.csv'
DELIMITER ','
CSV HEADER;




select * from hr_employee;


-- Overall Attrition

select 
	   Round(sum(case when Attrition= 'Yes' then 1 ELSE 0 end ) * 100.0 / count(*), 2) as Attriction_Percentage
from hr_employee;



-- Attrition by Department

SELECT department,
count(*) as total_department,
sum(case when Attrition= 'Yes' then 1 ELSE 0 end ) as employee_left,
Round(sum(case when Attrition= 'Yes' then 1 ELSE 0 end ) * 100.0 / count(*), 2) as Attriction_Percentage
from hr_employee
group by department
order by Attriction_Percentage desc ;




-- Attrition by Job Role & Avg Salary

select jobRole,
round(avg(MonthlyIncome), 0 ) as avg_salary,
count(*) as total_employee,
sum(case when Attrition = 'Yes' then 1 else 0 end) as employee_left,
round(sum(case when Attrition = 'Yes' then 1 else 0 end) * 100.0 / count(*),2) as Attriction_Percentage
from hr_employee
GROUP by jobRole
order by Attriction_Percentage desc ;



SELECT overtime,
       JobSatisfaction,
count(*) as total_employee,
sum(case when Attrition = 'Yes' then 1 else 0 end) as employee_left,
round(sum(case when Attrition = 'Yes' then 1 else 0 end) * 100.0 / count(*),2) as Attriction_Percentage
from hr_employee
GROUP by overtime,JobSatisfaction
order by Attriction_Percentage desc ;



SELECT AgeGroup,
       COUNT(*) AS Total_Employees,
       SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS Employees_Left,
       ROUND(SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Percentage
FROM HR_Employee
GROUP BY AgeGroup
ORDER BY AgeGroup;




SELECT Gender,
       COUNT(*) AS Total_Employees,
       SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS Employees_Left,
       ROUND(SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Percentage
FROM HR_Employee
GROUP BY Gender;



SELECT YearsAtCompany,
       COUNT(*) AS Total_Employees,
       SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS Employees_Left,
       ROUND(SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Percentage
FROM HR_Employee
GROUP BY YearsAtCompany
ORDER BY YearsAtCompany;


SELECT CASE 
           WHEN MonthlyIncome < 3000 THEN '<3000'
           WHEN MonthlyIncome BETWEEN 3000 AND 5000 THEN '3000-5000'
           WHEN MonthlyIncome BETWEEN 5001 AND 7000 THEN '5001-7000'
           ELSE '>7000'
       END AS SalaryBand,
       COUNT(*) AS Total_Employees,
       SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS Employees_Left,
       ROUND(SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Percentage
FROM HR_Employee
GROUP BY SalaryBand
ORDER BY SalaryBand;




