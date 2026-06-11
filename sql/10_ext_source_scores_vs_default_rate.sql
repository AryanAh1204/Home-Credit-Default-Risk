select 
	case
		when t.ext_source_1 < 0.25 then 'Q1 (Lowest)'
		when t.ext_source_1 < 0.50 then 'Q2'
		when t.ext_source_1 < 0.75 then 'Q3'
	else 'Q4 (Highest)'
	end as ext_source_1_bucket,
	count(*) as total_applicants,
	sum(target) as total_defaults,
	round(avg(target)*100,2) as default_rate
from application_train t
where t.ext_source_1 is not null
group by 1
order by 4 desc

select 
	case
		when t.ext_source_2 < 0.25 then 'Q1 (Lowest)'
		when t.ext_source_2 < 0.50 then 'Q2'
		when t.ext_source_2 < 0.75 then 'Q3'
	else 'Q4 (Highest)'
	end as ext_source_2_bucket,
	count(*) as total_applicants,
	sum(target) as total_defaults,
	round(avg(target)*100,2) as default_rate
from application_train t
where t.ext_source_2 is not null
group by 1
order by 4 desc

select 
	case
		when t.ext_source_3 < 0.25 then 'Q1 (Lowest)'
		when t.ext_source_3 < 0.50 then 'Q2'
		when t.ext_source_3 < 0.75 then 'Q3'
	else 'Q4 (Highest)'
	end as ext_source_3_bucket,
	count(*) as total_applicants,
	sum(target) as total_defaults,
	round(avg(target)*100,2) as default_rate
from application_train t
where t.ext_source_3 is not null
group by 1
order by 4 desc
