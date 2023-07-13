Select *
From PorfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PorfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PorfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PorfolioProject..CovidDeaths
Where location like '%united kingdom%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
From PorfolioProject..CovidDeaths
Where location like '%united kingdom%'
order by 1,2


-- Looking at countries with highest infection rate companred to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PorfolioProject..CovidDeaths
--Where location like '%united kingdom%'
Group by Location, population
order by PercentPopulationInfected desc

-- Showing countries with hiest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--Where location like '%united kingdom%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's break this down by continent

-- Showing continents with the highest death count per capita

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--Where location like '%united kingdom%'
Where continent is null
Group by location
order by TotalDeathCount desc



-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage--, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PorfolioProject..CovidDeaths
--Where location like '%united kingdom%'
Where continent is not null
--Group by date
order by 1,2



-- Loooking at Total Population vs Vaccinations with cast or convert

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
--, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population) * 100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3


--USE CTE

with PopvsVac (Continent, Location, Date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated / population) * 100 
From PopvsVac






-- Temp table



DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated / Population) * 100 
From #PercentPopulationVaccinated


--Creating view to store data for later visualisations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

select *
From PercentPopulationVaccinated