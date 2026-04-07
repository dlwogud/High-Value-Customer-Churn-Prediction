CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.user_order_features_all` AS
SELECT
  user_id,
  COUNT(*) AS total_orders,
  COALESCE(
    AVG(CASE 
          WHEN days_since_prior_order IS NOT NULL 
               AND days_since_prior_order > 0
          THEN days_since_prior_order 
        END),
    0
  ) AS avg_days_between_orders,
  MAX(order_number) AS max_order_number
FROM `instacart-churn.instacart_ds.orders`
GROUP BY user_id;
