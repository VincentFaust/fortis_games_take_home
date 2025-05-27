WITH active_users AS (
  SELECT 
    (event_timestamp_utc AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_Angeles')::date AS event_date,
    COUNT(DISTINCT player_id) AS dau 
  FROM {{source("raw", "start_session_events")}}
  GROUP BY event_date
),


payers AS (
  SELECT
    (event_timestamp_utc AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_Angeles')::date AS event_date,
    COUNT(DISTINCT player_id) AS daily_payers 
  FROM {{source("raw", "in_app_purchase_events")}}
    GROUP BY event_date
)




SELECT 
  event_date,
  COALESCE(daily_payers, 0) AS daily_payers,
  dau,
  ROUND(COALESCE(daily_payers * 1.0 / NULLIF(dau, 0), 0) * 100, 2) AS payer_rate
FROM active_users
LEFT JOIN payers 
  USING (event_date)
ORDER BY event_date
