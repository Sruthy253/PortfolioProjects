Select*
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select*From PortfolioProject..covidVaccination
--order by 3,4
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

--Looking at Total Cases Vs Total Deaths
Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%States%'
where continent is not null
order by 1, 2
--shows likelihood of dying in Australia bcoz of Covid
Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Australia%'
where continent is not null
order by 1, 2
--Total Deaths v/s Population
--% of citizens had the Covid
Select location, date, population, total_cases,(total_cases/population)*100 as Percentage_Population_Infected
From PortfolioProject..CovidDeaths
--Where location like '%India%'
order by 1, 2
--Countries with highest infection rate
Select location, population, Max(total_cases) as Highest_Infection_Rate, Max(total_cases/population)*100 as Infected_Population_Rate
From PortfolioProject..CovidDeaths
Group by location, population
where continent is not null
order by Infected_Population_Rate desc

--Highest Death Rate
Select location,Max(cast((total_deaths) as int))as Death_Count
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by Death_Count desc

--Continental break-up
Select continent,Max(cast((total_deaths) as int))as Death_Count
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by Death_Count desc

--Global Count
Select date,Sum(new_cases)as Total_Cases,Sum(cast(new_deaths as int))as Total_Deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1, 2
--Total World Count
Select Sum(new_cases)as Total_Cases,Sum(cast(new_deaths as int))as Total_Deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

--Joining Two Datasets
Select*
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
On dea.location= vac.location
and dea.date=vac.date

--Population vs Vaccination rate

Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
On dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2, 3


With PopvsVac (continent, Location, Date, Population,New_Vaccinations,  Rolling_People_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
On dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
)
Select*, (Rolling_People_vaccinated/population)*100
From PopvsVac

--Temp Table
Drop Table if exists #Percentage_Population_Vaccinated
Create Table #Percentage_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
Rolling_People_vaccinated numeric
)
Insert into #Percentage_Population_Vaccinated
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       Cast(vac.new_vaccinations AS BIGINT),
       Sum(Cast(vac.new_vaccinations AS BIGINT)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_vaccinated
FROM   portfolioproject..coviddeaths dea
       JOIN portfolioproject..covidvaccination vac
         ON dea.location = vac.location
            AND dea.date = vac.date
--WHERE  dea.continent IS NOT NULL 
Select*, (Rolling_People_vaccinated/Population)*100
From #Percentage_Population_Vaccinated

--Creating View for data visualization

Create View Percentage_Population_Vaccinated
as
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       Cast(vac.new_vaccinations AS BIGINT) as new_vaccinations,
       Sum(Cast(vac.new_vaccinations AS BIGINT)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_vaccinated
FROM   portfolioproject..coviddeaths dea
       JOIN portfolioproject..covidvaccination vac
         ON dea.location = vac.location
            AND dea.date = vac.date
WHERE  dea.continent IS NOT NULL 

select * from Percentage_Population_Vaccinated
