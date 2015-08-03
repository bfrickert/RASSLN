LOAD CSV WITH HEADERS FROM "file:c:/users/bfrickert/documents/github/rassln/data/wrestlers.csv" AS row CREATE (n:Wrestler) SET n = row, n.wrestler.id = toInt(row.id), n.name = row.name;

CREATE INDEX ON :Wrestler(`wrestler.id`);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:c:/users/bfrickert/documents/github/rassln/data/evt.win.lose.csv" AS csvLine
MERGE (winner:Wrestler { `wrestler.id`: csvLine.`winner.id` })
MERGE (loser:Wrestler { `wrestler.id`: csvLine.`loser.id` })
CREATE (winner)-[:Beat { date: csvLine.date }]->(loser);

match w-[r]-l where w.name = 'Hulk Hogan' and l.name in ['Paul Orndorff', 'Don Muraco'] return w,r,l;
