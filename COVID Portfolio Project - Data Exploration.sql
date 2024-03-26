SELECT date_time, total_cases,  total_deaths, location, ((total_deaths *100.0)/total_cases) AS DeathPer
FROM coviddeaths
WHERE location like 'Nigeria'

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT date_time, total_cases, population, location, ((total_cases *100.0)/population) AS Per
FROM coviddeaths

-- Looking at countries with the hghest infection rate compared to the population
SELECT  population, MAX(total_cases) AS Highinfec, location, MAX((total_cases *100.0)/population) AS MAXPer
FROM coviddeaths
GROUP BY location, population
ORDER BY MAXPer DESC


-- Showing countries with the highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeath
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeath DESC

-- Let's break thing down by continent
SELECT location, MAX(total_deaths) AS TotalDeath
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeath DESC

-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeath
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeath DESC

-- Global numbers
SELECT date_time, SUM(new_cases) AS total_cases,  SUM(new_deaths) AS total_deaths, SUM(new_deaths*100.0)/SUM(new_cases) as Percases 
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date_time
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases,  SUM(new_deaths) AS total_deaths, SUM(new_deaths*100.0)/SUM(new_cases) as Percases 
FROM coviddeaths
WHERE continent IS NOT NULL
--GROUP BY date_time
ORDER BY 1,2
 
-- Join covid deaths with covid vaccination table
SELECT *
FROM coviddeaths AS dea
JOIN covidvacc AS vac
ON dea.location = vac.location
AND dea.date_time =vac.date_time

--Looking at Total population vs Vaccinations
SELECT dea.continent, dea.location, dea.date_time, dea.population, vac.new_vaccinations
FROM coviddeaths AS dea
JOIN covidvacc AS vac
ON dea.location = vac.location
AND dea.date_time = vac.date_time
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Use CTE
WITH PopvsVac (continent, location, date_time, new_vaccination, RollPeopleVacc)
AS
(
SELECT dea.continent, dea.location, dea.date_time, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date_time) AS RollPeopleVacc
--(RollPeopleVacc*100.0)/population
FROM coviddeaths AS dea
JOIN covidvacc AS vac
ON dea.location = vac.location
AND dea.date_time = vac.date_time
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * 
FROM PopvsVac

-- Create views for later visualisation 
CREATE VIEW PercentPopulstionVaccinated as
SELECT dea.continent, dea.location, dea.date_time, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date_time) AS RollPeopleVacc
--(RollPeopleVacc*100.0)/population
FROM coviddeaths AS dea
JOIN covidvacc AS vac
ON dea.location = vac.location
AND dea.date_time = vac.date_time
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulstionVaccinated