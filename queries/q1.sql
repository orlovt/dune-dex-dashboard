-- Select the project name, truncated block time by day, and the sum of the trade amounts in USD
SELECT
  project,
  DATE_TRUNC('day', block_time), -- Truncate block_time to the day
  SUM(CAST(amount_usd AS DOUBLE)) AS usd_volume -- Sum the amount_usd and cast it as DOUBLE for accuracy
FROM
  dex."trades" AS t -- From the trades table in the dex schema
WHERE
  block_time > DATE_TRUNC('day', NOW()) - INTERVAL '30' day -- Only include records from the last 30 days
  AND block_time < DATE_TRUNC('day', NOW()) -- Exclude today's records for a full 30 days window
GROUP BY
  1, -- Group by project
  2  -- Group by truncated block_time (day)
