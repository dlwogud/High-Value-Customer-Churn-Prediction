-- 목적: 고가치 고객의 주문 데이터만 추출
-- 설명: 전체 주문 데이터에서 고가치 고객의 주문 내역만 필터링

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.high_value_orders` AS
SELECT
  o.*
FROM `instacart-churn.instacart_ds.orders` AS o
JOIN `instacart-churn.instacart_ds.high_value_customers` AS h
  ON o.user_id = h.user_id;
