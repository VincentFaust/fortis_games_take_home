
WITH ad_spend AS (
  SELECT 
    date_pst AS event_date
    , SUM(adn_cost) AS daily_spend
  FROM {{ source("raw", "summary_report_ad_networks") }}
  GROUP BY date_pst
)

,

rev AS (
  SELECT
    date_pst AS event_date
    , SUM(actual_revenue) AS daily_cumulative_revenue
  FROM {{ source("raw", "summary_report_revenue") }}
  GROUP BY date_pst
)

SELECT
  event_date,
  daily_spend,
  daily_cumulative_revenue,
  daily_cumulative_revenue - daily_spend AS daily_pnl
FROM ad_spend
LEFT JOIN rev USING(event_date)
