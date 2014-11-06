use ncarbdw
go

select wwe.match_date, wwe.winner, wwe.outcome, wwe.loser, wwe.duration, wstar.Finisher winner_finisher, wstar.Moves winner_moves, lstar.Finisher loser_finisher, lstar.Moves loser_moves 
from	(select a.*, CAST(year + '-' + month + '-' + day AS DATE) match_date from (
select	wwe.*, SUBSTRING(wwe.date, len(wwe.date) - 3, 4) year, SUBSTRING(wwe.date, 1,3) month, 
		replace(replace(replace(replace(SUBSTRING(wwe.date, 5, 2), 't', ''), 'n',''), 'r', ''), 's', '') day
from wwe 
  ) a
  where a.year < 1985) wwe
join	stars wstar on wstar.Name = wwe.winner
join	stars lstar on lstar.Name = wwe.Loser;

select * from wwf79
where winner_finisher is not null or winner_moves is not null;

select * from stars;