SELECT 
  (event_timestamp_utc AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_Angeles')::date AS event_date
, COUNT(DISTINCT player_id) AS dau
FROM {{ source("raw", "start_session_events") }}
GROUP BY event_date
