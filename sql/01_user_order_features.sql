-- 목적: target order(마지막 주문) 직전까지의 이력만 사용하여 고객별 feature 생성
-- 설명:
-- 1) 고빈도 고객의 마지막 주문 1건(target order)을 제외
-- 2) 그 이전 주문 이력만으로 최근성/변동성/추세 feature 생성
-- 3) label에 사용되는 마지막 주문 정보가 feature에 섞이지 않도록 시점 분리

CREATE OR REPLACE TABLE `instacart-churn.instacart_ds.user_order_features` AS
WITH target_orders AS (
  SELECT
    user_id,
    order_id AS target_order_id,
    order_number AS target_order_number,
    days_since_prior_order AS target_gap
  FROM `instacart-churn.instacart_ds.high_value_orders`
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY user_id
    ORDER BY order_number DESC
  ) = 1
),

history_orders AS (
  SELECT
    o.user_id,
    o.order_id,
    o.order_number,
    o.order_dow,
    o.days_since_prior_order,
    t.target_order_id,
    t.target_order_number,
    t.target_gap
  FROM `instacart-churn.instacart_ds.high_value_orders` o
  JOIN target_orders t
    ON o.user_id = t.user_id
  WHERE o.order_number < t.target_order_number
),

history_base AS (
  SELECT
    user_id,
    target_order_id,
    target_order_number,
    target_gap,

    COUNT(*) AS total_orders_before_target,

    COALESCE(
      AVG(CASE WHEN days_since_prior_order IS NOT NULL AND days_since_prior_order > 0
               THEN days_since_prior_order END),
      0
    ) AS avg_gap_before_target,

    COALESCE(
      STDDEV_SAMP(CASE WHEN days_since_prior_order IS NOT NULL AND days_since_prior_order > 0
                       THEN days_since_prior_order END),
      0
    ) AS std_gap_before_target,

    COALESCE(
      MIN(CASE WHEN days_since_prior_order IS NOT NULL AND days_since_prior_order > 0
               THEN days_since_prior_order END),
      0
    ) AS min_gap_before_target,

    COALESCE(
      MAX(CASE WHEN days_since_prior_order IS NOT NULL AND days_since_prior_order > 0
               THEN days_since_prior_order END),
      0
    ) AS max_gap_before_target,

    COALESCE(SUM(COALESCE(days_since_prior_order, 0)), 0) AS active_span_days,

    COUNTIF(order_dow IN (0, 6)) / COUNT(*) AS weekend_order_ratio,
    COUNT(DISTINCT order_dow) AS dow_variability
  FROM history_orders
  GROUP BY
    user_id, target_order_id, target_order_number, target_gap
),

recent_gaps AS (
  SELECT
    user_id,
    target_order_id,
    target_order_number,

    COALESCE(
      AVG(CASE WHEN rn_desc <= 3 AND days_since_prior_order IS NOT NULL AND days_since_prior_order > 0
               THEN days_since_prior_order END),
      0
    ) AS recent_3_avg_gap,

    COALESCE(
      AVG(CASE WHEN rn_desc <= 5 AND days_since_prior_order IS NOT NULL AND days_since_prior_order > 0
               THEN days_since_prior_order END),
      0
    ) AS recent_5_avg_gap,

    COALESCE(
      MAX(CASE WHEN rn_desc = 1 THEN days_since_prior_order END),
      0
    ) AS last_gap_before_target,

    COALESCE(
      AVG(CASE WHEN rn_desc BETWEEN 1 AND 3 AND days_since_prior_order IS NOT NULL AND days_since_prior_order > 0
               THEN days_since_prior_order END),
      0
    )
    -
    COALESCE(
      AVG(CASE WHEN rn_desc BETWEEN 4 AND 6 AND days_since_prior_order IS NOT NULL AND days_since_prior_order > 0
               THEN days_since_prior_order END),
      0
    ) AS gap_trend
  FROM (
    SELECT
      user_id,
      target_order_id,
      target_order_number,
      order_number,
      days_since_prior_order,
      ROW_NUMBER() OVER (
        PARTITION BY user_id
        ORDER BY order_number DESC
      ) AS rn_desc
    FROM history_orders
  )
  GROUP BY
    user_id, target_order_id, target_order_number
)

SELECT
  b.user_id,
  b.target_order_id,
  b.target_order_number,
  b.target_gap,

  b.total_orders_before_target,
  b.avg_gap_before_target,
  b.std_gap_before_target,
  b.min_gap_before_target,
  b.max_gap_before_target,

  r.recent_3_avg_gap,
  r.recent_5_avg_gap,
  r.last_gap_before_target,
  r.gap_trend,

  b.active_span_days,

  CASE
    WHEN b.active_span_days > 0
    THEN b.total_orders_before_target / b.active_span_days
    ELSE 0
  END AS order_frequency,

  b.weekend_order_ratio,
  b.dow_variability

FROM history_base b
LEFT JOIN recent_gaps r
  ON b.user_id = r.user_id
 AND b.target_order_id = r.target_order_id
 AND b.target_order_number = r.target_order_number;
