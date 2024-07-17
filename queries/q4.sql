-- Calculate the top 5 projects by TVL (Total Value Locked) in USD for each blockchain over the past 30 days
WITH ranked_projects AS (
  SELECT
    pm.blockchain, -- Blockchain name
    pm.project_contract_address, -- Project contract address
    SUM(pm.tvl_usd) AS USD_TVL, -- Sum of TVL in USD
    SUM(pm.tvl_eth) AS ETH_TVL, -- Sum of TVL in ETH
    ROW_NUMBER() OVER (PARTITION BY pm.blockchain ORDER BY SUM(pm.tvl_usd) DESC) AS rn -- Rank projects by TVL in USD within each blockchain
  FROM dex.pools_metrics_daily pm
  WHERE pm.block_date > CURRENT_DATE - INTERVAL '30' DAY -- Only include records from the last 30 days
  GROUP BY
    pm.blockchain, -- Group by blockchain
    pm.project_contract_address -- Group by project contract address
)
-- Select and format the required data for the final output
SELECT
  blockchain, -- Blockchain name
  project_contract_address, -- Project contract address
  ROUND(USD_TVL) AS USD_TVL, -- Round TVL in USD to the nearest whole number
  ROUND(ETH_TVL, 6) AS ETH_TVL -- Round TVL in ETH to 6 decimal places
FROM ranked_projects
WHERE rn <= 5 -- Only include the top 5 projects per blockchain
ORDER BY blockchain, USD_TVL DESC; -- Order by blockchain and then by TVL in USD descending
