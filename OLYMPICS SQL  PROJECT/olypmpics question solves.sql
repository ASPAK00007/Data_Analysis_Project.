create database Olympic;

use Olympic;

CREATE TABLE athlete_events (
    id          INT,
    name        VARCHAR(100),
    sex         VARCHAR(10),
    age         VARCHAR(10),
    height      VARCHAR(10),
    weight      VARCHAR(10),
    team        VARCHAR(100),
    noc         VARCHAR(10),
    games       VARCHAR(50),
    year        INT,
    season      VARCHAR(10),
    city        VARCHAR(50),
    sport       VARCHAR(50),
    event       VARCHAR(100),
    medal       VARCHAR(20)
);



CREATE TABLE noc_regions (
    noc     VARCHAR(10),
    region  VARCHAR(100),
    notes   VARCHAR(255)
);



select * from athlete_events ;
select * from noc_regions ;

SELECT COUNT(*) from  athlete_events;
SELECT count(*) FROM noc_regions;


-- ✅ List of 20 Olympic SQL Queries


-- Q1. How many Olympics games have been held?

select count(games)
from athlete_events;

-- Q2. List down all Olympics games held so far.(Usually includes Year, Season, City.)

select games,sport,year,season,city
from athlete_events
order by year ,season;

-- Q3. Mention the total number of nations who participated in each Olympic game.

select games, count(distinct noc) as total_partipation
from  athlete_events
group by games
order by games ;

-- Q4. Which year saw the highest and lowest number of countries participating in the Olympics?

with participation as (
select games,year,count(distinct noc) as nation_count
from athlete_events
group by games, year
)
select *
from participation
where nation_count =(select max(nation_count) from participation)
or nation_count =(select min(nation_count) from participation) ;


-- Q5. Which nation has participated in all of the Olympic games? -- 

with games_ctes as (
select count(distinct games) as total_games
from athlete_events
),
nation_games as (
select noc,count(distinct games) as games_played
from athlete_events
group by noc
)
select n.noc,r.region
from nation_games n
join games_ctes g on n.games_played = g.total_games
join noc_regions r on r.noc=n.noc;





-- Q6. Identify the sport which was played in all Summer Olympics.

with summer_games as(
select count(distinct games ) as total_summer_games
from athlete_events
where season = 'summer'
),

sports_in_summer as(
select sport,count(distinct games) as sport_games
from athlete_events
where season = 'summer'
group by sport
)
select sport
from summer_games, sports_in_summer
where sport_games = total_summer_games;


-- Q7.Which sports were played only once in the Olympics? 

select sport,count(distinct games) as games_played
from athlete_events
group by sport
having count(distinct games) = 1;

-- Q8. Fetch the total number of sports played in each Olympic game.

select year,count(distinct sport) as no_sport_played
from athlete_events
group by year
order by year desc;

-- Q9. Fetch details of the oldest athletes to win a gold medal.

select name,age,sport,event,team,medal
from athlete_events
where medal = 'gold' and  age != 'NA' 
order by age desc
limit 1 ;

-- Q10. Find the ratio of male and female athletes who participated in all Olympic games

SELECT 
sum(CASE WHEN SEX='M' THEN 1 ELSE 0 END) AS MALE_athlete,
sum(CASE WHEN SEX='f' THEN 1 ELSE 0 END) AS FEMALE_athlete,
round(sum(CASE WHEN SEX='M' THEN 1 ELSE 0 END) / sum(CASE WHEN SEX='f' THEN 1 ELSE 0 END),2) as male_to_female_ratio
from(
select distinct id,sex
from athlete_events
) as unique_id;


-- Q11.  Fetch the top 5 athletes who have won the most gold medals.

select name,count(medal) as total_medal
from athlete_events
where medal = 'Gold'
group by  name
order by total_medal desc
limit 5 ;


-- Q12. 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

select name, team,count(*) as total_medal
from athlete_events
where medal in ('Gold','Silver','Bronze')
group by name,team
order by total_medal desc
limit 5;

-- Q13. Fetch the top 5 most successful countries in Olympics (by total medals won).

select r.region as country, count(*) as total_medal
from athlete_events a
join noc_regions r on a.noc = r.noc
where medal is  not null
group by r.region
order by total_medal desc
limit 5 ; 


-- Q14. List down total gold, silver, and bronze medals won by each country.

select r.region as country,
count(case when medal = 'Gold' then 1 end) as gold,
count(case when medal = 'Silver' then 1 end) as Silver,
count(case when medal = 'Bronze' then 1 end) as Bronze
from athlete_events  a
join noc_regions r on a.noc = r.noc
where medal is not null
group by r.region
order by gold desc,silver desc,bronze desc;

-- Q15. List total gold, silver, bronze medals won by each country for each Olympic game.

select r.region as country,
count(case when medal = 'Gold' then 1 end) as gold,
count(case when medal = 'Silver' then 1 end) as Silver,
count(case when medal = 'Bronze' then 1 end) as Bronze
from athlete_events a
join noc_regions r on a.noc =r.noc
where medal is not null
group by r.region,a.games
order by a.games, gold desc;

-- Q16. Identify which country won the most gold, silver, and bronze medals in each Olympic game.

WITH medal_counts AS (
  SELECT Games, r.region AS country,
    COUNT(CASE WHEN Medal = 'Gold' THEN 1 END) AS Gold,
    COUNT(CASE WHEN Medal = 'Silver' THEN 1 END) AS Silver,
    COUNT(CASE WHEN Medal = 'Bronze' THEN 1 END) AS Bronze
    from athlete_events a
    join noc_regions r on a.noc = r.noc
    where medal is not null
    group by games,r.region),
    
    ranked as(
select *,
rank() over(partition by games order by gold desc) as Gold_rank,
rank() over(partition by games order by Silver desc) as Silver_rank,
rank() over(partition by games order by Bronze desc ) as Bronze_rank
from medal_counts
)
select games, country,Gold,Silver,Bronze
from ranked
where Gold_rank = 1 or Silver_rank = 1 or Bronze_rank = 1;



-- Q17. Identify which country won the most gold, most silver, most bronze, and most total medals in each Olympic game.

WITH medal_per_games AS (
SELECT Games, r.region AS country,
COUNT(CASE WHEN Medal = 'Gold' THEN 1 END) AS Gold,
COUNT(CASE WHEN Medal = 'Silver' THEN 1 END) AS Silver,
COUNT(CASE WHEN Medal = 'Bronze' THEN 1 END) AS Bronze,
count(*) as total_medals
from athlete_events a
join noc_regions r on a.noc = r.noc
where medal is not null
group by games,r.region
),

ranked as(
select *,
rank() over(partition by games order by gold desc) as Gold_rank,
rank() over(partition by games order by Silver desc) as Silver_rank,
rank() over(partition by games order by Bronze desc) as Bronze_rank,
rank() over(partition by games order by total_medals desc) as total_rank
from medal_per_games
)
select games, country,Gold,Silver,Bronze,total_medals
from ranked
where Gold_rank = 1 or Silver_rank = 1 or Bronze_rank = 1 or total_rank = 1;



-- Q18. Which countries have never won gold but have won silver/bronze medals?

WITH medal_summary AS (
SELECT r.region AS country,
count(CASE WHEN Medal = 'Gold' THEN 1 END) AS Gold,
count(CASE WHEN Medal = 'Silver' THEN 1 END) AS Silver,
count(CASE WHEN Medal = 'Bronze' THEN 1 END) AS Bronze
from athlete_events a
join noc_regions r on a.noc = r.noc
where medal is not null
group by r.region
)
select country, Silver, Bronze
from medal_summary
where Gold = 0 and (Silver > 0 or Bronze > 0) ;


-- Q19. In which sport/event has India won the highest number of medals?


select sport,event, count(*) as total_medals
from athlete_events a
join noc_regions r on a.noc = r.noc
where medal is not null
group by sport,event
order by total_medals desc ;

-- Q20. Break down all Olympic games where India won a medal for Hockey and how many medals in each

select games, count(*) as hockey_medal
from athlete_events a
join noc_regions r on a.noc = r.noc
where r.region = 'India'  AND SPORT = 'Hockey' AND medal is not null
group by games
order by games ;







