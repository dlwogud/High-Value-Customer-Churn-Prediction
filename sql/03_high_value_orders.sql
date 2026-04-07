-- 목적: 고빈도 고객 전체 주문 이력 추출
-- 설명:
-- 이후 단계에서 target order와 history order를 분리할 수 있도록
-- 고빈도 고객의 전체 주문 데이터를 유지

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.high_value_orders` AS
SELECT
  o.*
FROM `instacart-churn.instacart_ds.orders` o
JOIN `instacart-churn.instacart_ds.high_value_customers` h
  ON o.user_id = h.user_id;
