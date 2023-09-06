SELECT *
FROM Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM Project..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Project..CovidDeaths
WHERE location LIKE '%state%'
ORDER BY 1,2

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM Project..CovidDeaths
--WHERE location LIKE '%state%'
ORDER BY 1,2


SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Project..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


---Analysing by continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Project..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


SELECT SUM(new_cases) AS total_case, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM Project..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


---Joining 2 tables
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS PeopleVacinated
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

WITH popvsvac (continent, location, date, population, new_vaccinations, PeopleVacinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS PeopleVacinated
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (PeopleVacinated/population)*100
FROM popvsvac




DROP TABLE IF EXISTS #PercentPopulationVacinated
CREATE TABLE #PercentPopulationVacinated
(
Continent NVARCHAR(255),
location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
PeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVacinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS PeopleVacinated
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
---WHERE dea.continent IS NOT NULL


SELECT *, (PeopleVaccinated/Population)*100
FROM #PercentPopulationVacinated


CREATE VIEW PercentPopulationVacinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS PeopleVacinated
FROM Project..CovidDeaths dea
JOIN Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT * 
FROM PercentPopulationVacinated