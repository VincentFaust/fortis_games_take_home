SELECT 
	date_pst AS event_date
	, source
	, SUM(actual_revenue) as network_revenue
FROM {{source("raw", "summary_report_revenue")}}
GROUP BY event_date, source