SELECT * FROM
MyCovidProject..CovidDeaths$
ORDER BY 3,4

--SELECT * FROM
--MyCovidProject..CovidVaccinations$

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM MyCovidProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in Ghana

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM MyCovidProject..CovidDeaths$
WHERE Location='Ghana'
AND Continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid in Ghana

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM MyCovidProject..CovidDeaths$
WHERE Location='Ghana'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate Compared to Population

SELECT Location, population, MAX (total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM MyCovidProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY Location, PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM MyCovidProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT Continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM MyCovidProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC


-- Showing continents with the highest death count per population

 SELECT Continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM MyCovidProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC



--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM MyCovidProject..CovidDeaths$
--Where location ='Ghana'
WHERE Continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population Vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100 
FROM MyCovidProject..CovidDeaths$ dea
JOIN MyCovidProject..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE

With PopsvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS  
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100 
FROM MyCovidProject..CovidDeaths$ dea
JOIN MyCovidProject..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopsvsVac



--TEMP TABLE

DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR (255),
location NVARCHAR (255) , 
date DATETIME, 
population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100 
FROM MyCovidProject..CovidDeaths$ dea
JOIN MyCovidProject..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


--Creating Views to store for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100 
FROM MyCovidProject..CovidDeaths$ dea
JOIN MyCovidProject..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER 2,3


SELECT * FROM 
PercentPopulationVaccinated

