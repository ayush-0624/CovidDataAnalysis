---          COVID DATA EXPLORATION ----
-- we have got the data from ourworldindata.org
-- Accessing CovidDeaths table 

select * from CovidDataAnalysisProject..CovidDeaths 
where continent is not null 
order by 3,4

--select * from CovidDataAnalysisProject..CovidVaccinations 
--where continent is not null 
--order by 3,4

-- select data that we are going to use 

Select Location,date,total_cases,new_cases, total_deaths,population from 
CovidDataAnalysisProject..CovidDeaths
where continent is not null
order by 1,2;

-- Total cases vs Total deaths or Death_percentage
 
Select Location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage from 
CovidDataAnalysisProject..CovidDeaths 
where location like '%India%'
order by death_percentage;


--  Total cases vs population 
-- it shows how much percentage of people got infected with covid

Select Location,date,population,total_cases,(total_cases/population) as Population_PercentInfected from 
CovidDataAnalysisProject..CovidDeaths 
where location like '%India%'
order by 1,2; 


-- Countries with highest infection rate compare to population

Select Location,population,max(total_cases) as Highest_Infection_Count,max(total_cases/population)*100 as  Population_Percent_Infected from 
CovidDataAnalysisProject..CovidDeaths 
--where location like '%India%'
Group by location,population
order by Population_Percent_Infected DESC; 
 
-- Countries with Highest Death Count per Population
-- we are using cast() here to typecast into integer

Select Location, MAX(cast(Total_deaths as int)) as Total_Death_Count
From CovidDataAnalysisProject..CovidDeaths
Where continent is not null 
Group by Location
order by Total_Death_Count desc;

-- We are analyzing the data by continent now 
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDataAnalysisProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount DESC;

-- Accessing & showing covid data globally 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDataAnalysisProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

-- Accessing CovidVaccination and CovidDeaths boths

-- Total Population vs Vaccinations
-- Percentage of Population that has recieved at least one Covid Vaccine
-- Rolling People vaccinated or cummulative people vaccinated
-- convert() is same as cast()

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDataAnalysisProject..CovidDeaths dea
Join CovidDataAnalysisProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

-- (Rolling People vaccinated/ population) *100 = How much percentage of people got vaccinated

--  CTE: Common Table Expression 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDataAnalysisProject..CovidDeaths dea
Join CovidDataAnalysisProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;


-- creating a Temp table : to perform calculation on previous query 


DROP Table if exists Percent_Population_Vaccinated
Create Table Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDataAnalysisProject..CovidDeaths dea
Join CovidDataAnalysisProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From Percent_Population_Vaccinated;




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDataAnalysisProject..CovidDeaths dea
Join CovidDataAnalysisProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;

select * from PercentPopulationVaccinated;
