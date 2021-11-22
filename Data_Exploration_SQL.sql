--Looking at Data
SELECT
	*
FROM
	Covid_Project_v02.dbo.Covid_Deaths
WHERE
	continent is not NULL 
ORDER BY
	location

SELECT
	*
FROM
	Covid_Project_v02.dbo.Covid_Vaccination
WHERE
	continent is not NULL 
ORDER BY
	location

SELECT
	continent, location, date, population, total_cases, total_deaths
FROM
	Covid_Project_v02.dbo.Covid_Deaths
WHERE
	continent is not NULL 
ORDER BY
	location

--Total Cases vs Total deaths i.e. likelihood of dying if contracted covid
SELECT 
	continent, location, date, population, total_cases, total_deaths, ((total_deaths/total_cases)*100) as Death_Percentage
FROM
	Covid_Project_v02.dbo.Covid_Deaths
WHERE 
	location like '%united%'
	AND continent is not NULL 
ORDER BY
	location

--Total cases vs population i.e. likelihood of contracting covid

SELECT
	continent, location, date, population, total_cases, total_deaths, ((total_cases/population)*100) as Percent_Infected,
	((total_deaths/total_cases)*100) as Death_Percentage
FROM
	Covid_Project_v02.dbo.Covid_Deaths
WHERE
	continent is not NULL 
ORDER BY
	location

--Countries with highest infection rate

SELECT
	continent, location, population, Max(total_cases)as Highest_cases,MAX((total_cases/population)*100) as Percent_Infected
	
FROM
	Covid_Project_v02.dbo.Covid_Deaths
WHERE
	continent is not NULL 
GROUP BY
	continent, location, population
ORDER BY
	Highest_cases DESC,
	Percent_Infected DESC

--Countries with highest death count

SELECT
	location, MAX(CAST(total_deaths as int))as total_death_count
FROM	
	Covid_Project_v02.dbo.Covid_Deaths
WHERE
	continent is not NULL 
GROUP BY
	location
ORDER BY
	total_death_count DESC

--Continents with highest death count

SELECT
	location, MAX(CAST(total_deaths as int)) as Total_death_count
FROM
	Covid_Project_v02.dbo.Covid_Deaths
WHERE
	continent is NULL 
GROUP BY
	location
ORDER BY
	Total_death_count DESC	

--continent Numbers

SELECT
	location, MAX(CAST(total_deaths as int)) as Total_death_count, Max(total_cases)as Highest_cases,MAX((total_cases/population)*100) as Percent_Infected
FROM
	Covid_Project_v02.dbo.Covid_Deaths
WHERE
	continent is null
GROUP BY
	location
ORDER BY
	location


--Global numbers by date
SELECT
	CAST(date AS date) as Final_date, MAX(CAST(total_deaths as int)) as Total_death_count, Max(total_cases)as Highest_cases,MAX((total_cases/population)*100) as Percent_Infected
FROM
	Covid_Project_v02.dbo.Covid_Deaths
WHERE
	continent is null
GROUP BY
	date
ORDER BY
	date



SELECT
	CAST(date as date) as Final_date, SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, ((SUM(CAST(new_deaths as int))/SUM(new_cases))*100) as DeathPercentage
FROM
	Covid_Project_v02.dbo.Covid_Deaths
WHERE
	continent is not null
GROUP BY
	date
ORDER BY
	date
--Total Cases Globally
SELECT
	SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, ((SUM(CAST(new_deaths as int))/SUM(new_cases))*100) as DeathPercentage
FROM
	Covid_Project_v02.dbo.Covid_Deaths
WHERE
	continent is not null


--Vaccinations
SELECT
	*
FROM
	Covid_Project_v02.dbo.Covid_Vaccination

--Join Covid Deaths Table & Covid Vaccination Table

SELECT *
FROM 
	Covid_Project_v02.dbo.Covid_Deaths dea
JOIN
	Covid_Project_v02.dbo.Covid_Vaccination vac
	ON
		dea.location = vac.location
	AND
		dea.date = vac.date

--Total Population vs Vaccination	
SELECT
	dea.continent, dea.location,dea.date, (( vac.total_vaccinations/dea.population)*100) as VaccinationRate
FROM 
	Covid_Project_v02.dbo.Covid_Deaths dea
JOIN
	Covid_Project_v02.dbo.Covid_Vaccination vac
	ON
		dea.location = vac.location
	AND
		dea.date = vac.date
WHERE
	vac.total_vaccinations is not NULL
	AND dea.continent is not NULL
ORDER BY
	dea.location, dea.date

--Rolling count of vaccination for every location

SELECT
	dea.continent, dea.location,dea.date, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Vaccination_Count
FROM 
	Covid_Project_v02.dbo.Covid_Deaths dea
JOIN
	Covid_Project_v02.dbo.Covid_Vaccination vac
	ON
		dea.location = vac.location
	AND
		dea.date = vac.date
WHERE
	 dea.continent is not NULL
GROUP BY
	dea.continent, dea.location,dea.date, vac.new_vaccinations
ORDER BY
	dea.location, dea.date

--Using CTE

WITH PopVsVac (Continent, location, date, population, new_vaccination, Vaccination_Count)
as
(
SELECT
	dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) as Vaccination_Count
FROM 
	Covid_Project_v02.dbo.Covid_Deaths dea
JOIN
	Covid_Project_v02.dbo.Covid_Vaccination vac
	ON
		dea.location = vac.location
	AND
		dea.date = vac.date
WHERE
	 dea.continent is not NULL
GROUP BY
	dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
--ORDER BY
	--dea.location, dea.date
)
SELECT *
FROM PopVsVac

--Percent of Population Vaccinated

WITH PopVsVac (Continent, location, date, population, new_vaccination, Vaccination_Count)
as
(
SELECT
	dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) as Vaccination_Count
FROM 
	Covid_Project_v02.dbo.Covid_Deaths dea
JOIN
	Covid_Project_v02.dbo.Covid_Vaccination vac
	ON
		dea.location = vac.location
	AND
		dea.date = vac.date
WHERE
	 dea.continent is not NULL
GROUP BY
	dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
--ORDER BY
	--dea.location, dea.date
)
SELECT *, (Vaccination_Count/population)*100 as Percent_people_vaccinated
FROM PopVsVac

--Using TEMP table

DROP TABLE IF EXISTS Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, Vaccination_Count numeric)

INSERT INTO #Percent_Population_Vaccinated

SELECT
	dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) as Vaccination_Count
FROM 
	Covid_Project_v02.dbo.Covid_Deaths dea
JOIN
	Covid_Project_v02.dbo.Covid_Vaccination vac
	ON
		dea.location = vac.location
	AND
		dea.date = vac.date
WHERE
	 dea.continent is not NULL
GROUP BY
	dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
--ORDER BY
	--dea.location, dea.date

SELECT * --(Vaccination_Count/population)*100 as Percent_people_vaccinated
FROM Percent_Population_Vaccinated

--creating view
CREATE VIEW Percent_Population_Vaccinated AS
SELECT
	dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) as Vaccination_Count
FROM 
	Covid_Project_v02.dbo.Covid_Deaths dea
JOIN
	Covid_Project_v02.dbo.Covid_Vaccination vac
	ON
		dea.location = vac.location
	AND
		dea.date = vac.date
WHERE
	 dea.continent is not NULL

--ORDER BY
--	dea.location, dea.date
