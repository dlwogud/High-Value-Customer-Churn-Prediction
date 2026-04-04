-- 목적: 고가치 고객 이탈 라벨 생성
-- 설명: 구매 간격 분포의 상위 90% 분위수(q90=15일)를 기준으로,
--       마지막 주문의 days_since_prior_order가 15일 초과이면 churn=1로 정의

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.churn_labels_hv` AS
SELECT
  user_id,
  order_id,
  order_number,
  days_since_prior_order,
  CASE
    WHEN days_since_prior_order > 15 THEN 1
    ELSE 0
  END AS churn
FROM `instacart-churn.instacart_ds.last_orders_hv`;
