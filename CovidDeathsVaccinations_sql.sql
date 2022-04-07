select location, date, total_cases, total_deaths, (cast(total_deaths as  real) *100/total_cases) as DeathPercentage
from CovidDeaths
where location like '%india%'
order by 1,2;

-- Shows what percentage of population got covid
--Total cases vs population
select location, date, population, total_cases, (cast(total_cases as  real) *100/population) as PercentPopulationInfected
from CovidDeaths
where location like '%india%'
order by 1,2;

-- Looking at countries with highest infection rate compared to population--
select location, population, max(total_cases) as HighestInfectionCount, max((cast(total_cases as  real) *100/population)) as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc;



-- showing the countries with the highest death count per population--
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent != ''
group by location
order by TotalDeathCount desc;

-- let's break things down by continent--

-- Showing the continent with the highest death counts
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent != ''
group by continent
order by TotalDeathCount desc;

-- Global Numbers
select sum(cast(new_cases as real)) as total_cases, sum(cast(new_deaths as real)) as total_deaths, (sum(cast(new_deaths as real)) *100/(sum(cast(new_cases as real)))) as DeathPercentage
from CovidDeaths
where continent != ''
--group by date
order by 1,2;

--looking at total population vs vaccinations

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVacciniated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacciniated
--(RollingPeopleVacciniated/population)*100
from CovidDeaths dea
join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent !=''
--order by 2,3;
)

Select * , (RollingPeopleVacciniated*100)/population
from PopvsVac;

-- Use Temp Table

Create temporary Table PercentPopulationVaccinated
as
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacciniated numeric
);


Insert into PercentPopulationVaccinated
(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVacciniated)
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacciniated
--(RollingPeopleVacciniated/population)*100
from CovidDeaths dea
join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent !=''
--order by 2,3;
)

Select * , (RollingPeopleVacciniated*100)/population
from PercentPopulationVaccinated;


-- Creating view to store data for later visualisations
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacciniated
--(RollingPeopleVacciniated/population)*100
from CovidDeaths dea
join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent !=''
--order by 2,3;

select * from PercentPopulationVaccinated