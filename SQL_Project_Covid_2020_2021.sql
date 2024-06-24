SELECT * 
FROM `leafy-respect-417320.covid_deaths.covid_d`;

SELECT *
FROM `leafy-respect-417320.covid_vaccinations.covid_v`

SELECT total_cases, new_cases, total_deaths, population
FROM `leafy-respect-417320.covid_deaths.covid_d`;


--Total Cases vs Total Deaths
 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `leafy-respect-417320.covid_deaths.covid_d`
WHERE location like '%States%'
	ORDER BY 1,2

--Total Cases Vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM `leafy-respect-417320.covid_deaths.covid_d`
WHERE location like '%States%'
	ORDER BY 1,2

--Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM `leafy-respect-417320.covid_deaths.covid_d`
	GROUP BY location, population
	ORDER BY PercentPopulationInfected desc

--Highest Death Rate compared to Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM `leafy-respect-417320.covid_deaths.covid_d`
WHERE continent is not null
	GROUP BY location
	ORDER BY TotalDeathCount desc

--Death Rate compared to Population by Continent

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM `leafy-respect-417320.covid_deaths.covid_d`
WHERE continent is not null
	GROUP BY continent
	ORDER BY TotalDeathCount desc

--Global Numbers by Date

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `leafy-respect-417320.covid_deaths.covid_d`
WHERE continent is not null
	GROUP BY date
	ORDER BY 1,2

-- Total Population vs Vaccinations

WITH PopvsVac
AS
(
SELECT dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations, SUM(CAST (dea.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM `leafy-respect-417320.covid_vaccinations.covid_v` dea
JOIN `leafy-respect-417320.covid_deaths.covid_d` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
 )
SELECT *, (RollingPeopleVaccinated/population)*100
FROM 
  PopVsVac

-- TEMP TABLE

CREATE TABLE `covid_deaths.PercentPopulationVaccinated` (
continent STRING, 
location STRING, 
date TIMESTAMP, 
population NUMERIC, 
new_vaccinations NUMERIC, 
RollingPeopleVaccinated NUMERIC
);

INSERT INTO `leafy-respect-417320.PercentPopulationVaccinated` (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
SELECT dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations, SUM(CAST (dea.new_vaccinations --AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM `leafy-respect-417320.covid_vaccinations.covid_v` dea
JOIN `leafy-respect-417320.covid_deaths.covid_d` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
	ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM 
  `leafy-respect-417320.PercentPopulationVaccinated`

--Create View to store data for later visualizations

CREATE VIEW covid_deaths.PercPopVaccinated as
SELECT dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations, SUM(CAST (dea.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM `leafy-respect-417320.covid_vaccinations.covid_v` dea
JOIN `leafy-respect-417320.covid_deaths.covid_d` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3
