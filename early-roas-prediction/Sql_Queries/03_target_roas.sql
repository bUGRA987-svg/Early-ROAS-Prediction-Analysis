 ===================================================================
Script Name 03_target_roas.sql
Author Buğra
Description Bu sorgu, Day 0 referans noktasını alarak kullanıcıların 
             ilk 30 gün içindeki satın alma davranışlarını hesaplar. 
             Eğer kullanıcı 30 gün içinde satın alma yapmışsa 'target_roas = 1', 
             yapmamışsa '0' değerini alır.
Dataset firebase-public-project.analytics_153293282.events_
=================================================================== 

WITH user_cohort AS (
  SELECT 
    user_pseudo_id,
    MIN(event_timestamp) AS first_open_timestamp
  FROM 
    `firebase-public-project.analytics_153293282.events_`
  WHERE 
    event_name = 'first_open'
    AND _TABLE_SUFFIX BETWEEN '20180701' AND '20180831'
  GROUP BY 
    user_pseudo_id
)

SELECT 
  c.user_pseudo_id,
  
  -- Hedef Değişken (Y) Kullanıcı ilk 30 günde 'in_app_purchase' yaptı mı
  -- Yaptıysa 1 (Kârlı), yapmadıysa 0 (Zarar).
  MAX(IF(e.event_name = 'in_app_purchase', 1, 0)) AS target_roas_d30

FROM 
  user_cohort c
JOIN 
  `firebase-public-project.analytics_153293282.events_` e
ON 
  c.user_pseudo_id = e.user_pseudo_id
WHERE 
  e._TABLE_SUFFIX BETWEEN '20180701' AND '20180930' -- D30'u kapsayacak kadar tablo süresini uzattık
  
  -- KRONOMETRE KURALI 
  -- Olay zamanı, kullanıcının ilk açılışından büyük olmalı.
  -- 30 Gün = 30  24  60  60  1.000.000 = 2.592.000.000.000 mikrosaniye
  AND e.event_timestamp = c.first_open_timestamp
  AND e.event_timestamp = c.first_open_timestamp + 2592000000000
GROUP BY 
  c.user_pseudo_id
LIMIT 50;
