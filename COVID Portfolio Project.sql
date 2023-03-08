Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4
-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths in the United States


Select Location, date, total_cases, total_deaths, concat(round((total_deaths / total_cases)*100, 2), '%') as death_rate
From PortfolioProject..CovidDeaths
where location like '%states%' and total_deaths is not null and continent is not null
order by 1,2

--Looking at Total Cases vs Population
-- Shows the rate of infection from COVID in the US

Select Location, date, total_cases, population, concat(round((total_cases / population)*100, 2), '%') as infected_rate
From PortfolioProject..CovidDeaths
where location like '%states%' and total_deaths is not null and continent is not null
order by 1,2

-- Looking at countries with highest infection rate vs population

Select location, population, MAX(total_cases) as total_infections, CONCAT(ROUND(MAX(total_cases/population) * 100, 2), '%') as InfectionRate
From PortfolioProject..CovidDeaths
where population is not null and continent is not null
group by location, population
having MAX(total_cases) is not null
order by InfectionRate desc

-- Showing countries with highest death count

Select location, MAX(cast(total_deaths as int)) as death_count
From PortfolioProject..CovidDeaths
Where continent is not null 
group by Location
order by death_count desc

--Showing continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as death_count
From PortfolioProject..CovidDeaths
Where continent is not null 
group by continent
order by death_count desc


-- Global Numbers

Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as Death_Percentage
From PortfolioProject..CovidDeaths
where continent is not null and Total_Cases is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations with CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, daily_change) as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
 sum(cast(cv.new_vaccinations as bigint)) over(partition by cd.location order by cd.location, cd.date) as daily_change
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null
--order by 2, 3
)

select *, daily_change/Population as percent_vax
from PopvsVac

-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
running_total numeric)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
 sum(cast(cv.new_vaccinations as bigint)) over(partition by cd.location order by cd.location, cd.date) as daily_change
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null

Select *, daily_change/Population as percent_vax
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
 sum(cast(cv.new_vaccinations as bigint)) over(partition by cd.location order by cd.location, cd.date) as daily_change
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null


select *
from PercentPopulationVaccinated