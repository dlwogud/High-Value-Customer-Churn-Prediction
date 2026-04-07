-- 목적: 고빈도 고객의 target order(마지막 주문) 전용 테이블 생성
-- 설명:
-- 이 테이블은 label 생성용으로만 사용하며,
-- feature 계산에는 절대 포함하지 않음

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.last_orders_hv` AS
SELECT
  user_id,
  order_id AS target_order_id,
  order_number AS target_order_number,
  order_dow AS target_order_dow,
  order_hour_of_day AS target_order_hour_of_day,
  days_since_prior_order AS target_gap
FROM `instacart-churn.instacart_ds.high_value_orders`
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY user_id
  ORDER BY order_number DESC
) = 1;
