-- =============================================================================
-- E-commerce Funnel & Conversion Analysis  —  BigQuery SQL
-- Author : Omar Quinn
-- Source : event-level user_events (page_view, add_to_cart, checkout_start,
--          payment_info, purchase) with traffic_source and purchase amount.
-- Window : trailing 30 days from 2026-02-03.
-- =============================================================================

-- Sample the raw events
SELECT *
FROM `project-fa7543d8-8741-4591-a6e.1p.user-events`
LIMIT 1000;


-- 1. FUNNEL STAGES — distinct users reaching each stage
WITH funnel_stages AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view'      THEN user_id END) AS stage_1_views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart'    THEN user_id END) AS stage_2_cart,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info'   THEN user_id END) AS stage_4_payment,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase'       THEN user_id END) AS stage_5_purchase
  FROM `project-fa7543d8-8741-4591-a6e.1p.user-events`
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE('2026-02-03'), INTERVAL 30 DAY))
)
SELECT * FROM funnel_stages;


-- 2. FUNNEL CONVERSION RATES — step-by-step and overall
WITH funnel_stages AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view'      THEN user_id END) AS stage_1_views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart'    THEN user_id END) AS stage_2_cart,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info'   THEN user_id END) AS stage_4_payment,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase'       THEN user_id END) AS stage_5_purchase
  FROM `project-fa7543d8-8741-4591-a6e.1p.user-events`
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE('2026-02-03'), INTERVAL 30 DAY))
)
SELECT
  stage_1_views,
  stage_2_cart,
  ROUND(SAFE_DIVIDE(stage_2_cart, stage_1_views) * 100, 2)      AS view_to_cart_rate,
  stage_3_checkout,
  ROUND(SAFE_DIVIDE(stage_3_checkout, stage_2_cart) * 100, 2)   AS cart_to_checkout_rate,
  stage_4_payment,
  ROUND(SAFE_DIVIDE(stage_4_payment, stage_3_checkout) * 100, 2) AS checkout_to_payment_rate,
  stage_5_purchase,
  ROUND(SAFE_DIVIDE(stage_5_purchase, stage_4_payment) * 100, 2) AS payment_to_purchase_rate,
  ROUND(SAFE_DIVIDE(stage_5_purchase, stage_1_views) * 100, 2)   AS overall_rate
FROM funnel_stages;


-- 3. FUNNEL BY TRAFFIC SOURCE — channel quality, not just volume
WITH source_funnel AS (
  SELECT
    traffic_source,
    COUNT(DISTINCT CASE WHEN event_type = 'page_view'   THEN user_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS cart,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase'    THEN user_id END) AS purchases
  FROM `project-fa7543d8-8741-4591-a6e.1p.user-events`
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE('2026-02-03'), INTERVAL 30 DAY))
  GROUP BY traffic_source
)
SELECT
  traffic_source,
  views,
  cart,
  purchases,
  ROUND(SAFE_DIVIDE(cart, views) * 100, 2)       AS cart_conversion_rate,
  ROUND(SAFE_DIVIDE(purchases, views) * 100, 2)  AS purchase_conversion_rate,
  ROUND(SAFE_DIVIDE(purchases, cart) * 100, 2)   AS cart_to_purchase_conversion_rate
FROM source_funnel
ORDER BY purchases DESC;


-- 4. TIME IN THE FUNNEL — average minutes between stages for converters
WITH user_journey AS (
  SELECT
    user_id,
    MIN(CASE WHEN event_type = 'page_view'   THEN event_date END) AS view_time,
    MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END) AS cart_time,
    MIN(CASE WHEN event_type = 'purchase'    THEN event_date END) AS purchase_time
  FROM `project-fa7543d8-8741-4591-a6e.1p.user-events`
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE('2026-02-03'), INTERVAL 30 DAY))
  GROUP BY user_id
  HAVING purchase_time IS NOT NULL
)
SELECT
  COUNT(*) AS converted_users,
  ROUND(AVG(TIMESTAMP_DIFF(cart_time, view_time, MINUTE)), 2)     AS avg_view_to_cart_minutes,
  ROUND(AVG(TIMESTAMP_DIFF(purchase_time, cart_time, MINUTE)), 2) AS avg_cart_to_purchase_minutes,
  ROUND(AVG(TIMESTAMP_DIFF(purchase_time, view_time, MINUTE)), 2) AS avg_total_journey_minutes
FROM user_journey;


-- 5. REVENUE FUNNEL — AOV, revenue per buyer, revenue per visitor
WITH funnel_revenue AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS total_visitors,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase'  THEN user_id END) AS total_buyers,
    SUM(CASE WHEN event_type = 'purchase' THEN amount END)              AS total_revenue,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END)                 AS total_orders
  FROM `project-fa7543d8-8741-4591-a6e.1p.user-events`
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE('2026-02-03'), INTERVAL 30 DAY))
)
SELECT
  total_visitors,
  total_buyers,
  total_orders,
  total_revenue,
  SAFE_DIVIDE(total_revenue, total_orders)   AS avg_order_value,
  SAFE_DIVIDE(total_revenue, total_buyers)   AS revenue_per_buyer,
  SAFE_DIVIDE(total_revenue, total_visitors) AS revenue_per_visitor
FROM funnel_revenue;
