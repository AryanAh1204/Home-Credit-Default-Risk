select
	t.name_income_type ,
	count(*) as total_applicants,
	sum(target) as total_defaults,
	round(avg(target)*100,2) as default_rate
from application_train t 
group by 1
order by 4 desc
