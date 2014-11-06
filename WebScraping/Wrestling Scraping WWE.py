import requests
from BeautifulSoup import BeautifulSoup
import pandas as pd

nums = range(1,301)

def scrapeUFOSightings(i):
    url = "http://www.profightdb.com/cards/wwe-cards-pg%s-no-2.html" % i
    response = requests.get(url)
    soup = BeautifulSoup(response.text)
    table = soup.findAll('tbody')
    values = []
    for row in soup.findAll('tr'):
        cells = row.findAll('td')
        if len(cells) > 2:
            dt = cells[0].find(text=True)
            cardName = "http://www.profightdb.com%s" % cells[2].find('a')['href']
            city = cells[3].findAll('a')[0].contents[0]
            try:
                state = cells[3].findAll('a')[1].contents[0]
            except:
                state = NaN
            values.append([dt, cardName, city, state])
    df = pd.DataFrame(values)
    return df

df = pd.DataFrame()
for n in nums:
    df = df.append(scrapeUFOSightings(n))

df.to_csv('wwecards.tsv', sep='\t')