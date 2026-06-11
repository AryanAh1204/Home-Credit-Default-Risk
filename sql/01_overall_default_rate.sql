select
	count(*) as total_applicants,
	sum(target) as total_defaults,
	round(avg(target)*100,2) as default_rate
from application_train t 
