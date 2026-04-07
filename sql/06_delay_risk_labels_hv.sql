-- 목적: target order 기준 재구매 지연 위험 라벨 생성
-- 설명:
-- 고빈도 고객 집단의 q90=15일 기준 절대값을 사용하여
-- target_gap > 15 이면 delay_risk=1로 정의

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.delay_risk_labels_hv` AS
SELECT
  user_id,
  target_order_id,
  target_order_number,
  target_gap,
  CASE
    WHEN target_gap > 15 THEN 1
    ELSE 0
  END AS delay_risk
FROM `instacart-churn.instacart_ds.last_orders_hv`;

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.delay_risk_distribution_hv` AS
SELECT
  delay_risk,
  COUNT(*) AS cnt,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (), 4) AS ratio
FROM `instacart-churn.instacart_ds.delay_risk_labels_hv`
GROUP BY delay_risk
ORDER BY delay_risk;
