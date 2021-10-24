-- Data source adalah rekap transaksi sebuah hotel bulan Juni 2018 - Agustus 2020. Data terdiri dari 25 column dan 98.252 row. 
-- Data yang diupload pada github telah dinormalisasi untuk mengurangi redudansi. Hasil normalisasi data adalah lima table
-- dengan judul customer_record_2018, customer_record_2019, customer_record_2020, meal_cost, serta market_segment.
-- Beberapa pertanyaan yang bisa dijawab melalui project ini: 
-- (1.) Bagaimana karakteristik customer hotel? 
-- (2.) Bagaimana pertumbuhan revenue hotel? 
-- (3.) Strategi bisnis apa yang bisa diambil dari data source?
-- Query dilakukan menggunakan software SQL Server 2019 dan Microsoft SQL Server Management Studio 18, kemudian divisualisasikan melalui Tableu Public.
-- Nama table pada file ini disamakan dengan judul grafik yang ditampilkan pada Tableu, untuk memudahkan pembacaan.

------------------------------------------------------------ Part 1: Customer Insight
------------------------------------------------------------ Visitor Age Distribution vs Date
-- Identifikasi distribusi umur visitor per satuan waktu perlu dilakukan, agar hotel dapat memaksimalkan kapasitas hotel dan strategi lainnya. 
with customer_record as (
select * from dbo.customer_record_2018$
union
select * from dbo.customer_record_2019$
union
select * from dbo.customer_record_2020$)

-- Syntax with as (union) digunakan untuk membuat temporary data, berisi gabungan dari table dbo.customer_record_2018$, dbo.customer_record_2019$, dbo.customer_record_2020$.
-- Pembuatan temporary table customer_record banyak digunakan pada project ini, untuk mengefektifkan query.

select sum(adults) as adults_count, sum(children) as children_count, sum(babies) as babies_count, concat(arrival_date_month, ' ', arrival_date_year) as arrival
from customer_record
where is_canceled = 0
group by arrival_date_month, arrival_date_year


------------------------------------------------------------ Customer Distribution
-- Pemetaan mengenai negara asal customer perlu dilakukan untuk memaksimalkan marketing strategis. 

with customer_record as (
select * from dbo.customer_record_2018$
union
select * from dbo.customer_record_2019$
union
select * from dbo.customer_record_2020$)

select country,
count(country) as customer_amount
from customer_record as cr
left join dbo.market_segment$ as ms
on cr.market_segment = ms.market_segment
		left join meal_cost$ as mc
		on cr.meal = mc.meal
where is_canceled = 0
group by country


------------------------------------------------------------ Booking vs Cancellation
-- Perbandingan terkait jumlah pemesanan dan pembatalan perlu dilakukan. Apabila selisih keduanya 
-- semakin menipis, perlu diidentifikasi penyebabnya berdasarkan data waktu yang diberikan.

with customer_record as (
select * from dbo.customer_record_2018$
union
select * from dbo.customer_record_2019$
union
select * from dbo.customer_record_2020$)

select count(is_canceled) as total_booking,
sum(is_canceled) as book_cancellation,
arrival_date_year as year
from customer_record
group by arrival_date_year
order by year desc


------------------------------------------------------------ Marketing Channel vs Customer Amount
-- Identifikasi jenis Marketing Channel yang berpartisipasi besar dalam menarik customer.

with customer_record as (
select * from dbo.customer_record_2018$
union
select * from dbo.customer_record_2019$
union
select * from dbo.customer_record_2020$)

select count(market_segment) as total_booking,
market_segment as market_channel,
arrival_date_year 
from customer_record
group by market_segment, arrival_date_year


------------------------------------------------------------ Room Type vs Customer Type
-- Tipe customer memiliki kecenderungan untuk memilih tipe ruangan tertentu. Pemetaan kedua variable tersebut dapat membantu hotel untuk menyiapkan akomodasi yang cukup 
-- untuk menampung customer.

with customer_record as (
select * from dbo.customer_record_2018$
union
select * from dbo.customer_record_2019$
union
select * from dbo.customer_record_2020$)

select count(reserved_room_type) as room_count,
reserved_room_type,
customer_type 
from customer_record
group by reserved_room_type, customer_type


------------------------------------------------------------ Customer Type vs Customer Amount vs Date
-- Pertumbuhan jumlah customer pada masing-masing kelompok customer perlu dipetakan sebagai salah satu insight dalam menentukan business decision.

with customer_record as (
select * from dbo.customer_record_2018$
union
select * from dbo.customer_record_2019$
union
select * from dbo.customer_record_2020$)

select 
count(customer_type) as customer_type_count,
customer_type,
hotel,
concat(arrival_date_month,' ', arrival_date_year) as arrival
from customer_record
group by customer_type, arrival_date_month, arrival_date_year, hotel


------------------------------------------------------------ Car Amount vs Customer Type vs Date
-- Ketersediaan lahan parkir mempengaruhi kapasitas hotel untuk menampung calon customer. Sehingga perlu melakukan rincian waktu mengenai kapan 
-- hotel harus menyediakan lahan parkir yang cukup. Grafik menunjukkan bahwa terdapat tipe customer yang paling sering membawa kendaraan mobil, pada waktu tertentu.

with customer_record as (
select * from dbo.customer_record_2018$
union
select * from dbo.customer_record_2019$
union
select * from dbo.customer_record_2020$)

select 
count(hotel) as vehicle_count,
concat(arrival_date_month,' ', arrival_date_year) as arrival,
customer_type
from customer_record
where required_car_parking_spaces = 1 and is_canceled = 0
group by customer_type, arrival_date_month, arrival_date_year


------------------------------------------------------------ Priority Customer vs Hotel vs Date
-- Identifikasi Priority Customer. Berdasarkan kebijakan manajemen, Priority Customer memiliki syarat: tidak melakukan pembatalan booking, dan memiliki jumlah malam menginap 
-- lebih tinggi dari rata-rata tiap hotel.

with customer_record as (
select * from dbo.customer_record_2018$
union
select * from dbo.customer_record_2019$
union
select * from dbo.customer_record_2020$)

select 
count(hotel) as priority_customer_amount,
hotel,
concat(arrival_date_month,' ', arrival_date_year) as arrival
from customer_record
where (stays_in_week_nights+stays_in_weekend_nights) > (select avg(stays_in_week_nights+stays_in_weekend_nights) from customer_record) and is_canceled = 0
group by customer_type, arrival_date_month, arrival_date_year, hotel


------------------------------------------------------------ Part 2: Revenue and Operation
------------------------------------------------------------ Meal Revenue vs Room Revenue vs Date
-- Perbandingan pertumbuhan revenue hotel berdasarkan ruangan dan paket makanan per satuan waktu.  
with customer_record as (
select * from dbo.customer_record_2018$
union
select * from dbo.customer_record_2019$
union
select * from dbo.customer_record_2020$)

select hotel,
((stays_in_week_nights+stays_in_weekend_nights)*adr)*(1-Discount) as room_revenue,
(Cost*(stays_in_week_nights+stays_in_weekend_nights))*(1-Discount) as meal_revenue,
reservation_status_date
from customer_record as cr
left join dbo.market_segment$ as ms
on cr.market_segment = ms.market_segment
		left join meal_cost$ as mc
		on cr.meal = mc.meal
where is_canceled = 0
order by reservation_status_date asc


------------------------------------------------------------ Market Channel vs Revenue vs Date
-- Identifikasi jenis Market Channel yang paling berpartisipasi dalam memperoleh pendapatan hotel.

with customer_record as (
select * from dbo.customer_record_2018$
union
select * from dbo.customer_record_2019$
union
select * from dbo.customer_record_2020$)

select hotel,
ms.market_segment,
((stays_in_week_nights+stays_in_weekend_nights)*adr)+(Cost*(stays_in_week_nights+stays_in_weekend_nights))*(1-Discount) as revenue,
concat(arrival_date_month,' ', arrival_date_year) as arrival
from customer_record as cr
left join dbo.market_segment$ as ms
on cr.market_segment = ms.market_segment
		left join meal_cost$ as mc
		on cr.meal = mc.meal
where is_canceled = 0


------------------------------------------------------------ Revenue vs Time
-- Perbandingan pertumbuhan total revenue hotel per satuan waktu.  

with customer_record as (
select * from dbo.customer_record_2018$
union
select * from dbo.customer_record_2019$
union
select * from dbo.customer_record_2020$)

select hotel,
((stays_in_week_nights+stays_in_weekend_nights)*adr)+(Cost*(stays_in_week_nights+stays_in_weekend_nights))*(1-Discount) as revenue,
reservation_status_date
from customer_record as cr
left join dbo.market_segment$ as ms
on cr.market_segment = ms.market_segment
		left join meal_cost$ as mc
		on cr.meal = mc.meal
where is_canceled = 0
order by reservation_status_date asc

-- Berdasarkan data-data yang dikumpulkan diatas, diketahui bahwa: 
-- (1.) Visitor dari hotel tersebut didominasi oleh golongan customer yang tergolong 
-- usia dewasa, serta tergolong customer berkewarganegraan Portugal. Diketahui juga bahwa tipe costumer yang paling berpartisipasi dalam revenue hotel adalah tipe Transient.
-- (2.) Revenue total hotel mengalami cenderung fluktuatif, meskipun relatif memiliki tren meningkat setiap taunnya. 
-- Berdasarkan rekap revenue yang dilakukan, diperkirakan revenue hotel akan menurun hingga awal tahun 2021, dan tetap memiliki tren relatif meningkat 
-- hingga pertengahan tahun 2021. 
-- (3.) Strategi bisnis yang dapat dilakukan berasal dari beberapa perspektif: 
-- Pendekatan Costumer, Strategi Marketing, kontrol Product sampingan, dan peningkatan fasilitas. Dari segi pendekatan customer, hotel dapat memberikan promosi lebih kepada 
-- "Priority Customer", khususnya di Q2 - Q3 pertengahan tahun dimana jumlah customer tersebut diproyeksikan mencapai puncak. Dari segi marketing, 
-- diketahui bahwa pendekatan melalui Online TA selalu menghasilkan jumlah customer dan revenue paling tinggi terhadap hotel. Peningkatan revenue juga 
-- dapat dilakukan melalui kontrol paket makan yang disediakan hotel. Dapat berarti peningkatan kualitas makanan, kontrol harga, dsb. Meskipun memerlukan analisis lebih 
-- lanjut mengenai korelasi dua variable tersebut, diketahui bahwa peningkatan revenue dari sevice makanan memiliki tren serupa dengan 
-- revenue penyewaan ruangan. Peningkatan revenue melalui perspektif operasi, dapat dilakukan melalui pembukaan lahan parkir tambahan. Khususnya pada Q3 - Q4 
-- akhir tahun yang memiliki peningkatan jumlah mobil secara ekstrem.

-- Penjabaran mengenai karakteristik customer, laporan keuangan, serta strategi bisnis yang disebutkan diatas memerlukan identifikasi statistik lebih mendalam. 
-- Insight yang diambil dari projek ini dapat memberikan gambaran awal mengenai business decision yang perlu diambil oleh pihak manajemen hotel.