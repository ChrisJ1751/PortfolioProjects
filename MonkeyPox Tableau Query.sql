/*
Queries used for Tableau MonkeyPox Data Set
*/

-- Showing All the Data within the data set

Select *
From MonkeyPox..MonkeyPoxData
order by 1,2


-- Table showing cases, death and death percentage for all countires globally

Select SUM(Cases) as total_cases, SUM(Deaths) as total_deaths, SUM(Deaths)/SUM(Cases)*100 as DeathPercentage
From MonkeyPox..MonkeyPoxData
order by 1,2

-- Total Cases vs Continent

Select Continent, SUM(Cases) as TotalCaseCount
From MonkeyPox..MonkeyPoxData
Group by Continent
order by TotalCaseCount desc

-- Total Deaths vs Continent

Select Continent, SUM(Deaths) as TotalDeathCount
From MonkeyPox..MonkeyPoxData
Group by Continent
order by TotalDeathCount desc

-- Percent Population Infected in each Country

Select Country, Population, MAX(Cases) as HighestInfectionCount,  Max((Cases/population))*100 as PercentPopulationInfected
From MonkeyPox..MonkeyPoxData
Group by Country, Population
order by PercentPopulationInfected desc



