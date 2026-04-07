-- 목적: 최종 모델 학습용 테이블 생성
-- 설명:
-- 1) target order 직전까지의 이력으로 만든 feature
-- 2) target order 기준 delay_risk label
-- 3) split 및 추적을 위한 key(user_id, target_order_number, target_order_id) 포함

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.model_base_hv` AS
SELECT
  f.user_id,
  f.target_order_id,
  f.target_order_number,
  f.target_gap,

  f.total_orders_before_target,
  f.avg_gap_before_target,
  f.std_gap_before_target,
  f.min_gap_before_target,
  f.max_gap_before_target,
  f.recent_3_avg_gap,
  f.recent_5_avg_gap,
  f.last_gap_before_target,
  f.gap_trend,
  f.active_span_days,
  f.order_frequency,
  f.weekend_order_ratio,
  f.dow_variability,

  l.delay_risk
FROM `instacart-churn.instacart_ds.user_order_features` f
JOIN `instacart-churn.instacart_ds.delay_risk_labels_hv` l
  ON f.user_id = l.user_id
 AND f.target_order_id = l.target_order_id
 AND f.target_order_number = l.target_order_number;
