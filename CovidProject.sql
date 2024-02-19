SELECT * 
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

-- this command helps us to see all our data from columns 3 and 4 (you can use the columns numbers or the name of the column in this case will be location and date, where is for



-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
ORDER BY 1, 2



-- Looking at Total Cases vs Total Deaths .. how many cases are in this country and how many deaths do they have for the entire cases. We need to dived the total_deaths/total_cases and multiply it by 100 because we are trying to get the percentage also using AS to give and alias to the new column.
--WHERE is if you want to look a country in particular. 
 
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
AND continent IS NOT NULL
ORDER BY 1, 2




-- Looking at Total Cases vs Population
-- Shows what pecentage of population get Covid

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
ORDER BY 1, 2







-- Looking at Countries with Highest Infaction Rate compared to Population
--MAX is because we only want to see the very highest cases and then we will group our results by locations and population. Ordering those results from descendent 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population)) * 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC




-- Showing Countries with the Highest Death Count per Population
--In this query we need to use CAST (casting or converting date) because in our original file total_deaths is an NVARCHAR we need it as an INTERGER (INT).
--The reason we use WHERE continent IS NOT NULL is because some of the data the query without WHERE shows is the total of the continent itself and we don’t need that.

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount  DESC


-- LET'S BREAK THINGS DOWN BY CONTITENT 
-- Showing continents with the highest death count per population, only 6 results. The results will be a little wrong North America will only shows United States totals for some reason but for the purpose of hierarchy the exercise is enough.

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount  DESC


--But if we change the SELECT to this query then we will have the total we need.
--9

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount  DESC












-- GLOBAL NUMBERS (All the countries)
-- In this query we will use a couple of aggregating functions 

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


--Going back to our vaccinations table

SELECT * 
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3,4

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Looking at Total Population vs Vaccinations
-- First thing is to JOIN the tables 
-- CONVERT IS THE SAME AS CAST.
-- When we want to see how many people of a particular country has been vaccinated we need to first create a new column with a CTE

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND DEA.DATE = VAC.DATE
WHERE dea.continent IS NOT NULL 
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/population)* 100 
FROM PopvsVac

-- TEMP TABLE
-- Adding the DROP TABLE IF EXISTS help us running our query multiple times in case we need to make alterations to the table without dropping.

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)* 100 FROM #PercentPopulationVaccinated

-- Create a view to store date for tableau visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--order by 2,3

SELECT * FROM PercentPopulationVaccinated

