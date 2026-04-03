-- 목적: 모델 학습용 기본 테이블 생성
-- 설명: 고가치 고객의 주문 feature와 churn 라벨을 결합

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.model_base_hv` AS
SELECT
  f.user_id,
  f.total_orders,
  f.avg_days_between_orders,
  f.max_order_number,
  l.churn
FROM `instacart-churn.instacart_ds.high_value_customers` AS f
JOIN `instacart-churn.instacart_ds.churn_labels_hv` AS l
  ON f.user_id = l.user_id;
