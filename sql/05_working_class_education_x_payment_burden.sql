select
	t.name_education_type ,
	case
    	when amt_annuity / amt_income_total < 0.1 then 'Low burden (<10%)'
    	when amt_annuity / amt_income_total < 0.2 then 'Moderate (10-20%)'
    	when amt_annuity / amt_income_total < 0.3 then 'High (20-30%)'
    else 'Severe (>30%)'
    end as payment_burden_bucket,
    count(*) as total_applicants,
  	round(AVG(target)*100, 2) as default_rate
from application_train t 
where amt_income_total > 0 and t.name_income_type = 'Working'
group by 1 , 2
order by 4 desc;
