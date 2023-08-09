use coviddatabase;

select * from CovidDeaths
where continent is not null
order by 3,4;

select * from CovidVaccinations
order by 3,4;

select  location, date, total_cases,New_cases, Total_deaths, population
from CovidDeaths 
order by 1,2;


--Data Cleaing steps
Alter table CovidDeaths
Alter column total_deaths DECIMAL(18,2); 

Alter table CovidDeaths
Alter column total_cases DECIMAL(18,2) ; 

Alter table CovidDeaths
Alter column new_deaths DECIMAL(18,2) ;

Alter table CovidVaccinations
Alter column new_Vaccinations DECIMAL(18,2) ;


--Looking at total_cases vs total_deaths
select location, date, total_cases, total_deaths, ( total_deaths / total_cases) *100 as DeathPercent
from CovidDeaths
where location like '%states%'
order by 1,2;


--Looking at total_cases vs population
select location, date, total_cases, Population, ( total_cases /population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%states%'
order by 1,2;


--Looking at countries with highest infection rate compared to the population
select location, Population,  max(total_cases) as HighestInfectedCount, Max(( total_cases /population))*100 as PercentPopulationInfected
from CovidDeaths
where continent is not null
group by location,Population  
order by PercentPopulationInfected desc;


--Showig countries with highest Death Count Per population
select location, max(total_deaths) as DeathCount
from CovidDeaths
where continent is not null
group by location
order by DeathCount desc;


--Showig contienet with highest DeathCount per population
select continent, max(total_deaths) as DeathCount
from CovidDeaths
where continent is not  null
group by continent
order by DeathCount desc;


--Global Numbers
select  SUM(new_cases) As Total_cases, SUM(new_deaths) as Total_deaths  , sum(new_deaths) /  Nullif (sum(new_cases),0) * 100 as DeathsPerecent  
from CovidDeaths
where continent is not  null
--Group by date
order by 1,2;




---using CTE 
with PopvsVac(continent, location,date,population,new_vaccinations,RollingPeopleVaccinated )
as(
---Join CovidDeaths table with CovidVaccinatedby using two columns to look at Total population vs total Vaccinated 
select  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as  RollingPeopleVaccinated
from CovidDeaths  dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not  null
)
select * , (RollingPeopleVaccinated / population ) * 100   PeopleVaccinated from PopvsVac

-- drop table 
Drop table if exists #PercentPeopleVaccinated

--Temp table 
Create table #PercentPeopleVaccinated
(continent nvarchar(255), 
location nvarchar(255),
date datetime ,
population numeric ,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)
 insert into #PercentPeopleVaccinated   
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as  RollingPeopleVaccinated
from CovidDeaths  dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not  null 
select * , (RollingPeopleVaccinated / population ) * 100  from #PercentPeopleVaccinated;


--Creating view for  later  visulizations 
create view PercentPeopleVaccinated as  
select  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date ) as  RollingPeopleVaccinated
from CovidDeaths  dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not  null

select * from PercentPeopleVaccinated 














