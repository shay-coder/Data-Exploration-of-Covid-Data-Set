

--SELECT * FROM CovidDB..CovidVaccinations

--SELECT * FROM CovidDB..CovidVaccinations
--ORDER BY 3,4

Select * FROM CovidDB..CovidDeaths
WHERE continent is not NULL 
Order by 3,4

SELECT date,location,total_deaths,total_cases,new_cases,population
FROM CovidDB..CovidDeaths
WHERE continent is not NULL 
Order by 3,4

--sp_help CovidDeaths   to check datatypes

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float


--Total Cases VS Total_Deaths
SELECT date,location,population,total_cases,total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM CovidDB..CovidDeaths
WHERE location like '%TAN%'
WHERE continent is not NULL 
Order by 1,2


-- Total cases VS Population

SELECT date,location,population,total_cases, (total_cases/population)*100 AS Cases_Percentage
FROM CovidDeaths
--WHERE location like '%states%'
Order by 1,2


--Countries with Highest Percenatge Rates
SELECT location,population,MAX(total_cases) AS Highest_Infected_Country, MAX((total_cases/population)*100) AS Cases_Percentage
FROM CovidDeaths

GROUP BY location, population
Order by 4 desc

-- Showing countries with highest death counts and population

SELECT location, MAX(cast (total_deaths as int)) AS Highest_Infected_Country
FROM CovidDeaths
WHERE continent is not NULL 
GROUP BY location
Order BY Highest_Infected_Country desc


-- Showing continents with highest death counts and population
SELECT location, MAX(cast (total_deaths as int)) AS Highest_Infected_Country
FROM CovidDeaths
WHERE continent is NULL 
GROUP BY location
Order BY Highest_Infected_Country desc

--Global Data

SELECT SUM(cast(new_deaths as int)) AS total_Deaths, SUM(new_cases) AS total_Cases, SUM(cast(new_deaths as int))/SUM(new_cases) *100  AS DeathPercentage
FROM CovidDeaths
WHERE continent is not  null
--GROUP BY location
Order BY 1,2


--- Covid Vacciantion Table

SELECT *
FROM CovidVaccinations
order by 4

-- Joining

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated







