SELECT * FROM Portfolio..DEA
WHERE continent is not null
order by location, date

--������ ������ ���������� ������� ���������, �������������� �������
SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 as pecentage_of_infected 
FROM Portfolio..DEA where continent  is not null
ORDER by location, date



--������ ������ ����������, ������� ��������� ����� �� �������������� ���������� �� ������
select location, date, population, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as death_percentage 
from portfolio..dea where location = 'russia' 
order by date

--������ ������ ���������� ������� ���������, �������������� �������
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

--������ ������ ���������� ������� ����� ������� ���������� �� ���� ������ �������� 
WITH VVV AS (SELECT location, max(cast(total_cases as bigint)) as cases FROM Portfolio..DEA WHERE continent is not null GROUP BY location)
Select SUM(cases) FROM VVV; 

--������ ������ ����������, ������� ����� ����� ������ �� COVID-19 �� ��� ����� �������� 
WITH DEATHS AS (SELECT location, MAX(cast(total_deaths as bigint)) as cases FROM Portfolio..DEA WHERE continent is not null GROUP BY location)
select sum(cases) FROM DEATHS;

--������������� ������� �� COVID-19 �� ����������� 
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

--���������� ���������� 
Select SUM(new_cases) as total_cases_inthewrold, sum(cast(new_deaths as int)) as total_deaths_inthewrold, sum(cast(new_deaths as float))/SUM(new_cases)*100 as deathpercentage
FROM Portfolio..DEA
WHERE continent is not null

--������� ���������������
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.date) as totalVAC
from Portfolio..VAC VAC JOIN Portfolio..DEA DEA ON VAC.location = DEA.location and VAC.date = DEA.date
Where dea.continent is not null
order by 2,3

--��������������� ������� ��������� 
With PopVaccinated (continent, location, date, population, new_vaccinations, totalVAC)
as (Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    sum(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.date) as totalVAC
    from Portfolio..VAC VAC JOIN Portfolio..DEA DEA ON VAC.location = DEA.location and VAC.date = DEA.date
    Where dea.continent is not null)
Select *, (totalVAC/population)*100 as PercentageVaccinated 
FROM PopVaccinated
order by 2, 3

Drop table if exists #�������������������������������
Create table #������������������������������� 
(
Continent nvarchar(255),
Location nvarchar (255),
Date nvarchar (255), 
Population numeric,
New_vaccinations numeric, 
TotalVAC numeric
) 

Insert into #�������������������������������
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.date) as totalVAC
from Portfolio..VAC VAC JOIN Portfolio..DEA DEA ON VAC.location = DEA.location and VAC.date = DEA.date
Where dea.continent is not null

Select *, (totalVAC/population)*100 as PercentageVaccinated 
FROM #�������������������������������
order by 2, 3



Create View ������������������������������� as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.date) as totalVAC
from Portfolio..VAC VAC JOIN Portfolio..DEA DEA ON VAC.location = DEA.location and VAC.date = DEA.date
Where dea.continent is not null
order by 2,3 


Select * FROM ������������������������������� order by 2, 3 