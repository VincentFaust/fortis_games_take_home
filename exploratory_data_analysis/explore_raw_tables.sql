-- no cost data, but install data??? 

SELECT 
	*
FROM raw.summary_report_ad_networks
WHERE adn_cost = 0 
	AND adn_installs > 0


-- large number of unattributed installs as share of total

WITH install_counts AS (
  SELECT 
    tracker_network,
    COUNT(*) AS install_cnt
  FROM raw.mmp_singular_install_events
  GROUP BY tracker_network
),

all_counts AS (
  SELECT 
    COUNT(*) AS total_installs
  FROM raw.mmp_singular_install_events
)

SELECT 
  tracker_network,
  install_cnt,
  ROUND(install_cnt * 1.0 / total_installs * 100, 2) AS pct_of_total_installs
FROM install_counts 
CROSS JOIN all_counts 
ORDER BY pct_of_total_installs DESC;


-- Power law curve for session behavior (what you'd expect)

WITH session_counts AS (
  SELECT 
    player_id,
    COUNT(*) AS session_count
  FROM raw.start_session_events
  GROUP BY player_id
)

SELECT 
  session_count,
  COUNT(*) AS user_count
FROM session_counts
GROUP BY session_count
ORDER BY session_count;


-- Power law curve for unattributed users only 

WITH unattributed_users AS (
  SELECT DISTINCT player_id
  FROM raw.mmp_singular_install_events
  WHERE tracker_network = 'Unattributed'
),

session_counts AS (
  SELECT 
    player_id,
    COUNT(*) AS session_count
  FROM raw.start_session_events
  GROUP BY player_id
),

filtered_sessions AS (
  SELECT 
    s.player_id,
    s.session_count
  FROM session_counts s
  JOIN unattributed_users u ON s.player_id = u.player_id
)

SELECT 
  session_count,
  COUNT(*) AS user_count
FROM filtered_sessions
GROUP BY session_count
ORDER BY session_count;



--install dates after first sessions 

WITH first_sessions AS (
    SELECT 
        player_id,
        MIN(event_timestamp_utc) AS first_session
    FROM raw.start_session_events
    GROUP BY player_id
),

install_events AS (
    SELECT 
        event_timestamp_utc AS install_date,
        player_id,
        session_id,
        event_name,
        tracker_network,
        tracker_campaign_name,
        tracker_sub_campaign_name,
        is_organic,
        match_type
    FROM raw.mmp_singular_install_events
),

time_diff AS (
    SELECT 
        ie.player_id AS player_id,
        first_session,
        install_date,
        tracker_network,
        tracker_sub_campaign_name,
        EXTRACT(EPOCH FROM (ie.install_date - fs.first_session)) / 60 AS time_diff_minutes
    FROM first_sessions fs
    INNER JOIN install_events ie
        ON fs.player_id = ie.player_id
)

SELECT 
    CASE 
        WHEN time_diff_minutes < 0 THEN '< 0 min'
        WHEN time_diff_minutes < 1 THEN '0-1 min'
        WHEN time_diff_minutes < 5 THEN '1-5 min'
        WHEN time_diff_minutes < 15 THEN '5-15 min'
        WHEN time_diff_minutes < 60 THEN '15-60 min'
        WHEN time_diff_minutes < 180 THEN '1-3 hr'
        WHEN time_diff_minutes < 1440 THEN '3-24 hr'
        ELSE '> 24 hrs'
    END AS delay_buckets,
    COUNT(*) AS user_cnt 
FROM time_diff
GROUP BY delay_buckets
ORDER BY MIN(time_diff_minutes);


-- summary revenue data from the mmp

SELECT 
	SOURCE
	, SUM(actual_revenue)
FROM raw.summary_report_revenue
GROUP BY SOURCE


-- flagging revenue inconsistencies 


with data_get as (
SELECT 
  *
  , CASE WHEN actual_revenue != revenue_d7 THEN 1 ELSE 0 END AS rev_flag
FROM raw.summary_report_revenue) 


SELECT 
	rev_flag
	,  COUNT(*) 
FROM data_get
GROUP BY rev_flag
