CREATE TABLE raw.summary_report_revenue (
    date_pst DATE,
    source TEXT,
    adn_campaign_name TEXT,
    adn_sub_campaign_name TEXT,
    actual_revenue NUMERIC,
    revenue_d1 NUMERIC,
    revenue_d7 NUMERIC
);

CREATE TABLE raw.summary_report_ad_networks (
    date_pst DATE,
    source TEXT,
    adn_campaign_name TEXT,
    adn_sub_campaign_name TEXT,
    adn_cost NUMERIC,
    adn_impressions INTEGER,
    adn_clicks INTEGER,
    adn_installs INTEGER
);

CREATE TABLE raw.start_session_events (
    event_timestamp_utc TIMESTAMP,
    player_id TEXT,
    session_id TEXT,
    event_name TEXT
);

CREATE TABLE raw.mmp_singular_install_events (
    event_timestamp_utc TIMESTAMP,
    player_id TEXT,
    session_id TEXT,
    event_name TEXT,
    tracker_network TEXT,
    tracker_campaign_name TEXT,
    tracker_sub_campaign_name TEXT,
    is_organic BOOLEAN,
    match_type TEXT
);

CREATE TABLE raw.in_app_purchase_events (
    event_timestamp_utc TIMESTAMP,
    player_id TEXT,
    session_id TEXT,
    event_name TEXT,
    price NUMERIC
);
