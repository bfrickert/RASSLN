use NCARBDW
go


select a.*, CAST(year + '-' + month + '-' + day AS DATE) match_date from (
select	wwe.*, SUBSTRING(wwe.date, len(wwe.date) - 3, 4) year, SUBSTRING(wwe.date, 1,3) month, 
		replace(replace(replace(replace(SUBSTRING(wwe.date, 5, 2), 't', ''), 'n',''), 'r', ''), 's', '') day
from wwe 
  ) a
  where a.year < 1985;

select	distinct winner
from	wwe
where	SUBSTRING(wwe.date, len(wwe.date) - 3, 4) < 1985
union
select	distinct loser
from	wwe
where	SUBSTRING(wwe.date, len(wwe.date) - 3, 4) < 1985;

select * from stars where finisher = 'Prison Lock'

