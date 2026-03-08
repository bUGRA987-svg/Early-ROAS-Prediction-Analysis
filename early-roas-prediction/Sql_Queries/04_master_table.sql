/* ===================================================================
Script Name: 04_master_table.sql
Author: Buğra
Description: Bu sorgu, kullanıcıların D3 (İlk 3 Gün) davranış özellikleri 
             ile D30 (30. Gün) satın alma hedeflerini (Label) birleştirerek 
             makine öğrenmesi modeli için nihai 'Feature Matrix'i oluşturur.
Dataset: firebase-public-project.analytics_153293282.events_*
=================================================================== */
WITH user_cohort AS (
  -- 1. ADIM: Tüm 2018'deki ilk açılışları bul
  SELECT 
    user_pseudo_id,
    MIN(event_timestamp) AS first_open_timestamp
  FROM 
    `firebase-public-project.analytics_153293282.events_*`
  WHERE 
    event_name = 'first_open'
    AND _TABLE_SUFFIX BETWEEN '20180101' AND '20181231'
  GROUP BY 
    user_pseudo_id
),

d3_features AS (
  -- 2. ADIM: Bu kullanıcıların ilk 3 günlük hareketleri
  SELECT 
    c.user_pseudo_id,
    COUNT(e.event_name) AS d3_total_events,
    COUNTIF(e.event_name = 'level_complete_quickplay') AS d3_levels_completed,
    COUNTIF(e.event_name = 'app_exception') AS d3_errors,
    MAX((SELECT value.int_value FROM UNNEST(e.event_params) WHERE key = 'score')) AS d3_max_score,
    MAX(e.traffic_source.name) as traffic_source
  FROM 
    user_cohort c
  JOIN 
    `firebase-public-project.analytics_153293282.events_*` e
  ON 
    c.user_pseudo_id = e.user_pseudo_id
  WHERE 
    e._TABLE_SUFFIX BETWEEN '20180101' AND '20181231'
    AND e.event_timestamp >= c.first_open_timestamp
    AND e.event_timestamp <= c.first_open_timestamp + 259200000000
  GROUP BY 
    c.user_pseudo_id
),

d30_target AS (
  -- 3. ADIM: Aynı kullanıcıların 30 günlük harcama durumu
  SELECT 
    c.user_pseudo_id,
    MAX(IF(e.event_name = 'in_app_purchase', 1, 0)) AS target_roas_d30
  FROM 
    user_cohort c
  JOIN 
    `firebase-public-project.analytics_153293282.events_*` e
  ON 
    c.user_pseudo_id = e.user_pseudo_id
  WHERE 
    -- Target için tablo aralığını 1 ay daha geniş tutuyoruz ki son gün girenlerin de 30 günü dolsun
    e._TABLE_SUFFIX BETWEEN '20180101' AND '20181231'
    AND e.event_timestamp >= c.first_open_timestamp
    AND e.event_timestamp <= c.first_open_timestamp + 2592000000000
  GROUP BY 
    c.user_pseudo_id
)

-- 4. BİRLEŞTİRME
SELECT 
  f.user_pseudo_id,
  f.traffic_source,
  f.d3_total_events,
  f.d3_levels_completed,
  f.d3_errors,
  COALESCE(f.d3_max_score, 0) AS d3_max_score,
  COALESCE(t.target_roas_d30, 0) AS target_roas_d30
FROM 
  d3_features f
LEFT JOIN 
  d30_target t ON f.user_pseudo_id = t.user_pseudo_id;