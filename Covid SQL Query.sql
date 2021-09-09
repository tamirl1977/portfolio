-- World Data - Covid Tests, Vaccinations and Deaths --
-- Data From Ourworldindata https://ourworldindata.org/covid-deaths 8/9/2021--
-- Data Receives In 1 CSV File Format And Splited To 2 Excels Which Were Uploaeded To The SQL Server
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


-- Shows All Of The Data From Both Tables
select * from [OurWorldInData-Covid]..deaths
order by 3,4

select * from [OurWorldInData-Covid]..vaccinations
order by 3,4


-- Shows The Percentage Of Deaths Out Of The Total Cases In Israel By Date

select location, date, total_cases, total_deaths, concat(round((total_deaths/total_cases)*100,3),'%') as death_Percentage 
from [OurWorldInData-Covid]..Deaths
where location like '%isr%'
order by 1,2


-- Shows The Percentage Of Covid Infected Population Israel By Date

select location, date, total_cases, population, concat(round((total_cases/population)*100,3),'%') as percent_of_population_infacted 
from [OurWorldInData-Covid]..  Deaths
where location like '%isr%' 
order by 1,2


-- Shows The Current Infection Rate In Countries With More Then 5 Mil Population

select location, max(total_cases) as current_total_cases, population, concat(max(round((total_cases/population)*100,3)),'%') as current_percent_of_population_infacted 
from [OurWorldInData-Covid]..  Deaths
group by continent, location, population
having population > 5000000 and continent is not null
order by current_percent_of_population_infacted desc


-- Shows The Rank Of Countries Current Death Percentage With More Then 5 Mil Population 

select location, max(cast(total_deaths as int)) as total_cases, population, concat(max(round((total_deaths/population)*100,3)),'%') as percent_of_deaths,
dense_rank() over(order by location) as country_rank
from [OurWorldInData-Covid]..  Deaths
group by continent, location, population
having population > 5000000 and continent is not null
order by country_rank


-- Shows The Current Death Percentage By Continent & World

select location, max(cast(total_deaths as int)) as toatl_cases, population, concat(max(round((total_deaths/population)*100,3)),'%') as percent_of_deaths 
from [OurWorldInData-Covid]..  Deaths
group by continent, location, population
having continent is null and population is not null
order by Percent_Of_Deaths desc


-- Shos The Global New Cases And Deaths In The World Every Day

select date, sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as total_deaths, concat((sum(cast(new_deaths as int))/sum(new_cases))*100,'%') as death_percentage
from [OurWorldInData-Covid]..  Deaths
where continent is not null
group by date
order by 1


-- Shows The Current Total Cases And Deaths In The World

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, concat(round((sum(cast(new_deaths as int))/sum(new_cases))*100,3),'%') as death_percentage
from [OurWorldInData-Covid]..  Deaths
where continent is not null


-- Shows The Total Vaccinated Per Day And Total Number Of Vaccinated Vs Population

select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as New_Vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Total_Vaccinated
from [OurWorldInData-Covid]..Deaths dea
join [OurWorldInData-Covid]..vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- Total Vaccinated Vs Population With Rolleing Percentage Of Vaccinated
-- Includes Population Who Got More Then 1 Vaccinations (Total Can Be Greater Then Population)

					--Using CTE--

with PopulationVsVaccinated (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from [OurWorldInData-Covid]..Deaths dea
join [OurWorldInData-Covid]..vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *,  concat(round((rolling_people_vaccinated/population) * 100,3),'%') as rolleing_percentage_vaccinated
from PopulationVsVaccinated
order by 1,2,3


					--Using Temp Table--

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_people_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from [OurWorldInData-Covid]..Deaths dea
join [OurWorldInData-Covid]..vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *,  concat(round((rolling_people_vaccinated/population) * 100,3),'%') as rolleing_percentage_vaccinated
from #PercentPopulationVaccinated


-- Creating View For Later Visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [OurWorldInData-Covid]..Deaths dea
join [OurWorldInData-Covid]..vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

--select *
--from PercentPopulationVaccinated





