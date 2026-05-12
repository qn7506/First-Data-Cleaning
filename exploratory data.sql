-- Exploraty Data Analysis

SELECT * 
FROM layoffs_staging2; -- Look at everything

SELECT MIN(`date`) as Start_date, MAX(`date`) as End_date
FROM layoffs_staging2;  -- Started around when the pandemic first hit the US and end at least 3 years later

SELECT MAX(total_laid_off) as max_laid_off, MAX(percentage_laid_off) as max_percentage -- What is the most laid off number and percentage of laidoff?
FROM layoffs_staging2;

select *
from layoffs_staging2
where total_laid_off = 
(SELECT MAX(total_laid_off) as max_laid_off 
FROM layoffs_staging2);

select *
from layoffs_staging2
where percentage_laid_off = 
(SELECT MAX(percentage_laid_off) as max_percentage 
FROM layoffs_staging2)
ORDER BY funds_raised_millions DESC;

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC; -- Who has the percentage laidoff is 1 and has the most raised funds?

SELECT company, SUM(total_laid_off) as total_laid_off, location, country
FROM layoffs_staging2
GROUP BY company, location, country
ORDER BY 2 DESC;  -- What company has the most laid off?

SELECT country, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC
LIMIT 10; -- What industry has the most laid off?

SELECT YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1  DESC; -- What laid off number each year has? 2023 only record 3 months but already adds up to 125k

-- ROLLING SUM OF LAY OFF
WITH Rolling_total AS
(
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) is NOT NULL 
GROUP BY `month`
ORDER BY 1
)
SELECT `month`, total_off,
SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_total;

WITH company_year(company, years, total_laid_off, industry) AS
(
SELECT company, YEAR(`date`),  SUM(total_laid_off), industry
FROM layoffs_staging2
GROUP BY company,YEAR(`date`), industry
), company_rank AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking_laid_off
FROM company_year
WHERE years IS NOT NULL)
SELECT * 
FROM company_rank
WHERE ranking_laid_off <= 5;