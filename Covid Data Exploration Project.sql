SELECT *
FROM PortfolioProjects..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProjects..CovidVaccinations
--order by 3,4

--Select data that we are going to be using
Select location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total cases vs Total deaths
-- Shows the chances of dying if you contract covid in a country
Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
Where location like 'Nigeria'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows the percentage of population with covid
Select location,date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--Where location like 'Nigeria'
Where continent is not null
order by 1,2

-- Looking at Countries with highest infection rate compared to population
Select location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--Where location like 'Nigeria'
Where continent is not null
Group by location,population
order by PercentPopulationInfected desc


--Showing Countries with the highest Death count per population
Select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
--Where location like 'Nigeria'
Where continent is not null
Group by location,population
order by TotalDeathCount desc


-- EXPLORING BY CONTINENTS
-- Showing Continents with Highest Death Count per Population

Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
--Where location like 'Nigeria'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as PercentageDeath 
FROM PortfolioProjects..CovidDeaths
--Where location like 'Nigeria'
Where continent is not null
Group by date
order by 1,2


---Looking at the total figure
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as PercentageDeath 
FROM PortfolioProjects..CovidDeaths
--Where location like 'Nigeria'
Where continent is not null
--Group by date
order by 1,2



-- Looking at Total Population Vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)as CummulativePeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Looking at Total Population Vs Vaccination
-- USING CTE
With PopvsVac (continent, location, date, population, new_vaccinations, cummulativePeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)as CummulativePeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (CummulativePeopleVaccinated/population)*100
From PopvsVac


-- Looking at Total Population Vs Vaccination
-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
cummulativePeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)as CummulativePeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (CummulativePeopleVaccinated/population)*100 as PercentCummulative
From #PercentPopulationVaccinated


-- Creating View to Store Data for Subsequent Visualisation
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)as CummulativePeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select * 
From PercentPopulationVaccinated
