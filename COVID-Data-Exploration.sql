/*

Covid-19 Data Exploration

*/




-- Specify database used
use PortfolioProject
go

-- Load CovidDeaths table
select *
from ..CovidDeaths
where continent is not null
order by 3,4

-- Select data 

select location, date, total_cases, new_cases, total_deaths, population
from ..CovidDeaths
order by 1,2

-- Total cases vs total deaths
-- shows the likelihood of dying from contracting Covid-19 

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as PercentDeath
from  ..CovidDeaths
where location = 'Germany'
and continent is not null
order by location,date

-- Total cases vs population
-- Shows percentage of population infected

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from  ..CovidDeaths
where location = 'Germany'
and continent is not null
order by location,date

-- Countries with highest infection counts per population

select location, population, MAX(total_cases) as MaxInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from  ..CovidDeaths
group by location, population
order by PercentPopulationInfected DESC

-- Countries with highest death counts per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from  ..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount DESC

-- Continents with highest death counts per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from  ..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC

-- Daily global percent death

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as TotalPercentDeath
from  ..CovidDeaths
where continent is not null
group by date
order by 1,2 DESC

-- Total global percent deaths

select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as TotalPercentDeath
from  ..CovidDeaths
where continent is not null
order by 1,2 DESC

-- Join CovidDeaths and CovidVaccinations data sets on location and date

select *
from ..CovidDeaths cdea
join ..Vaccinations cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date
where cdea.continent is not null
order by 1,2 DESC


-- Total population vs vaccinations per day

select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.daily_vaccinations
from ..CovidDeaths cdea
join ..Vaccinations cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date 
where cdea.continent is not null
order by 2,3 DESC

-- Cumulative counts of people vaccinated per location per day

select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.daily_vaccinations
, SUM(cvac.daily_vaccinations) OVER (Partition by cdea.location Order by cdea.date) as CumulativeCountVaccinated
from ..CovidDeaths cdea
join ..Vaccinations cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date 
where cdea.continent is not null
order by 2,3


-- Use CTE to calculate in percentage of people vaccinated per location per day

with PopvsVac (continent, location, date, population, daily_vaccinations, CumulativeCountVaccinated)
as
(
select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.daily_vaccinations
, SUM(cvac.daily_vaccinations) OVER (Partition by cdea.location Order by cdea.date) as CumulativeCountVaccinated
from ..CovidDeaths cdea
join ..Vaccinations cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date 
where cdea.continent is not null
)
select *, (CumulativeCountVaccinated/population)*100 as PercentPopulationVaccinated
from PopvsVac


-- Temp table to calculate percentage of people vaccinated

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
daily_vaccinations numeric,
CumulativeCountVaccinated numeric
)

insert into #PercentPopulationVaccinated
select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.daily_vaccinations
, SUM(cvac.daily_vaccinations) OVER (Partition by cdea.location Order by cdea.date) as CumulativeCountVaccinated
from ..CovidDeaths cdea
join ..Vaccinations cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date 
where cdea.continent is not null

select *, (CumulativeCountVaccinated/population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated

-- Create view of percentage of people vaccinated for visualization

CREATE VIEW PopulationVaccinated as
select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.daily_vaccinations
, SUM(cvac.daily_vaccinations) OVER (Partition by cdea.location Order by cdea.date) as CumulativeCountVaccinated
from ..CovidDeaths cdea
join ..Vaccinations cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date 
where cdea.continent is not null

-- Create view of daily global percent deaths

create view GlobalDeaths as
select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as TotalPercentDeath
from  ..CovidDeaths
where continent is not null
group by date

-- Create view of countries with highest death count per population

create view CountryDeaths as 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from  ..CovidDeaths
where continent is not null
group by location
