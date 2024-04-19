--data is between 2020-01-05 to 2022-12-31

--look at the total_cases vs total_death and people dead per hundred
select location, date, total_cases, total_deaths, round((cast(total_deaths as float)/total_cases)*100, 4) DeathPercentage
from Project.dbo.CovidDeath
where continent is not NULL
order by location, date

--look at the total_cases vs population
select location, date, total_cases, population, round((cast(total_cases as float)/population)*100, 4) DeathPercentage
from Project.dbo.CovidDeath
where continent is not NULL
order by location, date

--look at countires with highest infection
select location, max(total_cases) total_cases, population, round( (cast (max(total_cases) as float)/population)*100, 4) InfectedPercentage
from Project.dbo.CovidDeath
where continent is not NULL
group by location, population
order by InfectedPercentage desc

--look at the countries with the higest death count per population
select location, population, max(total_deaths) total_death, round( (cast (max(total_deaths) as float)/population)*100, 4) DeathPercentage
from Project.dbo.CovidDeath
where continent is not NULL
group by location, population
order by DeathPercentage desc

--look at the continent with the highest death count per population
select location, population, max(total_deaths) total_death, round( (cast (max(total_deaths) as float)/population)*100, 4) DeathPercentage
from Project.dbo.CovidDeath
where continent is NULL
group by location, population
order by DeathPercentage desc

--join two tables
select *
from Project.dbo.CovidDeath dea
join Project.dbo.CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date

--look at total population vs vacinations
select dea.location, dea.date, population, new_vaccinations
from Project.dbo.CovidDeath dea
join Project.dbo.CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL and new_vaccinations is not NULL
order by dea.location, dea.date

--use new_vaccinations to roll up and get the total_vaccinations
select dea.location, dea.date, population, new_vaccinations, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) total_vaccinations
from Project.dbo.CovidDeath dea
join Project.dbo.CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL and new_vaccinations is not NULL
order by dea.location, dea.date

--use CTE to get totai_vaccinations per population
with VaccinationPerPopulation (location, date, popualtion, new_vaccinations, RollupVaccinations, VaccinationPercentage)
as
(select dea.location, 
        dea.date, population, 
        new_vaccinations, 
        sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) total_vaccinations, 
        round((cast(total_vaccinations as float)/population)*100, 4) VaccinationPercentage
from Project.dbo.CovidDeath dea
join Project.dbo.CovidVaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL and new_vaccinations is not NULL)
select * from VaccinationPerPopulation
order by VaccinationPercentage desc

--crate view to store data for later visualizations
create view CountriesWithHighestInfection as
select location, max(total_cases) total_cases, population, round( (cast (max(total_cases) as float)/population)*100, 4) InfectedPercentage
from Project.dbo.CovidDeath
where continent is not NULL
group by location, population