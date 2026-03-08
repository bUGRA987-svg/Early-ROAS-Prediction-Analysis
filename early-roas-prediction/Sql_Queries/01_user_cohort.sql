/* ===================================================================
Script Name: 01_user_cohort.sql
Author: Buğra
Description: Bu sorgu, kullanıcıların uygulamayı ilk kez açtıkları 
             zamanı (Day 0) bulur. Bu tarih damgası (timestamp), ilk 3 günlük (D3) 
             davranış pencerelerini ve 30 günlük (D30) ROAS/LTV hedeflerini 
             hesaplamak için referans noktamız (anchor) olacaktır.
Dataset: firebase-public-project.analytics_153293282.events_*
=================================================================== */

SELECT 
  user_pseudo_id,
  MIN(event_date) AS install_date,
  MIN(event_timestamp) AS first_open_timestamp
FROM 
  `firebase-public-project.analytics_153293282.events_*`
WHERE 
  event_name = 'first_open'
  -- MALIYET VE ZAMAN KONTROLÜ: 
  -- Modeli eğitmek için 2018 Temmuz ve Ağustos aylarını (2 ay) alıyoruz.
  AND _TABLE_SUFFIX BETWEEN '20180701' AND '20180831'
GROUP BY 
  user_pseudo_id;