/*
Covid 19 Data Exploration (Updated to 9/7/2022)

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProjectV2..CovidDeaths2
Where continent is not null
order by 3,4

Select *
From PortfolioProjectV2..CovidVaccinations2
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectV2..CovidDeaths2
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectV2..CovidDeaths2
Where continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population is infected with Covid

Select Location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjectV2..CovidDeaths2
Where continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjectV2..CovidDeaths2
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectV2..CovidDeaths2
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT AND INCOME

-- Highest Death Count Broken Down by Continent and Income

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectV2..CovidDeaths2
Where continent is null
Group by Location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjectV2..CovidDeaths2
Where continent is not null
Group by date
order by 1,2

-- GLOBAL NUMBERS Total

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjectV2..CovidDeaths2
Where continent is not null
order by 1,2

-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
From PortfolioProjectV2..CovidDeaths2 dea
join PortfolioProjectV2..CovidVaccinations2 vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Using CTE to preform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingVaccinations
From PortfolioProjectV2..CovidDeaths2 dea
join PortfolioProjectV2..CovidVaccinations2 vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingVaccinations/population)*100
From PopvsVac
order by 2,3

-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingVaccinations
From PortfolioProjectV2..CovidDeaths2 dea
join PortfolioProjectV2..CovidVaccinations2 vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingVaccinations/population)*100
From #PercentPopulationVaccinated
order by 2,3

-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.continent) as RollingVaccinations
From PortfolioProjectV2..CovidDeaths2 dea
join PortfolioProjectV2..CovidVaccinations2 vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null

Create View ContinentDeathCount as 
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectV2..CovidDeaths2
Where continent is null
Group by Location

Create View CountryDeathCount as
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectV2..CovidDeaths2
Where continent is not null
Group by Location