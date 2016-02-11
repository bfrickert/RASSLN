#RASSLN
Culls WWE data from WrestlingData.com into a final tab-delimited file that holds match data for each bout. Including the opponents, their weights and heights, and trademark moves!

1. Run the code in `WebScraping/scrape_wwe_years.R`
  * It finds all the links for each year's WWE events and writes them to a tab-delimited file (`data/year_urls.tsv`).
2. Run the code in `WebScraping/scrape_wwe_event_links.R`
  * It reads `data/year_urls.tsv` and culls and writes a file (`data/event.links.tsv`) comprised of links to each WWE event on record.
3. Run the code in `WebScraping/scrape_wwe_locations.R`
  * It reads `data/event.links.tsv` and collects all the location data for each WWE event and writes another tab-delimited file (event_locations.tsv).
4. Run the code in `WebScraping/scrape_wwe_bouts.R`
  * It reads `data/event.links.tsv` and `data/event_locations.tsv` and writes a file called `data/bouts.tsv`. In this foul is an id for the wrestlers involved in the bout and an id for the location of the bout.
5. Run the code in `winners_losers.R`
  * It reads `data/bouts.tsv` and writes who won each match to `data/winners_losers.tsv`.
6. Run the code in `WebScrpaing\scrape_wwe_biographies.R`
  * It reads `data/winners_losers.tsv` and writes `data/bio.tsv` in which information about each individual wrestler involved in each of the WWE bouts is written.
7. Run the code in `evt.win.lose.R`
  * It reads from `data/bio.tsv`, `data/event.locations.tsv` and `data/winners_losers.tsv` to create the file `data/full.tsv`.
8. THAT was it!
