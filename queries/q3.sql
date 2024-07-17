-- Calculate token volumes for the past 30 days, aggregating both bought and sold tokens
WITH token_volumes AS (
  -- Select token bought volumes
  SELECT
    token_bought_symbol AS token_symbol,
    DATE_TRUNC('day', block_time) AS period, -- Truncate block time to the day
    SUM(amount_usd) AS volume -- Sum the USD amount for bought tokens
  FROM dex.trades
  WHERE
    block_time >= CURRENT_DATE - INTERVAL '30' day -- Only include records from the last 30 days
  GROUP BY
    token_bought_symbol,
    DATE_TRUNC('day', block_time)
  UNION ALL
  -- Select token sold volumes
  SELECT
    token_sold_symbol AS token_symbol,
    DATE_TRUNC('day', block_time) AS period, -- Truncate block time to the day
    SUM(amount_usd) AS volume -- Sum the USD amount for sold tokens
  FROM dex.trades
  WHERE
    block_time >= CURRENT_DATE - INTERVAL '30' day -- Only include records from the last 30 days
  GROUP BY
    token_sold_symbol,
    DATE_TRUNC('day', block_time)
), aggregated_volumes AS (
  -- Aggregate daily, weekly, and monthly volumes for each token
  SELECT
    token_symbol,
    period,
    SUM(volume) OVER (PARTITION BY token_symbol, DATE_TRUNC('day', period)) AS daily_volume, -- Daily volume
    SUM(volume) OVER (PARTITION BY token_symbol, DATE_TRUNC('week', period)) AS weekly_volume, -- Weekly volume
    SUM(volume) OVER (PARTITION BY token_symbol, DATE_TRUNC('month', period)) AS monthly_volume -- Monthly volume
  FROM token_volumes
)
-- Select and order the required data for the final output
SELECT
  period,
  token_symbol,
  daily_volume AS volume_24h, -- 24-hour volume
  weekly_volume AS volume_7d, -- 7-day volume
  monthly_volume AS volume_30d -- 30-day volume
FROM aggregated_volumes
WHERE
  period = CURRENT_DATE - INTERVAL '1' day -- Data for 1 day ago
  OR period = CURRENT_DATE - INTERVAL '7' day -- Data for 7 days ago
  OR period = CURRENT_DATE - INTERVAL '30' day -- Data for 30 days ago
ORDER BY
  period DESC, -- Order by period descending
  daily_volume DESC, -- Then by daily volume descending
  weekly_volume DESC, -- Then by weekly volume descending
  monthly_volume DESC -- Finally by monthly volume descending
LIMIT 10 -- Limit the result to top 10
