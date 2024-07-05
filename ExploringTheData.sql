Select *
From covid_data
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From covid_data
order by 1,2

--Looking at total case vs total deaths
--Shows the likelihood of dying if you get covid in Slovakia
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From covid_data
Where location like '%Slovakia%'
order by 1,2

--Total cases vs population
--Population that get covid in Slovakia
Select location, date, total_cases, population, (total_cases/population)*100 as PopulationWithCovidPercentage
From covid_data
Where location like '%Slovakia%'
order by 1,2

--Countries with highest infection rate compared to population
Select location, max(total_cases) as HighestInfectionCount, population, (max(total_cases)/population)*100 AS PercentPopulationInfected
From covid_data
Group by location, Population
order by PercentPopulationInfected desc

--Countries with highest death rate compared to population
Select location, max(cast(total_deaths as int)) as HighestDeathCount, population, (max(cast(total_deaths as int))/population)*100 AS PercentPopulationDeaths
From covid_data
where continent is not null
Group by location, Population
order by HighestDeathCount desc

-- Select with continent
Select continent, max(cast(total_deaths as int)) as HighestDeathCount
From covid_data
where continent is not null
Group by continent
order by HighestDeathCount desc

-- Select with continent but better with location
Select location, max(cast(total_deaths as int)) as HighestDeathCount
From covid_data
where continent is null
Group by location
order by HighestDeathCount desc

-- Select Global numbers
Select SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths,
Case
	WHEN SUM(new_cases) = 0 then 0
	ELSE SUM(new_deaths)/SUM(new_cases)*100 
end as DeathPercentage
From covid_data
where continent is not null
--group by date
order by 1,2

--Total population and vacination slovakia
Select continent, location, date, population, new_vaccinations, total_vaccinations
From covid_data
where continent is not null and location like '%Slovakia%'
order by 2,3

--Total vaccination country
Select continent, location, date, population, new_vaccinations, total_vaccinations,
SUM(new_vaccinations) OVER (Partition by location order by location, date) as rollingNewVaccinated
From covid_data
where continent is not null
order by 2,3

--USE CTE 
With PopulationVsVaccination(continent, location, date, population, new_vaccinations, rollingNewVaccinated)
as
(
Select continent, location, date, population, new_vaccinations,
SUM(new_vaccinations) OVER (Partition by location order by location, date) as rollingNewVaccinated
From covid_data
where continent is not null
)
Select *, (rollingNewVaccinated/population)*100 as rollingPercentage
from PopulationVsVaccination

--USE Temp temple
DROP TABLE if exists PercentPopulationVaccinated;
Create TEMP Table PercentPopulationVaccinated
(
	Continent varchar(255),
	Location varchar(255),
	Date date,
	Population numeric,
	New_vaccinations numeric,
	RollingNewVaccinated numeric
);
Insert into PercentPopulationVaccinated
Select continent, location, date, population, new_vaccinations,
SUM(new_vaccinations) OVER (Partition by location order by location, date) as rollingNewVaccinated
From covid_data
where continent is not null;

Select *, (rollingNewVaccinated/population)*100 as rollingPercentage
from PercentPopulationVaccinated

--Creating View to store data for visualizations

Create View PercentPopulationVaccinated as 
Select continent, location, date, population, new_vaccinations,
SUM(new_vaccinations) OVER (Partition by location order by location, date) as rollingNewVaccinated
From covid_data
where continent is not null;

--Select from view
Select *
From PercentPopulationVaccinated