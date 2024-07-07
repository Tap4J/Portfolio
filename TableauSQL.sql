/*

Queries for Tableau Project

*/

-- 1.
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

-- 2.

Select location, SUM(new_deaths) as TotalDeathCount
From covid_data
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3.

Select location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_data
Group by location, Population
order by PercentPopulationInfected desc

-- 4.


Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_data
Group by Location, Population, date
order by PercentPopulationInfected desc
