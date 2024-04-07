-- Select *
-- From covid_vacs
-- Order by 3,4 

-- Select *
-- From covid_deaths
-- Order by 3,4 

Select Location, date, total_cases, new_cases, total_deaths, population
From covid_deaths
Order by 1, 2

-- Looking at the Total Cases vs Total Deaths
-- This shows the likelihood of dying if from contracting Covid in North America (up until 4/30/21)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From covid_deaths
Where Location In ('united states','canada','mexico')
And continent is not null
Order by 1, 2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid in Russia (up until 4/30/21)
Select Location, date, total_cases, population, (total_cases/population)*100 as Cases_Percentage
From covid_deaths
Where Location like 'Russia'
And continent is not null
Order by 1, 2

-- Looking at countries with Highest Infection Rate compared to Population
Select Location, population, Max(total_cases) as Highest_Infection_Count, Max((total_cases/population))*100 as PerOf_Population_Infected
From covid_deaths
Group by Location, Population
Order by Per_Population_Infected desc

-- Showing the Countries with the Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS UNSIGNED INTEGER)) AS Total_Death_Count
FROM covid_deaths
Where Continent is not null
GROUP BY Location
ORDER BY Total_Death_Count DESC;

-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED INTEGER)) AS Total_Death_Count
FROM covid_deaths
Where Continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC;

-- Global Numbers: Total cases, deaths and death percentage
SELECT 
       SUM(new_cases) AS Total_Cases, 
       SUM(CAST(new_deaths AS UNSIGNED INTEGER)) AS Total_Deaths, 
       SUM(CAST(new_deaths AS UNSiGNED INTEGER))/SUM(new_cases)*100 as Death_Percentage
FROM covid_deaths 
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Looking at Total Population vs Total Vaccination 
Select de.continent, de.location, de.date, de.population, cast(vac.new_vaccinations as unsigned integer),
Sum(cast(vac.new_vaccinations as unsigned integer)) over(partition by de.location order by de.location, de.date) as RollingPeepsVaxed
From covid_deaths de
Join covid_vacs vac
On de.location = vac.location
And de.date = vac.date
Where de.continent is not null
Order by 2,3

With PvsV (Continent, location, date, population, new_vaccinations, RollingPeepsVaxed)  
as
(Select de.continent, de.location, de.date, de.population, cast(vac.new_vaccinations as unsigned integer),
Sum(cast(vac.new_vaccinations as unsigned integer)) over(partition by de.location order by de.location, de.date) as RollingPeepsVaxed
From covid_deaths de
Join covid_vacs vac
On de.location = vac.location
And de.date = vac.date
Where de.continent is not null
)
Select *, (rollingpeepsvaxed/population)*100
From PvsV

-- Creating View for Tableau Visualization 1: (Highest Infection Rate compared to Population)
Create view HighestInfectionRate as
Select Location, population, Max(total_cases) as Highest_Infection_Count, Max((total_cases/population))*100 as PerOf_Population_Infected
From covid_deaths
Group by Location, Population


-- Creating View for Tableau Visualization 2: (Continents with the highest death count per population)
Create view HighestDeathPerPopulation as
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED INTEGER)) AS Total_Death_Count
FROM covid_deaths
Where Continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC;

-- Creating View for Tableau Visualization 3: (Likelihood of dying if from contracting Covid in North America)
Create view NAlikelihoodofdying as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From covid_deaths
Where Location In ('united states','canada','mexico')
And continent is not null
Order by 1, 2


-- Creating View for Tableau Visualization 4: (Shows what percentage of population got Covid in Russia)
Create view RussiaInfectionPercentage as
Select Location, date, total_cases, population, (total_cases/population)*100 as Cases_Percentage
From covid_deaths
Where Location like 'Russia'
And continent is not null
Order by 1, 2

-- Creating View for Tableau Visualization 5: (Total Population vs Total Vaccination )
Create view PercentPopulationVaccinated as
Select de.continent, de.location, de.date, de.population, cast(vac.new_vaccinations as unsigned integer),
Sum(cast(vac.new_vaccinations as unsigned integer)) over(partition by de.location order by de.location, de.date) as RollingPeepsVaxed
From covid_deaths de
Join covid_vacs vac
On de.location = vac.location
And de.date = vac.date
Where de.continent is not null


