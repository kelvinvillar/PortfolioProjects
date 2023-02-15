Select *
From PortfolioProject..CovidDeaths
Order by	3,4


--Select *
--From PortfolioProject..CovidVaccinations
--Order by	3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by	1,2

-- looking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by	1,2

--looking at the Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 As TotalCasesPercentage
From PortfolioProject..CovidDeaths
Where location like '%Philippines%'
Order by	1,2

-- looking at countries with highest infection rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by 4 desc


-- Showing the Continents with the highest death count per population

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not Null
Group by continent
Order by TotalDeathCount desc


-- Showing the Continents with the highest death count per population


-- Global Numbers

Select 
	Sum(cast(new_cases as int)) TotalCases, 
	Sum(cast(new_deaths as int)) TotalDeath, 
	Sum(cast(new_deaths as int))/Sum(new_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by	1,2


-- Looking at total population vs Vaccinations 

Select
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) 
		Over (Partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
order by 2,3


-- Use CTE

With PopVsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
As
(
Select
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) 
		Over (Partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac



-- Temp Table

Drop Table if Exists #PercentPopulationVaccination 
Create Table #PercentPopulationVaccination 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccination
Select
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) 
		Over (Partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccination


-- Creating View to store data later for visualizations

Create View PercentPopulationVaccinated
As
Select
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) 
		Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
--order by 2,3

Select *
From PercentPopulationVaccinated
