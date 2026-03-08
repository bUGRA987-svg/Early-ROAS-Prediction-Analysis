# Early-ROAS-Prediction-Analysis
Predicting 30-day LTV and ROAS using early user behavior (D3) with BigQuery &amp; XGBoost.

**Veriyle Geleceği Görmek**: Mobil Oyunlarda D30 ROAS Tahminlemesi

Ajans bünyesinde çalıştığımız bir mobil oyun müşterimiz için, pazarlama bütçesini daha verimli kullanabilmek adına heyecan verici bir 'Early Prediction' projesini tamamladık.

Sorun: Müşterimiz, hangi reklam kanalının gerçekten kârlı olduğunu anlamak için 30 gün beklemek zorundaydı. Bu da bütçenin verimsiz harcanmasına neden olabiliyordu.

Çözüm: Google BigQuery üzerinde milyonlarca satır ham Firebase logunu işleyerek bir veri boru hattı kurduk. Kullanıcıların oyunu indirdikleri andan itibaren ilk 72 saat içindeki davranışlarını (tamamlanan bölümler, teknik hatalar, rekabetçi skorlar) anlamlı metrikler haline getirdik.

Teknik Zorluk: Mobil oyun dünyasının gerçeği olan 'aşırı dengesiz veri' (kullanıcıların %1'inden azının harcama yapması) ile karşılaştık. XGBoost modelimizi scale_pos_weight ve Precision-Recall optimizasyonlarıyla eğiterek, sistemin 'balina' kullanıcıları tespit etme kapasitesini artırdık.

Sonuç: Bu model sayesinde, henüz 3. günün sonunda hangi kullanıcı kitlesinin kârlı olacağını tahmin edebilir hale geldik. Bu, müşterimize reklam kampanyalarını gerçek zamanlı olarak optimize etme ve zarar eden kanalları anında kapatma imkanı sağladı.

Veri odaklı pazarlama, sadece harcamak değil, nereye harcayacağını önceden bilmektir! 
