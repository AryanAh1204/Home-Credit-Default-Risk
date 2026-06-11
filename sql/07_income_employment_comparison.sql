select 
    name_income_type,
    round(avg(amt_income_total), 2) as avg_income,
    round(avg(days_employed), 2) as avg_days_employed
from application_train
group by 1
order by 2 desc;
