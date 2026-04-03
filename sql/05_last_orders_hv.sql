-- 목적: 고가치 고객별 마지막 주문 1건 추출
-- 설명: 각 user_id별 가장 최근 주문(order_number 최대값)만 남김

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.last_orders_hv` AS
SELECT
  *
FROM `instacart-churn.instacart_ds.high_value_orders`
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY user_id
  ORDER BY order_number DESC
) = 1;
