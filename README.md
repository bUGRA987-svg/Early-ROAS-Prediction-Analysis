# Early-ROAS-Prediction-Analysis
Predicting 30-day LTV and ROAS using early user behavior (D3) with BigQuery &amp; XGBoost.

#  Early ROAS Prediction & LTV Modeling for Mobile Gaming

![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)
![BigQuery](https://img.shields.io/badge/Google_BigQuery-SQL-yellow.svg)
![XGBoost](https://img.shields.io/badge/XGBoost-Machine_Learning-green.svg)
![Status](https://img.shields.io/badge/Status-Completed-success.svg)

##  Proje Özeti (Business Context)
Ajans bünyesinde çalıştığımız bir mobil oyun müşterimiz için, pazarlama bütçesini daha verimli kullanabilmek adına geliştirilmiş uçtan uca (end-to-end) bir makine öğrenmesi ve veri mühendisliği projesidir.

**Sorun:** Müşterimiz, hangi reklam kanalının gerçekten kârlı olduğunu anlamak için 30 gün beklemek zorundaydı. Bu durum, bütçenin verimsiz harcanmasına ve kârsız kampanyaların gereksiz yere açık kalmasına neden oluyordu.
**Çözüm:** Kullanıcıların oyunu indirdikleri andan itibaren **ilk 72 saat (Day 3)** içindeki davranışlarını analiz ederek, **30. gün (Day 30)** sonundaki satın alma (ROAS - LTV) potansiyellerini önceden tahmin eden bir sistem kurgulanmıştır.

> **Gizlilik Notu:** Müşteri gizliliğini (KVKK/GDPR) korumak adına tüm kullanıcı kimlikleri (user_pseudo_id) ve hassas iş metrikleri maskelenmiş/anonimize edilmiştir. Proje, kişisel verilerden ziyade tamamen davranışsal örüntülere odaklanmaktadır.

---

##  Kullanılan Teknolojiler
* **Veri Ambarı & SQL:** Google BigQuery, Standard SQL (Nested Records, CTEs, Window Functions)
* **Veri Manipülasyonu:** Pandas, NumPy
* **Makine Öğrenmesi:** XGBoost (eXtreme Gradient Boosting), Scikit-Learn
* **Veri Görselleştirme:** Matplotlib, Seaborn

---

##  Veri Boru Hattı (Data Pipeline) ve Mimari

Firebase Analytics üzerinden akan saniyelik loglar (NoSQL yapısı), BigQuery üzerinde SQL ile işlenerek düz (tabular) bir makine öğrenmesi matrisine dönüştürülmüştür.

1. **Zaman Makinesi (Cohort Analysis):** Milyonlarca log taranarak her kullanıcının oyunu ilk açtığı `first_open` anı (T=0) mikrosaniye cinsinden tespit edildi.
2. **Özellik Çıkarımı (Feature Engineering):** BigQuery'nin `UNNEST` fonksiyonu kullanılarak iç içe geçmiş (nested) JSON formatındaki loglardan anlamlı özellikler çıkarıldı.
   * `d3_total_events`: Toplam uygulama içi etkileşim.
   * `d3_levels_completed`: İlk 3 günde geçilen bölüm sayısı.
   * `d3_errors`: Karşılaşılan teknik hatalar (`app_exception`).
   * `d3_max_score`: Rekabetçilik göstergesi olan maksimum skor.
3. **Hedef Değişken (Target Labeling):** 30. günün sonunda `in_app_purchase` (uygulama içi satın alma) yapan kullanıcılar `1`, yapmayanlar `0` olarak etiketlendi.

---

##  Makine Öğrenmesi Yaklaşımı ve Zorluklar

Mobil oyun dünyasının en büyük gerçeği olan **"Aşırı Dengesiz Veri" (Highly Imbalanced Dataset)** bu projenin temel zorluğuydu. Kullanıcıların %1'inden azı harcama yapma (balina) eğilimindeydi.

* **Algoritma Seçimi:** Dengesiz verilerdeki üstün performansı sebebiyle **XGBoost Classifier** tercih edildi.
* **Optimizasyon:** Sınıf dengesizliğini çözmek için XGBoost modeline hiperparametre olarak otomatik hesaplanan `scale_pos_weight` uygulandı.
* **Metrik Seçimi:** Sistem %99 oranında "0" sınıfından oluştuğu için yanıltıcı olan *Accuracy* (Doğruluk) metriği yerine, işletme hedeflerine uygun olarak **Precision-Recall (Kesinlik-Duyarlılık)** ve **PR-AUC** metriklerine odaklanıldı.

---

##  Depo Yapısı (Repository Structure)

```text
Early-ROAS-Prediction/
│
├── sql_queries/               # BigQuery veri mühendisliği sorguları
│   ├── 01_user_cohort.sql     # T=0 anının tespiti
│   ├── 02_d3_features.sql     # D3 davranışsal özellik çıkarımı (UNNEST)
│   ├── 03_target_roas.sql     # D30 satın alma durumu (Hedef)
│   └── 04_master_table.sql    # Nihai ML matrisinin birleştirilmesi
│
├── notebooks/                 # Keşifsel Veri Analizi ve Modelleme
│   └── Early_roas_prediction_model.ipynb
│
├── data/                      # Model şablonunu göstermek için maskelenmiş sample veri
│   └── 04_master_table.csv
│
└── README.md

```

**Sonuç ve İş Etkisi:**
Bu modelleme çalışması, pazarlama ve büyüme (Growth) ekiplerine şu yetenekleri kazandırmayı hedefler:

Kampanya kalitesini 30 gün yerine 3. günün sonunda değerlendirebilmek.

Düşük ROAS getirecek reklam kanallarını erkenden kapatıp bütçe israfını önlemek.

"Potansiyel alıcı" olarak tahmin edilen kullanıcılara özel oyun içi teklifler (in-app offers) sunarak dönüşüm oranlarını (Conversion Rate) artırmak.

Geliştirici: Buğra Avsar
Linkedin : https://www.linkedin.com/in/bugra-avsar/


