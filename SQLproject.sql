SELECT * FROM Portfolio..DEA
WHERE continent is not null
order by location, date

--Данный запрос показывает процент населения, инфицированный вирусом
SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 as pecentage_of_infected 
FROM Portfolio..DEA where continent  is not null
ORDER by location, date



--Данный запрос показывает, сколько процентов людей от инфицированных скончались от вируса
select location, date, population, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as death_percentage 
from portfolio..dea where location = 'russia' 
order by date

--Данный запрос показывает процент населения, инфицированный вирусом
SELECT location, population, MAX(cast(total_cases as int)) as HIC,  MAX(total_cases/population)*100 as MM 
FROM Portfolio..DEA 
WHERE continent is not null
GROUP BY location, population 
ORDER BY MM DESC


SELECT location, population,  MAX(cast(total_deaths as int)) as DeathCount,  MAX((cast(total_deaths as int)/population))*100 as MM 
FROM Portfolio..DEA 
WHERE continent is not null
GROUP BY location, population
ORDER BY DeathCount DESC

--Данный запрос показывает сколько всего человек заразилось за весь период пандемии 
WITH VVV AS (SELECT location, max(cast(total_cases as bigint)) as cases FROM Portfolio..DEA WHERE continent is not null GROUP BY location)
Select SUM(cases) FROM VVV; 

--Данный запрос показывает, сколько всего людей умерло от COVID-19 за все время пандемии 
WITH DEATHS AS (SELECT location, MAX(cast(total_deaths as bigint)) as cases FROM Portfolio..DEA WHERE continent is not null GROUP BY location)
select sum(cases) FROM DEATHS;

--Распределение смертей от COVID-19 по континентам 
SELECT continent, sum(cast(new_deaths as int)) as DeathCount
FROM Portfolio..DEA 
WHERE continent is not null
GROUP BY continent
ORDER BY DeathCount DESC

Select date, SUM(new_cases) as total_cases_inthewrold, sum(cast(new_deaths as int)) as total_deaths_inthewrold, CASE when new_cases = 0 then null else sum(cast(new_deaths as float))/SUM(new_cases)*100 end as deathpercentage
FROM Portfolio..DEA
WHERE continent is not null
group by date, new_cases
order by date

--Глобальная статистика 
Select SUM(new_cases) as total_cases_inthewrold, sum(cast(new_deaths as int)) as total_deaths_inthewrold, sum(cast(new_deaths as float))/SUM(new_cases)*100 as deathpercentage
FROM Portfolio..DEA
WHERE continent is not null

--сколько вакцинированных
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.date) as totalVAC
from Portfolio..VAC VAC JOIN Portfolio..DEA DEA ON VAC.location = DEA.location and VAC.date = DEA.date
Where dea.continent is not null
order by 2,3

--Вакцинированный процент населения 
With PopVaccinated (continent, location, date, population, new_vaccinations, totalVAC)
as (Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    sum(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.date) as totalVAC
    from Portfolio..VAC VAC JOIN Portfolio..DEA DEA ON VAC.location = DEA.location and VAC.date = DEA.date
    Where dea.continent is not null)
Select *, (totalVAC/population)*100 as PercentageVaccinated 
FROM PopVaccinated
order by 2, 3

Drop table if exists #Вакцинированныйпроцентнаселения
Create table #Вакцинированныйпроцентнаселения 
(
Continent nvarchar(255),
Location nvarchar (255),
Date nvarchar (255), 
Population numeric,
New_vaccinations numeric, 
TotalVAC numeric
) 

Insert into #Вакцинированныйпроцентнаселения
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.date) as totalVAC
from Portfolio..VAC VAC JOIN Portfolio..DEA DEA ON VAC.location = DEA.location and VAC.date = DEA.date
Where dea.continent is not null

Select *, (totalVAC/population)*100 as PercentageVaccinated 
FROM #Вакцинированныйпроцентнаселения
order by 2, 3



Create View Вакцинированныйпроцентнаселения as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.date) as totalVAC
from Portfolio..VAC VAC JOIN Portfolio..DEA DEA ON VAC.location = DEA.location and VAC.date = DEA.date
Where dea.continent is not null
order by 2,3 


Select * FROM Вакцинированныйпроцентнаселения order by 2, 3 