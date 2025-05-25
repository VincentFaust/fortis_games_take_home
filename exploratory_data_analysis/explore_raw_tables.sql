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


