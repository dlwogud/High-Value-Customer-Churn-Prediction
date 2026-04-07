-- 각 사용자(user_id)별 주문 이력을 기반으로 핵심 행동 지표를 생성하는 테이블
-- 총 주문 수, 주문 간 평균 간격(days), 마지막 주문 번호를 계산하여 고객 특성 요약
-- 이후 churn 분석이나 모델링에 사용할 기본 피처 테이블 생성
CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.user_order_features_all` AS
SELECT
  user_id,
  COUNT(*) AS total_orders,
  COALESCE(
    AVG(CASE 
          WHEN days_since_prior_order IS NOT NULL 
               AND days_since_prior_order > 0
          THEN days_since_prior_order 
        END),
    0
  ) AS avg_days_between_orders,
  MAX(order_number) AS max_order_number
FROM `instacart-churn.instacart_ds.orders`
GROUP BY user_id;
