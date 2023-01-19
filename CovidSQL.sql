SELECT *
FROM Covid_Deaths
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM Covid_Vaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..Covid_deaths
ORDER BY 1,2 


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Portfolio_Project..Covid_deaths
WHERE location LIKE '%states%'
ORDER BY 1,2 

--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, Population, total_cases,  (total_cases/population)*100 AS Percent_of_Population_Infected
FROM Portfolio_Project..Covid_deaths
WHERE location = 'United States'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population

SELECT location, Population, MAX(total_cases) AS Highest_Infection_Count,  MAX((total_cases/population))*100 AS Percent_of_Population_Infected
FROM Portfolio_Project..Covid_deaths
GROUP BY location , Population
ORDER BY  Percent_of_Population_Infected DESC

--Looking at countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS Total_Death_Count 
FROM Portfolio_Project..Covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death_Count DESC



-- LET'S BREAK THINGS DOWN BY continent

SELECT continent, MAX(cast(total_deaths as int)) AS Total_Death_Count 
FROM Portfolio_Project..Covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC


--Global Numbers

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not null
ORDER BY 1,2 


--Total population vs Vaccinations

--CTE

WITH Pop_VS_Vac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Total_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, 
dea.date) as Rolling_Total_Vaccinated
FROM Covid_Deaths dea
JOIN Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order By 2,3
)
SELECT *, (Rolling_Total_Vaccinated/Population)*100 as Rolling_Percent_Vaccinated
FROM Pop_VS_Vac

--TEMP TABLE

DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacccinations numeric,
Rolling_Total_Vaccinated numeric
)

INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, 
dea.date) as Rolling_Total_Vaccinated
FROM Covid_Deaths dea
JOIN Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
Order By 2,3

SELECT *, (Rolling_Total_Vaccinated/Population)*100 as Rolling_Percent_Vaccinated
FROM #Percent_Population_Vaccinated


--Creating View to store data for later visualizations


CREATE VIEW Percent_Population_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, 
dea.date) as Rolling_Total_Vaccinated
FROM Covid_Deaths dea
JOIN Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT *
FROM Percent_Population_Vaccinated