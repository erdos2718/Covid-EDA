--overview of covid deaths and cases
Select * FROM PortfolioProject..CovidDeaths$ 
Where continent is NULL
ORDER BY 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--rolling morbidity 
Select Location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathRate 
From PortfolioProject..CovidDeaths$
order by 1,2

--rolling infection count
Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentInfected
From PortfolioProject..CovidDeaths$
order by 1,2

--a look at maxium infection by location
Select Location, Max(total_cases) as HighestInfectionCount, Population, Max(total_cases/population)*100 as PercentInfected
From PortfolioProject..CovidDeaths$
Group by Location, Population
order by PercentInfected Desc 

--maxium total death count by location
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not NULL
Group by Location
order by TotalDeathCount desc 

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is NULL
Group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathRate 
From PortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as rollingPeopleVacc
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



with PopvsVac (Continent, Location, Date, Population, new_vaccinations, rollingPeopleVacc)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as rollingPeopleVacc
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.location like '%states%'

)
Select *,(rollingPeopleVacc/Population)*100 from PopvsVac

--with CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, rollingPeopleVacc)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as rollingPeopleVacc
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)

USE PortfolioProject 
GO
Create View PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as rollingPeopleVacc
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- 1.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--2.
Select location, SUM(cast(new_deaths as int)) as totalDeathCount
From PortfolioProject..CovidDeaths$
where continent is null and location not in ('world', 'European Union', 'International','High income','Upper middle income','Lower middle income','Low income')
Group by location
order by totalDeathCount desc

--3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected

--4.
Select Location, Population, Date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Where location like '%states%'
Group by Location, Population, Date
order by PercentPopulationInfected desc