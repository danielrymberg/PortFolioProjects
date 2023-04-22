/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


select *
from CovidDeaths2023
where continent is not null
order by 3,4

-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths2023
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths

-- Shows likelihood of dying if you contract covid in your country - USA

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths2023
where location = 'United States' and continent is not null
order by 1,2

--Shows likelihood of dying if you contract covid in your country - Israel

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths2023
where location = 'Israel' and continent is not null
order by 1,2

--Total Cases vs Population
--Shows what percentage of population infected with Covid

select location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths2023
where continent is not null
--and location = 'Israel'
order by 1,2

-- Shows what percentage of population infected with Covid in your country - Israel
select location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths2023
where continent is not null
and location = 'Israel'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

select location, population,max(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths2023
-- where location = 'Israel'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths2023
-- where location = 'Israel'
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population - option 1

select location, max(total_deaths) as TotalDeathCount
from CovidDeaths2023
-- where location = 'Israel'
where continent is null
group by location
order by TotalDeathCount desc

-- Showing continents with the highest deat count per population -- option 2

select continent, max(total_deaths) as TotalDeathCount
from CovidDeaths2023
-- where location = 'Israel'
where continent is not null
group by continent
order by TotalDeathCount desc



-- Global Numbers
-- DeathPercentage by Date - option 1 -  without null

select date, total_cases, total_deaths, sum(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths2023 
where continent is not null 
and total_cases is not null
and total_deaths is not null
group by date,total_cases,total_deaths
order by date

-- DeathPercentage by Date - option 2 - with null

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
(sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from CovidDeaths2023
where continent is not null
group by date
order by 1,2

--Summary of Deathpercentage Worldwide
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
(sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from CovidDeaths2023
where continent is not null
--Group by date
order by 1,2



--Total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths2023 dea
join CovidVaccinations vac on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--and dea.location = 'Israel'
order by 2,3

--Shows Percentage of Population that has recieved at least one Covid Vaccine in your country - Israel

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths2023 dea
join CovidVaccinations vac on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
and dea.location = 'Israel'
order by 2,3


--Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths2023 dea
join CovidVaccinations vac on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--and dea.location = 'Israel'
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 VacPercentage
from PopvsVac

--Using CTE to perform Calculation on Partition By in previous query in your country - Israel
with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths2023 dea
join CovidVaccinations vac on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
and dea.location = 'Israel'
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 VacPercentage
from PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths2023 dea
join CovidVaccinations vac on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null 
--and dea.location = 'Israel'
-- order by 2,3

select *, (RollingPeopleVaccinated/population)*100 VacPercentage
from #PercentPopulationVaccinated





-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths2023 dea
join CovidVaccinations vac on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 


