select
  	CASE
    	WHEN amt_annuity / amt_income_total < 0.1 THEN 'Low burden (<10%)'
    	WHEN amt_annuity / amt_income_total < 0.2 THEN 'Moderate (10-20%)'
    	WHEN amt_annuity / amt_income_total < 0.3 THEN 'High (20-30%)'
    ELSE 'Severe (>30%)'
  	END AS payment_burden_bucket,
  	COUNT(*) AS total_applicants,
  	ROUND(AVG(target)*100, 2) AS default_rate
FROM application_train t
WHERE amt_income_total > 0
GROUP BY 1
ORDER BY 3 DESC;
