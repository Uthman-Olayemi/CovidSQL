

Select *
From dbo.CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From dbo.CovidVaccinations
--Order by 3,4
--SELECT DATA TO BE USED
Select Location, date, total_cases, new_cases, total_deaths, population 
From dbo.CovidDeaths
Order by 1,2

--TOTAL DEATHS vs TOTAL CASES
---Showing Likelihood of death by a person through covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From dbo.CovidDeaths
Where Location = 'Canada'
Order by 1,2

--TOTAL DEATHS vs POPULATION in Canada
Select Location, date, Population, total_cases, (total_cases/Population)*100 as InfectedPopulationPercentage
From dbo.CovidDeaths
Where continent is not null
Where Location = 'Canada'
Order by 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as InfectedPopulationPercentage
From dbo.CovidDeaths
Where continent is not null
--Where Location = 'Canada'
Group by Location, Population
Order by InfectedPopulationPercentage desc

--COUNTRIES WITH HIGHEST DEATH COUNT
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
Where continent is not null
--Where Location = 'Canada'
Group by Location
Order by TotalDeathCount desc

--DEATHS BY CONTINENT
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
Where continent is not null
--Where Location = 'Canada'
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS Of TOTAL CASES AND DEATHS
Select date,SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
From dbo.CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--TOTAL NUMBER OF CASES AND DEATHS

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
From dbo.CovidDeaths
Where continent is not null
--Group by date
Order by 1,2

--TOTAL POPULATION vs VACCINATION

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3

--PARTITIONING TOTAL POPULATION vs VACCINATION
-- USE CTE

With PopvsVac ( Continent, Location, date, Population, new_vaccinations, RollingVaccinatedPeople) as

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT (int, new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingVaccinatedPeople
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)

Select * , (RollingVaccinatedPeople/Population)*100 as PercentageRollingVacc
From PopvsVac


--TEMP TABLE
Drop Table if exists PercentPopulationVaccinated

Create Table PercentPopulationVacc
( Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaccinatedPeople numeric,
)
Insert into PercentPopulationVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT (int, new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingVaccinatedPeople
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Select * , (RollingVaccinatedPeople/Population)*100 as PercentageRollingVacc
From PercentPopulationVacc


CREATE VIEW PercentPopVacc as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT (int, new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingVaccinatedPeople
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopVacc