/*

Queries used for Tableau Project

*/

-- 1. Specify database 
USE PortfolioProject
GO


-- 2. Standardize Date Format
-- select DateConverted, convert(Date, date)
-- from ..CovidDeaths

-- update CovidDeaths
-- set date = convert(Date, date)

-- Alter Table CovidDeaths
-- add DateConverted Date;

-- update CovidDeaths
-- set DateConverted = convert(Date, date)

-- 3. Confirmed cases and deaths 

create view TableauCOVIDCases as

select  

population, continent, location, date, total_cases, new_cases, total_deaths, cast(new_deaths as int) as new_deaths,

ISNULL((cast(new_deaths as int))/NULLIF(new_cases, 0), 0)*100 as DailyPercentNewDeaths,

ISNULL(total_deaths/NULLIF(total_cases, 0), 0)*100 as DailyTotalPercentDeaths,

(total_cases/population)*100 as PercentPopulationInfected

from  ..CovidDeaths

where continent is not null
and new_cases is not null
and new_deaths is not null

group by population, continent, location, date, total_cases, new_cases, total_deaths, new_deaths

-- order by date


-- 4. Percentage of people fully and partly vaccinated
--    Number of people fully and partly vaccinated

/*

A person is considered partly vaccinated if they have received only one dose of a 2-dose vaccine protocol.
A person is considered fully vaccinated if they have received a single-dose vaccine or both doses of a two-dose vaccine.

*/

-- Join CovidDeaths and CovidVaccinations data sets on location and date

select *
from ..CovidDeaths cdea
join ..Vaccinations cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date
where cdea.continent is not null
order by 1,2 DESC

-- Daily number and percentage of people fully and partly vaccinated by location

create view TableauCOVIDVaccinations as

select

cdea.continent, cdea.location, cdea.date, cdea.population, cvac.total_vaccinations,

cvac.people_vaccinated, cvac.people_fully_vaccinated, cvac.daily_vaccinations,

(cvac.people_vaccinated/cdea.population)*100 as PercentPeoplePartlyVaccinated,

(cvac.people_fully_vaccinated/cdea.population)*100 as PercentPeopleFullyVaccinated,

(cvac.total_vaccinations/cdea.population)*100 as TotalPercentPeopleVaccinated

from ..CovidDeaths cdea

join ..Vaccinations cvac
	on cdea.location = cvac.location
	and cdea.date = cvac.date 

where cdea.continent is not null
and cvac.people_vaccinated is not null
and cvac.people_fully_vaccinated is not null


order by cdea.date