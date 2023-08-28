/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
use sql_project;
select * from covid_death;
select * from covid_vaccination;

-- select data that we are going to be using --
select location,date,total_cases,new_cases,total_deaths,population 
from covid_death
order by date;

-- Total Cases Vs Populations --
-- Sow what % of population got Covid --
select location,date,total_cases,population,concat(round((total_cases/population)*100,5),"%") as Case_percentage
from covid_death
order by date;


-- Looking at Highest infections and Death Day --
select location , max(total_cases) from covid_death
group by location;
select location,date , max(total_cases) as Highest_case from covid_death
group by location,date
order by   Highest_case desc;



-- Looking at total Cases vs Total Deaths --
select location,date,total_cases,total_deaths,concat(round((total_deaths/total_cases)*100,2),"%") as Death_percentage
from covid_death
order by date;

-- Showing Countries with Highest Death count Per Population --
select location ,max(total_deaths) as total_death_count
from covid_death
where location is not null
group by location 
order by total_death_count;

-- Showing the continent Highest Deaths count --
select continent ,max(total_deaths) as total_death_count
from covid_death
where continent is not null
group by continent 
order by total_death_count;

-- Global Numbers -- as Death_Percentage
select  date ,sum(new_cases) new_cases,sum(new_deaths) new_deaths,concat((sum(new_deaths)/sum(new_cases)*100 ),"%") as Deaths_Percentage
from covid_death 
group by date 
order by date,Deaths_Percentage desc;

-- Looking at total Population Vs vaccinations --

with PopvsVac (continent,location,date,population,new_vaccinations,Rolling_people_vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) Rolling_people_vaccinated
from covid_death dea
join covid_vaccination vac 
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
)
select * ,concat( round((Rolling_people_vaccinated/population)*100,5),"%") Total_percentage_vaccinated 
from PopvsVac;

-- TEMP_TABLE --

create temporary table percentagepopulationvaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) Rolling_people_vaccinated
from covid_death dea
join covid_vaccination vac 
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null;

select * ,concat( round((Rolling_people_vaccinated/population)*100,5),"%") Total_percentage_vaccinated 
from percentagepopulationvaccinated;

-- Creating View  --

create view Deathpercentage as 
select  date ,sum(new_cases) new_cases,sum(new_deaths) new_deaths,concat((sum(new_deaths)/sum(new_cases)*100 ),"%") as Deaths_Percentage
from covid_death 
group by date 
order by date,Deaths_Percentage desc;

select * from Deathpercentage;

