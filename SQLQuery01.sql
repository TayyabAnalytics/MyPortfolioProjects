SELECT location, date, new_cases, total_cases, total_deaths, population
FROM Deaths
ORDER BY location, date

--Total Cases vs Total Deaths in Finland
SELECT location, date, 
CAST(total_deaths AS float) AS total_deaths, 
CAST(total_cases AS float) AS total_cases, 
(CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS PercentDeaths
FROM Deaths
WHERE location = 'Finland'
ORDER BY location, date

--Total Cases vs Population
--Rate of Infection in Finland
SELECT date, location,population, 
CAST(total_cases AS int) AS total_cases, 
(CAST(total_cases AS int)/population)*100 AS PercentInfected
FROM Deaths
WHERE location = 'Finland'
ORDER BY location, date

--Countries with highest infection rates
SELECT  location, population, MAX(cast (total_cases as int)) AS HighestInfectionCount, 
MAX(cast (total_cases as int)/population) *100 InfectedPercentPop
FROM Deaths
GROUP BY location, population
ORDER BY InfectedPercentPop DESC

--Countries with highest death rate
SELECT  location, MAX(cast (total_deaths as int)) AS HighestDeathCount 
FROM Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--Death count broken by continents
SELECT  continent, MAX(cast (total_deaths as int)) AS HighestDeathCount 
FROM Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

--Global stats for death percentages by population

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths,
SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM Deaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1, 2

--Global stats for overall death percentage
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths,
SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM Deaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2

--Different counrties total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population,
		CONVERT(bigint, vac.new_vaccinations) AS new_vaccinations, 
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingVaccinations
FROM Deaths dea
JOIN Vaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent  IS NOT NULL
ORDER BY location, date

--Using CTE to calculate overall vaccinated population percentage for different countries

WITH PopVac (continent, location, date, popualtion, new_vaccinations, RollingVaccinations)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population,
		CONVERT(bigint, vac.new_vaccinations) AS new_vaccinations, 
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingVaccinations
FROM Deaths dea
JOIN Vaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent  IS NOT NULL
)
SELECT *, (RollingVaccinations / popualtion) * 100 RollingVacPercent
FROM PopVac

--View for visualization

CREATE VIEW PercentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population,
		CONVERT(bigint, vac.new_vaccinations) AS new_vaccinations, 
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingVaccinations
FROM Deaths dea
JOIN Vaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent  IS NOT NULL