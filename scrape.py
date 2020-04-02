from bs4 import BeautifulSoup
import requests
import pandas as pd
import sys

URL = sys.argv[1]
output = "out.csv"
page = requests.get(URL)

names = []
organisations = []
projects = []

soup = BeautifulSoup(page.content, 'html.parser')
for a in soup.findAll('md-card'):
    name=a.find('h4')
    project=a.find('h4').find_next_sibling("div")
    org=a.find('h4').find_next_sibling("div").find_next_sibling("div")
    names.append(name.text.strip())
    projects.append(project.text.strip())
    organisations.append(org.text.strip().replace('Organization: ', '')) 


df = pd.DataFrame({'Name':names,'Project':projects,'Organisation':organisations}) 
df.to_csv(output, index=False, encoding='utf-8')