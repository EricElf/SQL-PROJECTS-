-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns

Create Table layoffs_staging
Like layoffs;

Select *
From layoffs_staging

Insert layoffs_staging
Select *
From layoffs;


-- Removing duplicates
With duplicates as
(Select *,
Row_number() Over
(Partition By company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_numb
From layoffs_staging)
Select *
From duplicates
Where row_numb > 1

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_numb` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Insert into layoffs_staging2
Select *,
Row_number() Over
(Partition By company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_numb
From layoffs_staging

Delete
From layoffs_staging2
Where row_numb > 1

-- Standardizing Data

-- Removing the extra spaces
Update layoffs_staging2
Set company = TRIM(company);

Select Distinct(industry)
From layoffs_staging2
Order by 1

-- Removing redundant Crypto industry
Update layoffs_staging2
Set industry = 'Crypto'
Where industry like 'Crypto%'

-- United States had a 2nd categories (United States and United States.) - removed the period at the end of the 2nd one. 
Select Distinct(Country), Trim(Trailing '.' From country)
From layoffs_staging2
Order by 1

Update layoffs_staging2
Set country = Trim(Trailing '.' From country)
Where country like 'United States%';

-- Fixing Date column from Text to Date
Select `date`,
str_to_date(`date`, '%m/%d/%Y')
From layoffs_staging2

Update layoffs_staging2
Set `date` = str_to_date(`date`, '%m/%d/%Y')

Alter Table layoffs_staging2
Modify column `date` Date;

-- Populating Null values
Select *
From layoffs_staging2
Where industry is Null
or industry = ' ';

Select *
From layoffs_staging2
Where company = 'Airbnb';

Select *
From layoffs_staging2 t1
Join layoffs_staging2 t2
	On t1.company = t2.company
	And t1.location = t2.location
Where (t1.industry is null or t1.industry = '')
And t2.industry is not null

Update layoffs_staging2
Set industry = null
Where industry = '';


Update layoffs_staging2 t1
Join layoffs_staging2 t2
	On t1.company = t2.company
Set t1.industry = t2.industry
Where t1.industry is null
And t2.industry is not null;


-- Deleting Nulls in total_laid_off & percentage_laid_off
Delete
From layoffs_staging2
Where percentage_laid_off is null
And total_laid_off is null;

-- Removing Row Number column
Alter table layoffs_staging2
Drop column row_numb