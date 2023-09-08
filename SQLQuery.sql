USE ProjectPortfolio
SELECT * from CovidDeaths
where continent is not null
ORDER BY 3,4
SELECT * from CovidVaccinations
ORDER BY 3,4

--Select Data that we are going to use
select Location,date,total_cases,new_cases,total_deaths,population 
from CovidDeaths
order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract with corona virus in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
Order by total_cases desc

--Total cases Vs Population
--Shows what percentage of population got covid
SELECT location,date,total_cases,population,(total_cases/population)*100 as covidcasepercentage
from CovidDeaths
where location like '%states%'
Order by covidcasepercentage desc

-- Countries with highest infection rate compared to population
SELECT location,max(total_cases) as Highestinfectioncount,population,max(total_cases/population)*100 as percentagepopulationinfected
from CovidDeaths
group by location, population
Order by percentagepopulationinfected desc

--Showing countries with Highest Death count
SELECT location,max(cast(total_deaths as int)) as Highestdeathcount,population,max(total_deaths/population)*100 as percentagepopulationdied
from CovidDeaths
where continent is not null
group by location, population
Order by Highestdeathcount desc

--Let's break things down by continent

SELECT continent,max(cast(total_deaths as int)) as Highestdeathcount,max(total_deaths/population)*100 as percentagepopulationdied
from CovidDeaths
where continent is not null
group by continent
Order by Highestdeathcount desc

--Global Numbers
SELECT sum(new_cases) as total_New_cases,sum(cast(new_deaths as int)) as total_new_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage from CovidDeaths
where continent is not null
--group by date
Order by 1,2

--Looking at Total population Vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,dea.total_deaths,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as cumulative_vaccinations
--cumulative_vaccinations/dea.population
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac(continent,location,date,population,new_vaccinations,cumulative_vaccinations) as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as cumulative_vaccinations
--cumulative_vaccinations/dea.population
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(cumulative_vaccinations/population)*100 as Vacpercent from PopvsVac

--Temp Table

Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
cumulative_vaccinations numeric
)
Insert into #PercentagePopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as cumulative_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(cumulative_vaccinations/population)*100 as Vacpercent 
from #PercentagePopulationVaccinated

--Creating Views to store data for later visualisations

Create View PercentPupulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as cumulative_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
