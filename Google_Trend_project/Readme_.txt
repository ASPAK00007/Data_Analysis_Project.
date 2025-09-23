Google Trends Analysis using Pytrends
Project Overview

This project demonstrates how to analyze search trends using Google Trends data with Python. The main objective is to explore global interest in technology-related keywords, visualize trends over time, and compare the popularity of multiple keywords.

Key Highlights:

Analyze keyword search trends over the last 12 months.

Visualize country-wise interest using bar charts and world maps.

Track time-wise interest trends.

Compare multiple keywords for insights into relative popularity.

Libraries Used

pandas – for data manipulation

numpy – for numerical operations

matplotlib & seaborn – for static visualizations

plotly.express – for interactive maps

pytrends – to fetch Google Trends data

Installation:

pip install pandas numpy matplotlib seaborn plotly pytrends

How It Works
1. Setup Pytrends
from pytrends.request import TrendReq
pytrends = TrendReq(hl='en-us', tz=360)


hl → language (e.g., 'en-us')

tz → timezone offset in minutes

2. Keyword Selection
keyword = "cloud computing"


Keywords define what you want to analyze on Google Trends.

Can also compare multiple keywords:

kw_list = ["Cloud Computing", "AWS", "Azure", "Google Cloud", "Kubernetes"]

3. Build Payload
pytrends.build_payload([keyword], cat=0, timeframe='today 12-m', geo='', gprop='')


cat=0 → all categories

timeframe='today 12-m' → last 12 months

geo='' → worldwide (use 'in' for India, 'us' for USA)

gprop='' → Google property (e.g., 'youtube', 'news')

4. Country-wise Interest
region_data = pytrends.interest_by_region()
region_data = region_data.sort_values(by=keyword, ascending=False).head(15)

sns.barplot(x=region_data[keyword], y=region_data.index, palette="Blues_d")


Visualizes the top countries searching for a keyword.

Can also create a world map using Plotly:

fig = px.choropleth(region_data.reset_index(),
                    locations='geoName',
                    locationmode='country names',
                    color=keyword,
                    color_continuous_scale='Blues')
fig.show()

5. Time-wise Interest
time_df = pytrends.interest_over_time()
plt.plot(time_df.index, time_df[keyword])


Shows how interest evolves over time.

6. Compare Multiple Keywords
pytrends.build_payload(kw_list, cat=0, timeframe='today 12-m', geo='', gprop='')
compare_df = pytrends.interest_over_time()

for kw in kw_list:
    plt.plot(compare_df.index, compare_df[kw], label=kw)
Allows tracking relative popularity of multiple keywords.

USE LIBARY FOR GOOD RESULT'
