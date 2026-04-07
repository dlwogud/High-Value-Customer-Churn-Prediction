-- 목적: target gap 기준 분위수 결과 저장 + 발표용 근거 자료 생성
-- 설명:
-- 1) 고빈도 고객의 마지막 주문 gap(target_gap) 기준으로 q80/q90/q95 저장
-- 2) 구간별 빈도표도 함께 생성하여 발표 자료로 활용 가능하게 구성

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.target_orders_hv` AS
SELECT
  user_id,
  order_id AS target_order_id,
  order_number AS target_order_number,
  days_since_prior_order AS target_gap
FROM `instacart-churn.instacart_ds.high_value_orders`
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY user_id
  ORDER BY order_number DESC
) = 1;

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.delay_risk_quantiles_hv` AS
SELECT
  APPROX_QUANTILES(target_gap, 100)[OFFSET(80)] AS q80,
  APPROX_QUANTILES(target_gap, 100)[OFFSET(90)] AS q90,
  APPROX_QUANTILES(target_gap, 100)[OFFSET(95)] AS q95
FROM `instacart-churn.instacart_ds.target_orders_hv`
WHERE target_gap IS NOT NULL;

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.delay_risk_gap_hist_hv` AS
SELECT
  FLOOR(target_gap / 5) * 5 AS gap_bin_start,
  COUNT(*) AS cnt
FROM `instacart-churn.instacart_ds.target_orders_hv`
WHERE target_gap IS NOT NULL
GROUP BY gap_bin_start
ORDER BY gap_bin_start;
