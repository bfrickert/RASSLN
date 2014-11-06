import requests
from BeautifulSoup import BeautifulSoup
import pandas as pd

cards = pd.read_csv('wwfcards.tsv', sep='\t')
cards.columns = ['num','dt','url', 'city', 'state']

def scrapeUFOSightings(url, dt, city, state):
    response = requests.get(url)
    soup = BeautifulSoup(response.text)
    table = soup.findAll('table')
    values = []
    for row in soup.findAll('tr'):
        cells = row.findAll('td')
        #For each "tr", assign each "td" to a variable.
        if len(cells) > 6:
            winner = cells[01].find(text=True)
            outcome = cells[2].find(text=True)
            loser = cells[3].find(text=True)
            Duration = cells[4].find(text=True)
            MatchType = cells[5].find(text=True)
            values.append([winner, outcome, loser, Duration, MatchType, dt])
    df = pd.DataFrame(values)
    return df

df = pd.DataFrame()
for index, row in cards.iterrows():
    df = df.append(scrapeUFOSightings(row['url'], row['dt'], row['city'], row['state']))

df.columns = ['winner', 'outcome', 'loser', 'duration', 'matchtype', 'date', 'city', 'state']
df.to_csv('wwfbouts.tsv', sep='\t')