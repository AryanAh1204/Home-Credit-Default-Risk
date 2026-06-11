select
	case 
		when days_birth/365 > -20 then 'Teenage'
		when days_birth/365 > -30 then 'Young'
		when days_birth/365 > -60 then 'Adult'
		else 'Senior Citizen'
	end as age,
	case
    	when amt_annuity / amt_income_total < 0.1 then 'Low burden (<10%)'
    	when amt_annuity / amt_income_total < 0.2 then 'Moderate (10-20%)'
    	when amt_annuity / amt_income_total < 0.3 then 'High (20-30%)'
    else 'Severe (>30%)'
    end as payment_burden_bucket,
    count(*) as total_applicants,
    sum(target) as total_defaults,
    round(avg(target)*100,2) as default_rate
from application_train t
group by 1,2
order by 5 desc;
