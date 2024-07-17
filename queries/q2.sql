WITH
  -- Calculate the total USD volume for each project over the past 7 days
  seven_day_volume AS (
    SELECT
      project AS "Project",
      SUM(CAST(amount_usd AS DOUBLE)) AS usd_volume
    FROM
      dex_aggregator.trades AS t
    WHERE
      block_time > CURRENT_TIMESTAMP - INTERVAL '7' day
    GROUP BY
      1
  ),
  -- Calculate the total USD volume for each project over the past 1 day
  one_day_volume AS (
    SELECT
      project AS "Project",
      SUM(CAST(amount_usd AS DOUBLE)) AS usd_volume
    FROM
      dex_aggregator.trades AS t
    WHERE
      block_time > CURRENT_TIMESTAMP - INTERVAL '1' day
    GROUP BY
      1
  )
-- Select and rank projects based on their 7-day volume
SELECT
  ROW_NUMBER() OVER (
    ORDER BY
      SUM(seven.usd_volume) DESC NULLS FIRST -- Rank by 7-day volume, highest first
  ) AS "Rank",
  seven."Project",
  SUM(seven.usd_volume) AS "7 Days Volume", -- Sum of 7-day volume
  SUM(one.usd_volume) AS "24 Hours Volume"  -- Sum of 24-hour volume
FROM
  seven_day_volume AS seven
  LEFT JOIN one_day_volume AS one ON seven."Project" = one."Project" -- Join with 1-day volume on project name
GROUP BY
  2
ORDER BY
  3 DESC NULLS FIRST -- Order by 7-day volume, highest first
