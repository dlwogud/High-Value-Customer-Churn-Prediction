-- 목적: 고빈도 고객 정의 + threshold 숫자 저장
-- 설명:
-- 1) 전체 고객의 total_orders 분포에서 상위 20% 기준 추출
-- 2) 실제 threshold 값을 별도 테이블에 저장
-- 3) 발표 시 "상위 20%"와 "N회 이상"을 함께 설명 가능하도록 구성

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.high_value_threshold` AS
SELECT
  APPROX_QUANTILES(total_orders, 100)[OFFSET(80)] AS order_threshold
FROM `instacart-churn.instacart_ds.user_order_features_all`;

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.high_value_customers` AS
SELECT
  f.*
FROM `instacart-churn.instacart_ds.user_order_features_all` f
CROSS JOIN `instacart-churn.instacart_ds.high_value_threshold` t
WHERE f.total_orders >= t.order_threshold;
