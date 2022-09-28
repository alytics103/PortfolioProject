-- Selecting data that we are going to use 

select * from worldometer_data$

select country/region population, totalcases, newcases, totaldeaths, newdeaths
from worldometer_data$

-- Cleaning some data to comfortable use 

sp_rename 'worldometer_data$.country/region', 'Country', 'column'



select country, population, totalcases, newcases, totaldeaths, newdeaths
from worldometer_data$ 
order by 3 desc

-- Looking at total cases vs total deaths 

select country, totalcases, totaldeaths, (totaldeaths/totalcases) * 100 as DeathPercentage 
from worldometer_data$ 
order by 4 desc

-- Looking at total cases vs population 
-- Shows what percentage of population got covid

select country, population, totalcases, totaldeaths, (totalcases/population) * 100 as CovidPercentage 
from worldometer_data$ 
order by 4 desc


-- Looking at countries with highest infection rate compared to population

select country, population, max(totalcases) as HighestInfection, max ((totalcases/population)) * 100 as PercentPopInfected
from worldometer_data$ 
group by country, population
order by PercentPopInfected desc 

-- Countries with highest death count per population 

select country, max(totaldeaths) as DeathCount  
from worldometer_data$
group by country
order by DeathCount desc

-- Breaking down by continets 

select continent, max(totaldeaths) as DeathCount  
from worldometer_data$
where continent is not null 
group by continent

-- Global Numbers 

select sum(newcases) as totalcases, sum(newdeaths) totaldeaths, sum(newdeaths)/sum(newcases) * 100 as DeathPercentage 
from worldometer_data$

-- Looking at total cases vs recovered 

select dw.country, dw.population, dw.totalcases, dw.totaldeaths, sum(cw.recovered+cw.NewRecovered) as TotalRecovered,
sum(cw.recovered+cw.NewRecovered)/(dw.totalcases) * 100 as PercentageTotRec
from worldometer_data$ dw
left join country_wise_latest$ cw on cw.country = dw.country
where dw.continent is not null
group by dw.country, dw.population, dw.totalcases, dw.totaldeaths, cw.recovered, TotalRecovered

-- Use Cte 

with CaseVsRec (Country, Population, totalcases, totaldeaths, TotalRecovered, PercentageTotRec)
as 
(
select dw.country, dw.population, dw.totalcases, dw.totaldeaths, sum(cw.recovered+cw.NewRecovered) as TotalRecovered,
sum(cw.recovered+cw.NewRecovered)/(dw.totalcases) * 100 as PercentageTotRec
from worldometer_data$ dw
left join country_wise_latest$ cw on cw.country = dw.country
where dw.continent is not null
group by dw.country, dw.population, dw.totalcases, dw.totaldeaths, cw.recovered, TotalRecovered
)
select * from CaseVsRec

-- Temp Table 

drop table if exists #PercentPopRecovered


 create table #PercentPopRecovered 
( 
country nvarchar (255),
Population numeric, 
totalcases numeric,
totaldeaths numeric,
TotalRecovered numeric 
)

insert into #PercentPopRecovered 
select dw.country, dw.population, dw.totalcases, dw.totaldeaths, sum(cw.recovered+cw.NewRecovered) as TotalRecovered
from worldometer_data$ dw
left join country_wise_latest$ cw on cw.country = dw.country
group by dw.country, dw.population, dw.totalcases, dw.totaldeaths, cw.recovered, TotalRecovered

select * from #PercentPopulationRecovered 


-- Creating view 

create view PercentPopulationRecovered  as
select dw.country, dw.population, dw.totalcases, dw.totaldeaths, sum(cw.recovered+cw.NewRecovered) as TotalRecovered,
sum(cw.recovered+cw.NewRecovered)/(dw.totalcases) * 100 as TotalPercentageRecovered
from worldometer_data$ dw
left join country_wise_latest$ cw on cw.country = dw.country
where dw.continent is not null
group by dw.country, dw.population, dw.totalcases, dw.totaldeaths, cw.recovered, TotalRecovered
