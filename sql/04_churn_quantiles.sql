-- 목적: 고가치 고객의 구매 간격 분포 확인
-- 설명: churn 기준 설정을 위해 구매 간격의 분위수(q80, q90, q95) 계산

SELECT
  APPROX_QUANTILES(days_since_prior_order, 100)[OFFSET(80)] AS q80,
  APPROX_QUANTILES(days_since_prior_order, 100)[OFFSET(90)] AS q90,
  APPROX_QUANTILES(days_since_prior_order, 100)[OFFSET(95)] AS q95
FROM `instacart-churn.instacart_ds.high_value_orders`
WHERE days_since_prior_order IS NOT NULL;
