--Covid 19 Data Exploration 
--Skill yang digunakan : Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


--Buka file hasil import dari Excel
Select *
From PortofolioProject1..CovidDeaths
Where continent is not null
Order by 3,4

-- Pilih data yang akan diolah
select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject1..CovidDeaths
order by 1,2


-- Membandingkan total kasus dengan total kematian
-- Menunjukkan probabilitas kematian akibat COVID19 di Indonesia
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortofolioProject1..CovidDeaths
where location like 'Indonesia' and continent is not null
order by 1,2

-- Membandingkan total kasus dengan populasi
-- Menunjukkan persentase populasi yang terpapar COVID19 di Indonesia
select location, date, population,total_cases,(total_cases/population)*100 as Case_Percentage
from PortofolioProject1..CovidDeaths
where location like 'Indonesia'
order by 1,2

-- Melihat perbandingan negara - negara dengan laju infeksi tinggi terhadap populasi
select Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
from PortofolioProject1..CovidDeaths
group by Location, Population
order by Percent_Population_Infected desc

-- Menunjukkan negara - negara dengan angka kematian tertinggi per populasi
select Location, MAX(CAST(total_deaths as INT)) as Total_Death_Count
from PortofolioProject1..CovidDeaths
where continent is not null
group by Location
order by Total_Death_Count desc

-- Breakdown kasus per benua
-- Menunjukkan benua dengan angka kematian tertinggi
select location, MAX(CAST(total_deaths as INT)) as Total_Death_Count
from PortofolioProject1..CovidDeaths
where continent is null
group by location
order by Total_Death_Count desc

-- Angka global
select SUM(new_cases) as Total_Cases,SUM(CAST(new_deaths as INT)) as Total_Deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as Death_Percentage
from PortofolioProject1..CovidDeaths
--where location like 'Indonesia' 
where continent is not null
--group by date
order by 1,2 

-- Menggunakan CTE
with Pop_VS_Vac(Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
 as
 (
--Looking at Total Population VS Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated 
--(Rolling_People_Vaccinated/population)*100
from PortofolioProject1..CovidDeaths dea
join PortofolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

Select *, (Rolling_People_Vaccinated/Population)*100
From Pop_VS_Vac


-- Menerapkan TEMP TABLE

Drop Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(Continent nvarchar(255), 
location nvarchar(255), 
date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric)

Insert into #Percent_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated 
--(Rolling_People_Vaccinated/population)*100
from PortofolioProject1..CovidDeaths dea
join PortofolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3


Select *, (Rolling_People_Vaccinated/Population)*100
From #Percent_Population_Vaccinated


-- Menerapkan Creating View untuk menyimpan data guna keperluan visualisasi berikutnya
Create View Percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated 
--(Rolling_People_Vaccinated/population)*100
from PortofolioProject1..CovidDeaths dea
join PortofolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select *
From Percent_Population_Vaccinated