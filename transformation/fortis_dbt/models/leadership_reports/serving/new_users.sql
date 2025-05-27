WITH active_users AS (
SELECT 
  (event_timestamp_utc AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_Angeles')::date AS event_date
	, COUNT(DISTINCT player_id) AS dau
FROM {{source("raw", "start_session_events")}}
GROUP BY event_date) 


, 


new_comers as (
SELECT 
  (event_timestamp_utc AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_Angeles')::date AS event_date
	, COUNT(player_id) AS new_users 
FROM {{source("raw", "mmp_singular_install_events")}}
GROUP BY event_date) 


SELECT 
	dau
	, new_users 
	, dau - new_users as net_new_users
FROM active_users
LEFT JOIN new_comers 
	USING(event_date)