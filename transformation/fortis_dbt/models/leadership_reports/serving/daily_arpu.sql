
WITH active_users AS(
SELECT
	  (event_timestamp_utc AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_Angeles')::date AS event_date
,	COUNT(DISTINCT player_id) AS dau 
FROM {{ source("raw", "start_session_events") }}
GROUP BY event_date )



,

daily_rev AS(
SELECT 
	date_pst AS event_date
	, SUM(actual_revenue) AS total_daily_revenue 
FROM {{ source("raw", "summary_report_revenue") }}
GROUP BY event_date ) 


SELECT 
	event_date
	, dau
	, total_daily_revenue 
    , ROUND(COALESCE(total_daily_revenue, 0) / NULLIF(dau, 0), 2) AS arpu
FROM active_users
LEFT JOIN daily_rev	
	USING(event_date)




