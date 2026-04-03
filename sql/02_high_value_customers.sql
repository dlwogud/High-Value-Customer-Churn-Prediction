-- 목적: 고가치 고객 정의
-- 설명: 주문 횟수 기준 상위 20% 고객을 고가치 고객으로 추출

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.high_value_customers` AS
WITH threshold_table AS (
  SELECT
    APPROX_QUANTILES(total_orders, 100)[OFFSET(80)] AS order_threshold
  FROM `instacart-churn.instacart_ds.user_order_features`
)
SELECT
  u.*
FROM `instacart-churn.instacart_ds.user_order_features` AS u
CROSS JOIN threshold_table AS t
WHERE u.total_orders >= t.order_threshold;
