 copy brian.wwe_full from 's3://ncarb-dsteam/RASSLN/full.tsv'
 credentials 'aws_access_key_id=[access key];aws_secret_access_key=[secret]'
 delimiter '\t'
 ignoreheader as 1
 dateformat 'YYYY-MM-DD'
 removequotes
 ACCEPTINVCHARS
 ;
drop table brian.wwe_full;
create table brian.wwe_full (
winner_id int,
loser_id int,
evt_id int,
dt date,
winner_name varchar(100),
winner_wgt int,
winner_hgt float,
winner_trademark_moves varchar(500),
winner_finishers varchar(500),
loser_name varchar(100),
loser_wgt int,
loser_hgt float,
loser_trademark_moves varchar(1000),
loser_finishers varchar(500));

