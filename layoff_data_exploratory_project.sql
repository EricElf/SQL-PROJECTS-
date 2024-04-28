-- Layoff project Part 2 - Exploratory Data Analysis

-- Timeframe of the layoffs
Select Min(date), Max(date)
From layoffs_staging2

-- Day with the most layoffs 
Select date, max(total_laid_off) as totes
From layoffs_staging2
Group by date
Order by totes desc

-- Locations with the most layoffs
Select Count(location) as count, location
From layoffs_staging2
Group by location
Order by count desc

-- The most people laid off by a company at one time
Select Max(total_laid_off)
From layoffs_staging2

-- The avg percentage of workforce laid off
Select Round(Avg(percentage_laid_off),2)
From layoffs_staging2

-- The highest percentage of people being laid off. 1 equals 100%
Select Max(percentage_laid_off)
From layoffs_staging2

-- Companies that laid off everyone ordered by the amount of people laid off
Select *
From layoffs_staging2
Where percentage_laid_off = 1
order by total_laid_off desc;

-- Company layoffs
Select company, sum(total_laid_off) as total
From layoffs_staging2
Group by company
Order by total desc;

-- Industries most impacted
Select industry, sum(total_laid_off) as total
From layoffs_staging2
Group by industry
Order by total desc;

-- Countries most impacted
Select Country, sum(total_laid_off) as total
From layoffs_staging2
Group by Country
Order by total desc;

-- impact of funds raised on layoff percentage
Select year(date), sum(total_laid_off), sum(funds_raised_millions)
From layoffs_staging2
group by year(date)
order by year(date) asc

-- Layoffs Broken down by years
Select Year(date), sum(total_laid_off) as total
From layoffs_staging2
Group by Year(date)
Order by Year(date)

-- Breakdown by stage
Select Stage, sum(total_laid_off) as total
From layoffs_staging2
Group by stage
order by total desc

-- Grouping by month and year plus getting rid of null values
Select substring(date,1,7) as month, sum(total_laid_off) as total
From layoffs_staging2
Where substring(date,1,7) is not null
Group by month
Order by month desc

-- Rolling total of layoffs with monthly comparison
With rolling_total as
(
Select substring(date,1,7) as month, sum(total_laid_off) as total_l
From layoffs_staging2
Where substring(date,1,7) is not null
Group by month
Order by month desc
)
Select Month, total_l, sum(total_l) over(order by month) as rolling_totes
From rolling_total 

-- Company layoffs by year
Select company, Year(date), sum(total_laid_off) as total
From layoffs_staging2
Group by company, year(date)
Order by total Desc

-- Company layoffs ranked (Top 5) over the years
With company_year (company, years, total) as
(Select company, Year(date), sum(total_laid_off) as total
From layoffs_staging2
Group by company, year(date)
),
company_year_rank as 
(Select *, dense_rank() over(partition by years order by total desc) as layoff_rank
From company_year
Where years is not null)
Select *
From company_year_rank
Where layoff_rank <= 5;

-- Industry layoffs by year
Select industry, year(date), sum(total_laid_off) as total
From layoffs_staging2
Where year(date) is not null
Group by industry, year(date)
Order by year(date) asc;

-- Industry layoffs ranked (Top 5) over the years
With industry_lay (industry, years, total) as
(
Select industry, year(date), sum(total_laid_off) as total
From layoffs_staging2
Where year(date) is not null
Group by industry, year(date)
),
industry_year_rank as 
(Select *,
dense_rank() over(partition by years order by total desc) as industry_rank
From industry_lay
Where years is not null)
Select *
From industry_year_rank
where industry_rank <= 5;

-- Country layoffs by year (USA!! USA!! USA!!)
Select Country, year(date), sum(total_laid_off) as total
From layoffs_staging2
Where year(date) is not null
Group by Country, year(date)
Order by total desc;

-- Country layoffs ranked (Top 5) over the years
With country_lay (country, years, total) as
(Select Country, year(date), sum(total_laid_off) as total
From layoffs_staging2
Where year(date) is not null
Group by Country, year(date)),
country_year_rank as
(Select *,
dense_rank() over(partition by years order by total desc) as country_rank
From country_lay
Where total is not null)
Select *
From country_year_rank
Where country_rank <= 5;

-- Layoffs by Stage of company over years
Select Stage, Year(date), sum(total_laid_off) as total
From layoffs_staging2
group by stage, year(date)
Order by total desc

-- Layoffs by Stage of company ranked (Top 5) over the years
With stage_lay (stage, years, total) as
(
Select Stage, Year(date), sum(total_laid_off) as total
From layoffs_staging2
Where stage is not null
group by stage, year(date)
),
stage_rank as 
(Select *,
dense_rank() over(partition by years order by total desc) rnk
From stage_lay)
Select *
From stage_rank
Where rnk <=5
And years is not null;

