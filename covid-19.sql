-- 1. Selecting CovidDeaths table 
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY location, date



-- 2. SELECTING DATA 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY location, date



-- 3. CALCULATING THE DEATH PERCENTAGE 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY location, date



-- 4. PERCENTAGE OF POPULATION INFECTED
SELECT location, population, MAX(total_cases) as  MAX_of_TotalCases, MAX((total_cases/CAST(population AS float))*100) AS Population_Infected_Percent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Population_Infected_Percent



-- 5. CONTINENTS WITH HIGHEST DEATH COUNT
SELECT continent, MAX(CAST(total_deaths AS int))AS MAX_of_TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY MAX_of_TotalDeaths DESC



-- 6. COUNTRIES WITH HIGHEST DEATH COUNT 
SELECT location, MAX(CAST(total_deaths AS int)) AS MAX_of_TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY MAX_of_TotalDeaths DESC



-- 7. GLOBAL NUMBERS
SELECT date, SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths AS int)) as Total_Deaths , (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date



-- 8. GLOBAL DEATH PERCENTAGE
SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths



-- 9. POPULATION Vs VACCINATIONS
SELECT DEATHS.continent, DEATHS.location, DEATHS.date, DEATHS.population, VACCINATIONS.new_vaccinations,
 SUM(CAST(new_vaccinations AS bigint)) over (PARTITION BY DEATHS.LOCATION ORDER BY deaths.location, deaths.date) 
FROM PortfolioProject..CovidDeaths DEATHS
JOIN PortfolioProject..CovidVaccinations VACCINATIONS
 ON DEATHS.location = VACCINATIONS.location AND DEATHS.date = VACCINATIONS.date
WHERE DEATHS.continent IS NOT NULL
ORDER BY DEATHS.location, DEATHS.date



-- 10. VACCINATION PERCENTAGE USING CTE
	WITH Popvacc  as
	(
	SELECT DEATHS.continent, DEATHS.location, DEATHS.date, DEATHS.population, VACCINATIONS.new_vaccinations,
	 SUM(CAST(new_vaccinations AS bigint)) over (PARTITION BY DEATHS.LOCATION ORDER BY deaths.location, deaths.date) as Rolling_Vaccinations
	FROM PortfolioProject..CovidDeaths DEATHS
	JOIN PortfolioProject..CovidVaccinations VACCINATIONS
	 ON DEATHS.location = VACCINATIONS.location AND DEATHS.date = VACCINATIONS.date
	WHERE DEATHS.continent IS NOT NULL
	--ORDER BY DEATHS.location, DEATHS.date
	)

	Select *, (Rolling_Vaccinations/population)*100 as Vaccination_Percentage 
	from Popvacc
	where location = 'india'



-- 11. CREATING TEMP TABLE 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEATHS.continent, DEATHS.location, DEATHS.date, DEATHS.population, VACCINATIONS.new_vaccinations,
	 SUM(CAST(new_vaccinations AS bigint)) over (PARTITION BY DEATHS.LOCATION ORDER BY deaths.location, deaths.date) as Rolling_Vaccinations
	FROM PortfolioProject..CovidDeaths DEATHS
	JOIN PortfolioProject..CovidVaccinations VACCINATIONS
	 ON DEATHS.location = VACCINATIONS.location AND DEATHS.date = VACCINATIONS.date
	WHERE DEATHS.continent IS NOT NULL

	Select *, (Rolling_Vaccinations/population)*100 as Vaccination_Percentage 
	from #PercentPopulationVaccinated
	ORDER  BY Location, Date


-- 12. CREATING VIEW
Create View Total_Deaths as 
SELECT continent, MAX(CAST(total_deaths AS int))AS MAX_of_TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent









