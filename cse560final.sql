create table matches ( 
id int,
country_id int, 
league_id int, 
season varchar(45), 
stage int, 
date varchar(45), 
match_api_id int, 
home_team_api_id int, 
away_team_api_id int, 
home_team_goal int, 
away_team_goal int 
); 


create table team ( 
id int, 
team_api_id int, 
team_fifa_api_id int, 
team_long_name varchar(200), 
team_short_name varchar(5) 
); 

create table country ( 
id int, 
name varchar(50) 
); 


create table league ( 
id int, 
country_id int, 
name varchar(200) 
); 



--- Primary keys 
alter table country add primary key(id); 
alter table league add primary key(id); 
alter table matches add primary key(match_api_id); 
alter table team add primary key(team_api_id); --- Foreign keys 
alter table league add foreign key(country_id) references country(id); 
alter table matches add foreign key(country_id) references 
country(id); 
alter table matches add foreign key(league_id) references league(id); 
alter table matches add foreign key(home_team_api_id) references 
team(team_api_id); 
alter table matches add foreign key(away_team_api_id) references 
team(team_api_id); 



---We created a smaller dataset using the following queries: 
create view country_limit as 
select * from country limit 5; 
create view league_limit as 
select * from league limit 5; 
create view matches_limit as 
select * from matches limit 5; 
create view team_limit as 
select * from team limit 5;

---check the tables 
select * from country 
limit 5;

select * from league 
limit 5;

select * from matches 
limit 5;

select * from team 
limit 5;


---List leagues and their associated country. 
select country.name as country_name, 
league.name as league_name from country  
join league on country.id=league.country_id;


---Extract country, league_name, season, stage, date, home_team,  away_team,goals, and team 
--names: 
select country.name as country_name,league.id as league_id, 
matches.season as season,matches.stage as stage,matches.date, 
HT.team_long_name as home_team_long_name, 
AT.team_long_name as away_team_long_name from country 
join league on country.id=league.country_id  
join matches on country.id=matches.country_id 
and league.id=matches.league_id 
left join team as HT 
on HT.team_api_id=matches.home_team_api_id 
left join team as AT 
on AT.team_api_id=matches.away_team_api_id; 



 ---Find the number of teams, average home team goals, average away team goals, 
---average goal difference, average total number of goals 
--- sum of the goals made by both the home and away team. 
--- w.r.t country and the league 
select country.name as country_name, 
league.name as league_name, 
count(HT.team_api_id) as no_of_teams, 
avg(matches.home_team_goal) as avg_home_team_goals, 
avg(matches.away_team_goal) as avg_away_team_goals, 
avg(matches.home_team_goal-matches.away_team_goal) as avg_goal_diff, 
avg(matches.home_team_goal+matches.away_team_goal) as avg_tot_goals, 
sum(matches.home_team_goal+matches.away_team_goal) as sum_of_goals 
from country 
join league on country.id=league.country_id 
join matches on matches.country_id=country.id 
and matches.league_id=league.id
left join team HT on HT.team_api_id=matches.home_team_api_id 
left join team AT on AT.team_api_id=matches.away_team_api_id 
group by country.name, league.name;


---Display the average number of goals the home team scored in all matches: 
select home_team_api_id, avg(home_team_goal) as avg_goal from matches 
group by home_team_api_id having avg(home_team_goal)>1;

---Compute the number of home goals a team has scored: 
create view home_team_goal_count as 
select matches.home_team_api_id,  team.team_long_name, 
sum(matches.home_team_goal) as goal_count 
from matches 
join team on 
matches.home_team_api_id=team.team_api_id 
group by matches.home_team_api_id, team.team_long_name 
having sum(matches.home_team_goal)>=2; 
select * from home_team_goal_count; 


---Compute the number of away goals a team has scored: 
create view away_team_goal_count as 
select matches.away_team_api_id,  team.team_long_name, 
sum(matches.away_team_goal) as goal_count 
from matches 
join team on matches.away_team_api_id=team.team_api_id 
group by matches.away_team_api_id, team.team_long_name 
having sum(matches.away_team_goal)>=2; 
select * from away_team_goal_count;

---milestone part2 
---q9 test your database ...
---1 insert a new league 
---INSERT INTO league (id, country_id, name)
---VALUES (101, 1, 'Premier League');
---2 insert a new match 
INSERT INTO matches (id, match_api_id, country_id, league_id, season, stage, date, home_team_api_id, away_team_api_id, home_team_goal, away_team_goal)
VALUES (5001, 600001, 1, 101, '2024/2025', 1, '2024-01-01', 9987, 9993, 3, 2);

---4  delete matches for a specific reason 
DELETE FROM matches
WHERE season = '2024/2025';
---4 update team name 
UPDATE team
SET team_long_name = 'New Genk FC'
WHERE team_api_id = 9987;
---4  update match goals 
UPDATE matches
SET home_team_goal = 5, away_team_goal = 4
WHERE match_api_id = 600001;

----select queris 
---join query -list league and associated countries
SELECT country.name AS country_name, league.name AS league_name
FROM country
JOIN league ON country.id = league.country_id;
---groupby query -avg goals per league 
SELECT league.name AS league_name, AVG(matches.home_team_goal + matches.away_team_goal) AS avg_goals
FROM league
JOIN matches ON league.id = matches.league_id
GROUP BY league.name
ORDER BY avg_goals DESC;

---subquery -teams with high goal difference 
SELECT team_long_name, team_api_id
FROM team
WHERE team_api_id IN (
    SELECT home_team_api_id
    FROM matches
    WHERE home_team_goal - away_team_goal > 3
);

---q9 more sql queries based on q9 
---add a new match 
INSERT INTO matches (id, match_api_id, country_id, league_id, season, stage, date, home_team_api_id, away_team_api_id, home_team_goal, away_team_goal)
VALUES (1001, 600101, 1, 1, '2024/2025', 1, '2024-01-15', 9987, 9993, 2, 1);
---add a new  team 
INSERT INTO team (id, team_api_id, team_fifa_api_id, team_long_name, team_short_name)
VALUES (101, 7777, 5555, 'New Football Club', 'NFC');

---delete matches from a  speicific season 
DELETE FROM matches
WHERE season = '2023/2024';

---delete teams without matches 
DELETE FROM team
WHERE team_api_id NOT IN (
    SELECT home_team_api_id FROM matches
    UNION
    SELECT away_team_api_id FROM matches
);


----update queries 
----update team names 
UPDATE team
SET team_long_name = CONCAT(team_long_name, ' United')
WHERE team_long_name LIKE '%FC%';


----update goals for matches 
UPDATE matches
SET home_team_goal = home_team_goal + 1, away_team_goal = away_team_goal + 1
WHERE date >= '2024-01-01' AND season = '2024/2025';



----select queries 
---- select leagues and their countries 
SELECT country.name AS country_name, league.name AS league_name
FROM country
JOIN league ON country.id = league.country_id
ORDER BY country_name, league_name;


---top 5 matches by total goals 
SELECT match_api_id, home_team_goal, away_team_goal, (home_team_goal + away_team_goal) AS total_goals
FROM matches
ORDER BY total_goals DESC
LIMIT 5;



---- teams with high scoring marks 
SELECT team_long_name, COUNT(*) AS high_scoring_matches
FROM team
JOIN matches ON team.team_api_id = matches.home_team_api_id OR team.team_api_id = matches.away_team_api_id
WHERE home_team_goal + away_team_goal > 5
GROUP BY team_long_name
HAVING COUNT(*) > 2
ORDER BY high_scoring_matches DESC;


---matches with league and country details 
SELECT country.name AS country_name, league.name AS league_name, matches.match_api_id, matches.date
FROM matches
JOIN league ON matches.league_id = league.id
JOIN country ON matches.country_id = country.id
WHERE matches.season = '2024/2025'
ORDER BY matches.date ASC;


----subquery tem with the most matches played 
SELECT team_long_name, total_matches
FROM (
    SELECT team_long_name, 
           (COUNT(home_matches.home_team_api_id) + COUNT(away_matches.away_team_api_id)) AS total_matches
    FROM team
    LEFT JOIN matches AS home_matches ON team.team_api_id = home_matches.home_team_api_id
    LEFT JOIN matches AS away_matches ON team.team_api_id = away_matches.away_team_api_id
    GROUP BY team_long_name
) AS team_match_counts
ORDER BY total_matches DESC
LIMIT 5;

---most frequent winning team 
SELECT team_long_name, COUNT(*) AS wins
FROM team
JOIN matches ON team.team_api_id = matches.home_team_api_id AND matches.home_team_goal > matches.away_team_goal
GROUP BY team_long_name
ORDER BY wins DESC
LIMIT 5;


---league with most goals scored 
SELECT league.name AS league_name, SUM(home_team_goal + away_team_goal) AS total_goals
FROM league
JOIN matches ON league.id = matches.league_id
GROUP BY league.name
ORDER BY total_goals DESC
LIMIT 1;







---q10 query 1 
SELECT league.name AS league_name, AVG(matches.home_team_goal + matches.away_team_goal) AS avg_goals
FROM league
JOIN matches ON league.id = matches.league_id
GROUP BY league.name;


---solution 
--add an index 
CREATE INDEX idx_matches_league_id ON matches(league_id);

---q10 more queries continuted 

----original query  - team with high scoring matches 
SELECT team_long_name, COUNT(*) AS high_scoring_matches
FROM team
JOIN matches ON team.team_api_id = matches.home_team_api_id OR team.team_api_id = matches.away_team_api_id
WHERE home_team_goal + away_team_goal > 5
GROUP BY team_long_name
HAVING COUNT(*) > 2
ORDER BY high_scoring_matches DESC;


---Performance Issues
---Expensive OR condition: The join condition uses OR, which prevents efficient use of indexes.
---Aggregate computation: The COUNT(*) and HAVING clause add computational overhead.
----Full table scan: Without indexes, the database performs a sequential scan on both team and matches.




----solution - optimization 
---create indexes 
CREATE INDEX idx_matches_total_goals ON matches ((home_team_goal + away_team_goal));
CREATE INDEX idx_matches_home_team_api_id ON matches (home_team_api_id);
CREATE INDEX idx_matches_away_team_api_id ON matches (away_team_api_id);


----Restructure the query to split the OR condition into two UNION queries
SELECT team_long_name, COUNT(*) AS high_scoring_matches
FROM (
    SELECT team.team_long_name
    FROM team
    JOIN matches ON team.team_api_id = matches.home_team_api_id
    WHERE matches.home_team_goal + matches.away_team_goal > 5
    UNION ALL
    SELECT team.team_long_name
    FROM team
    JOIN matches ON team.team_api_id = matches.away_team_api_id
    WHERE matches.home_team_goal + matches.away_team_goal > 5
) AS high_scoring_teams
GROUP BY team_long_name
HAVING COUNT(*) > 2
ORDER BY high_scoring_matches DESC;



----query league with most goals scored 
---original query 
SELECT league.name AS league_name, SUM(home_team_goal + away_team_goal) AS total_goals
FROM league
JOIN matches ON league.id = matches.league_id
GROUP BY league.name
ORDER BY total_goals DESC
LIMIT 1;


---Performance Issues
----Aggregate on large dataset: SUM and GROUP BY over the matches table can be costly.
---Full table scan: Without an index on league_id or the calculated total goals, a sequential scan is likely.

---solution /optimization
---Create an index on league_id in the matches table:
---CREATE INDEX idx_matches_league_id ON matches (league_id);

---Precompute the total goals in a materialized view:
---CREATE MATERIALIZED VIEW league_goals AS
---SELECT league_id, SUM(home_team_goal + away_team_goal) AS total_goals
------FROM matches
---GROUP BY league_id;

--- Simplify the query to 
SELECT league.name AS league_name, lg.total_goals
FROM league
JOIN league_goals lg ON league.id = lg.league_id
ORDER BY lg.total_goals DESC
LIMIT 1;


---subquery for teams with most matches played 
---orginal query 
SELECT team_long_name, total_matches
FROM (
    SELECT team_long_name, 
           (COUNT(home_matches.home_team_api_id) + COUNT(away_matches.away_team_api_id)) AS total_matches
    FROM team
    LEFT JOIN matches AS home_matches ON team.team_api_id = home_matches.home_team_api_id
    LEFT JOIN matches AS away_matches ON team.team_api_id = away_matches.away_team_api_id
    GROUP BY team_long_name
) AS team_match_counts
ORDER BY total_matches DESC
LIMIT 5;

---Performance Issues
---Multiple joins: Two LEFT JOIN operations are performed on the matches table.
---Subquery: The subquery introduces additional computation overhead.
---Expensive aggregation: Aggregating counts from two different joins adds significant cost.

---solution  / optimization 
---Create indexes on home_team_api_id and away_team_api_id
CREATE INDEX idx_matches_home_team ON matches (home_team_api_id);
CREATE INDEX idx_matches_away_team ON matches (away_team_api_id);

---Use a single query with a UNION ALL approach to avoid separate joins:
SELECT team_long_name, COUNT(*) AS total_matches
FROM (
    SELECT team.team_long_name
    FROM team
    JOIN matches ON team.team_api_id = matches.home_team_api_id
    UNION ALL
    SELECT team.team_long_name
    FROM team
    JOIN matches ON team.team_api_id = matches.away_team_api_id
) AS team_match_data
GROUP BY team_long_name
ORDER BY total_matches DESC
LIMIT 5;









---- sql dump   .datasets  - ---zip folder   



