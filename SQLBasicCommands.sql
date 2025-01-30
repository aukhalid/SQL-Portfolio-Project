--BASIC COMMAND IN SQL:

SELECT*
FROM [Portfolio Project]..CovidDeaths

SELECT location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
ORDER BY 1,2

--Looking at Total Caes Vs Total Deaths

SELECT location, date ,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
ORDER BY 1,2

--Looking at Total Caes Vs Population (Shows what % of population got Covid)

SELECT location, date, population ,total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From [Portfolio Project]..CovidDeaths
ORDER BY 1,2

--Looking at countries with highest infection rate

SELECT location, population ,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From [Portfolio Project]..CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc

-- Showing countries with highest desth count per population

SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
From [Portfolio Project]..CovidDeaths
GROUP BY location
ORDER BY HighestDeathCount desc


-- Showing contilents with highest desth count per population

SELECT continent, MAX(cast(total_deaths as int)) AS HighestDeathCount
From [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount desc

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases , SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS 2

SELECT SUM(new_cases) as TotalCases , SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Total Vaccinations

SELECT* 
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2

--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeoplevaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3


--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeoplevaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeoplevaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)

SELECT* , (RollingPeoplevaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentagePeopleVaccinated
CREATE TABLE #PercentagePeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)

INSERT INTO #PercentagePeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeoplevaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT* , (RollingPeoplevaccinated/population)*100
FROM #PercentagePeopleVaccinated

-- Creating view for data visualizations later

CREATE VIEW PercentagePeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeoplevaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT*
FROM PercentagePeopleVaccinated