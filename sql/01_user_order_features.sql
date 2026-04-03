-- 목적: 고객별 기본 주문 행동 feature 생성
-- 설명: 총 주문 횟수, 평균 구매 간격, 최대 주문 순서를 생성

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.user_order_features` AS
SELECT
  user_id,
  COUNT(*) AS total_orders,
  AVG(CASE 
        WHEN days_since_prior_order IS NOT NULL THEN days_since_prior_order 
      END) AS avg_days_between_orders,
  MAX(order_number) AS max_order_number
FROM `instacart-churn.instacart_ds.orders`
GROUP BY user_id;

SELECT *
FROM `instacart-churn.instacart_ds.user_order_features`
LIMIT 10;
