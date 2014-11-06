import requests
from BeautifulSoup import BeautifulSoup
import pandas as pd

cards = pd.read_csv('wwfcards.tsv', sep='\t')
cards.columns = ['num','dt','url', 'city', 'state']

def scrapeUFOSightings(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text)
    table = soup.findAll('table')
    urls = []
    for row in soup.findAll('tr'):
        cells = row.findAll('td')
        #For each "tr", assign each "td" to a variable.
        if len(cells) > 6:
            try: win_url = "http://www.profightdb.com%s" % cells[01].find('a')['href']
            except: win_url = ''
            try: lose_url = "http://www.profightdb.com%s" % cells[03].find('a')['href']
            except: lose_url = ''
            print win_url
            print lose_url
            urls.append([win_url, lose_url])
    df = pd.DataFrame(urls)
    return df
#
df = pd.DataFrame()
for index, row in cards.iterrows():
    df = df.append(scrapeUFOSightings(row['url']))

df.to_csv('wwf_wrestler_urls.tsv', sep='\t')
    
    