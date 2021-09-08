-- Data from ourworldindata https://ourworldindata.org/covid-deaths 8/9/2021--


select * from [OurWorldInData-Covid]..deaths
order by 3,4

select * from [OurWorldInData-Covid]..vaccinations
order by 3,4


-- total casses Vs total deaths
-- shows the percentage of deaths of total cases in Israel

select location, date, total_cases, total_deaths, concat(round((total_deaths/total_cases)*100,3),'%') as Death_Percentage 
from [OurWorldInData-Covid]..Deaths
where location like '%isr%'
order by 1,2


-- total casses Vs population
-- shows the percentage of population who has covid In Israel

select location, total_cases, population, concat(round((total_cases/population)*100,3),'%') as Percent_Of_Population_Infacted 
from [OurWorldInData-Covid]..  Deaths
where location like '%isr%' 
order by 1,2


-- countries with highest infection rate per population above 5 Mil

select location, max(total_cases) as MaxToatlCases, population, max(round((total_cases/population)*100,3)) as Max_Percent_Population_Infacted 
from [OurWorldInData-Covid]..  Deaths
group by continent, location, population
having population > 5000000 and continent is not null
order by Max_Percent_Population_Infacted desc


-- countries with highest deaths percentage with population above 5 Mil

select location, max(cast(total_deaths as int)) as Total_Cases, population, max(round((total_deaths/population)*100,3)) as Percent_Of_Deaths 
from [OurWorldInData-Covid]..  Deaths
group by continent, location, population
having population > 5000000 and continent is not null
order by Percent_Of_Deaths desc


-- deaths percentage by continent

select location, max(cast(total_deaths as int)) as Toatl_Cases, population, max(round((total_deaths/population)*100,3)) as Percent_Of_Deaths 
from [OurWorldInData-Covid]..  Deaths
group by continent, location, population
having continent is null and population is not null
order by Percent_Of_Deaths desc


-- Global numbers - deaths every day

select date, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as Total_Deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
from [OurWorldInData-Covid]..  Deaths
where continent is not null
group by date
order by 1,2


-- Global numbers - total deaths 

select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
from [OurWorldInData-Covid]..  Deaths
where continent is not null


-- total vaccinated Vs population

select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as New_Vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinated
from [OurWorldInData-Covid]..Deaths dea
join [OurWorldInData-Covid]..vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- total vaccinated Vs population with Rolleing_Percentage_Vaccinated

					--using CTE--

with PopulationVsVaccinated (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as New_Vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [OurWorldInData-Covid]..Deaths dea
join [OurWorldInData-Covid]..vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *,  (RollingPeopleVaccinated/population) * 100 as Rolleing_Percentage_Vaccinated
from PopulationVsVaccinated


					--using a temp table--

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [OurWorldInData-Covid]..Deaths dea
join [OurWorldInData-Covid]..vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *,  (RollingPeopleVaccinated/population) * 100 as Rolleing_Percentage_Vaccinated
from #PercentPopulationVaccinated


-- creating view for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [OurWorldInData-Covid]..Deaths dea
join [OurWorldInData-Covid]..vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

--select *
--from PercentPopulationVaccinated





