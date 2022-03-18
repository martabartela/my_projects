--select * from dbo.CovidDeaths
--order by 3,4

--select * from dbo.CovidVaccinations
--order by 3,4

USE PortfolioProject
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
order by location, date

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contact covid at your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
and location = 'Poland'
order by location, date

-- Looking at Total Cases vs Total Deaths
-- Shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from dbo.CovidDeaths
where continent is not null
and location = 'Poland'
order by location, date

--Looking at Countries with highest infetion Rate compared to the population
select location, population,MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population)*100) as PercentagePopulationInfected
from dbo.CovidDeaths
where continent is not null
--where location = 'Poland'
group by location, population
order by PercentagePopulationInfected desc

-- Showing countries with Highest Death Count per population
select location, max(cast(total_deaths as int)) as total_death_count
from dbo.CovidDeaths
where continent is not null
group by location
order by total_death_count desc

-- Let's break things down by continent
-- Showing continents with the hoghest death count per population
select continent, max(cast(total_deaths as int)) as total_death_count
from dbo.CovidDeaths
where continent is not null
group by continent
order by total_death_count desc


-- GLOBAL NUMBERS

select date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage  --, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null 
group by date
order by date

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage  --, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null 
--group by date
--order by date


-- Looking at Total Population vs Vaccinations
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, LAG(vac.new_vaccinations) over (Order BY dea.date),cast(LAG(vac.new_vaccinations) over (Order BY dea.date) as int)+vac.new_vaccinations
--from dbo.CovidDeaths dea
--join dbo.CovidVaccinations vac
--on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null and dea.location='Canada'
--order by location, date


ALTER TABLE dbo.CovidDeaths  ALTER COLUMN location  nvarchar(150)


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccineted
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
and dea.location='Canada'
order by dea.location, dea.date

--USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinantions, RollingPeopleVaccinated)
as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
CAST(SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as bigint) as RollingPeopleVaccineted

from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
--and dea.location='Canada'
--order by dea.location, dea.date)
)
select * ,(RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE
DROP table if exists #PercentPopulationVaccinted

Create table #PercentPopulationVaccinted (
Continent nvarchar(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_vacciantions numeric,
RollingPeopleVaccinated numeric )




insert into #PercentPopulationVaccinted
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
CAST(SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as bigint) as RollingPeopleVaccineted
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 

select * ,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinted


--Creating view to store data for later vizualizations

create view PercentPopulationVaccinted as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
CAST(SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as bigint) as RollingPeopleVaccineted
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select * from PercentPopulationVaccinted