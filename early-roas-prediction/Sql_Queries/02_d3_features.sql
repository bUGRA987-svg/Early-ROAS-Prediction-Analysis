/* ===================================================================
Script Name: 02_d3_features.sql
Author: Buğra
Description: Bu sorgu, Day 0 referans noktasını alarak kullanıcıların 
             ilk 3 gün (72 saat) içindeki davranışsal özelliklerini 
             hesaplar. XGBoost modelimizin girdi (Feature) matrisidir.
Dataset: firebase-public-project.analytics_153293282.events_*
=================================================================== */

WITH user_cohort AS (
  -- Adım 1: Kullanıcıların oyuna ilk girdikleri anı (T=0) buluyoruz
  SELECT 
    user_pseudo_id,
    MIN(event_timestamp) AS first_open_timestamp
  FROM 
    `firebase-public-project.analytics_153293282.events_*`
  WHERE 
    event_name = 'first_open'
    AND _TABLE_SUFFIX BETWEEN '20180701' AND '20180831'
  GROUP BY 
    user_pseudo_id
)

SELECT 
  c.user_pseudo_id,
  
  -- Özellik 1: İlk 3 günde toplam kaç olay (event) tetikledi? (Uygulama İçi Etkileşim)
  COUNT(e.event_name) AS d3_total_events,
  
  -- Özellik 2: Kaç kere bölüm bitirdi? (Oyun İlerlemesi)
  COUNTIF(e.event_name = 'level_complete_quickplay') AS d3_levels_completed,
  
  -- Özellik 3: Oyunda kaç kere hata (crash/exception) yaşadı? (Teknik Sorunlar)
  COUNTIF(e.event_name = 'app_exception') AS d3_errors,
  
  -- Özellik 4: (Senior Dokunuşu - UNNEST) Nested veriden 'score' parametresini çekmek
  -- event_params içindeki diziyi açıp (UNNEST), key değeri 'score' olanların int_value'sunu alıyoruz.
  MAX((SELECT value.int_value FROM UNNEST(e.event_params) WHERE key = 'score')) AS d3_max_score

FROM 
  user_cohort c
JOIN 
  `firebase-public-project.analytics_153293282.events_*` e
ON 
  c.user_pseudo_id = e.user_pseudo_id
WHERE 
  e._TABLE_SUFFIX BETWEEN '20180701' AND '20180831'
  -- KRONOMETRE KURALI: 
  -- Olay zamanı, kullanıcının ilk açılışından (T=0) büyük olmalı.
  -- 3 Gün = 3 * 24 * 60 * 60 * 1.000.000 = 259.200.000.000 mikrosaniye
  AND e.event_timestamp >= c.first_open_timestamp
  AND e.event_timestamp <= c.first_open_timestamp + 259200000000
GROUP BY 
  c.user_pseudo_id
LIMIT 50; -- Test için şimdilik 50 satır getiriyoruz
