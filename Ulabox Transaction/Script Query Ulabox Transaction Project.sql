-- Data source adalah rekap transaksi sebuah platform retail online Ulabox. Data terdiri dari 14 column dan 30.000 row. 
-- Data yang diupload pada github telah dinormalisasi untuk mengurangi redudansi. Hasil normalisasi data adalah tiga table
-- dengan judul discount, purchase_percentage, dan purchase_time.
-- Beberapa insight yang bisa didapat melalui project ini: 
-- (1.) Customer Behaviour
-- (2.) Operation
-- Query dilakukan menggunakan software SQL Server 2019 dan Microsoft SQL Server Management Studio 18.

------------------------------------------------------------ Part 1: Customer Behaviour
------------------------------------------------------------ Jumlah Transaksi per Customer

select
distinct customer,
count(customer) as transaction_count
from dbo.purchase_time$
group by customer
order by customer asc

------------------------------------------------------------ Klasifikasi Customer
-- Pihak manajerial Ulabox mengklasifikasikan customer menjadi kelompok Premium, Gold, Silver, dan Economy. Kelompok tersebut dapat menjadi acuan 
-- strategis untun pengembangan bisnis, seperti dalam hal pembagian discount dan purna jual.

with customer_table as(
select sum(a.total_items) as total_items_sold, b.customer
from dbo.purchase_percentage$ as a
left join dbo.purchase_time$ as b
on a.transaction_id = b.transaction_id
	left join dbo.discount$ as c
	on a.transaction_id = c.transaction_id
group by b.customer)

select customer_table.customer,
case when total_items_sold >= 200 then 'Premium'
         when total_items_sold >= 100 and total_items_sold < 200 then 'Gold'
         when total_items_sold >= 50 and total_items_sold < 100 then 'Silver'
         else 'Economy' end as customer_type
from customer_table
order by customer_table.customer asc

------------------------------------------------------------ Presentase Jenis Barang yang dibeli Customer
-- Presentase jenis barang yang dibeli masing-masing customer. Membantu memberikan insight mengenai Market Segmenting, Targeting, Positioning.

select b.customer,
sum(a.total_items) as total_items,
sum(a.[Food%])/count(b.customer) as total_food_percent,
sum(a.[Fresh%])/count(b.customer) as total_fresh_percent,
sum(a.[Drinks%])/count(b.customer) as total_drinks_percent,
sum(a.[Home%])/count(b.customer) as total_home_percent,
sum(a.[Beauty%])/count(b.customer) as total_beauty_percent,
sum(a.[Health%])/count(b.customer) as total_health_percent,
sum(a.[Baby%])/count(b.customer) as total_baby_percent,
sum(a.[Pets%])/count(b.customer) as total_pets_percent
from dbo.purchase_percentage$ as a
left join purchase_time$ as b
on a.transaction_id = b.transaction_id
group by b.customer
order by b.customer asc

------------------------------------------------------------ Jumlah Barang yang dibeli Customer
-- Jumlah barang yang dibeli oleh customer. Membantu memberikan insight mengenai Market Segmenting, Targeting, Positioning.

select
b.customer,
round((sum(a.[Food%]/100*a.total_items)), 0) as food_sold,
round((sum(a.[Fresh%]/100*a.total_items)), 0)as fresh_sold,
round((sum(a.[Drinks%]/100*a.total_items)), 0) as drinks_sold,
round((sum(a.[Home%]/100*a.total_items)), 0) as home_sold,
round((sum(a.[Beauty%]/100*a.total_items)), 0) as beauty_sold,
round((sum(a.[Health%]/100*a.total_items)), 0) as health_sold,
round((sum(a.[Baby%]/100*a.total_items)), 0) as baby_sold,
round((sum(a.[Pets%]/100*a.total_items)), 0) as pets_sold
from dbo.purchase_percentage$ as a
left join dbo.purchase_time$ as b
on a.transaction_id = b.transaction_id
group by b.customer
order by b.customer asc

------------------------------------------------------------ Identifikasi Customer Prioritas
-- Manajemen Ulabox perlu memetakan customer mana saja yang termasuk kelompok prioritas. 

with transaction_count as (
select customer, count(customer) as amount
from dbo.purchase_time$
group by customer)

select b.customer, a.amount
from transaction_count as a
left join dbo.purchase_time$ as b
on a.customer = b.customer
	left join dbo.purchase_percentage$ as c
	on b.transaction_id = c.transaction_id
where amount > (select avg(amount) from transaction_count) and total_items > (select avg(total_items) from dbo.purchase_percentage$)
group by b.customer, a.amount
order by b.customer asc

------------------------------------------------------------ Rata-rata discount yang diberikan untuk tiap costumer
-- Identifikasi pengaruh discount sebagai strategi marketing terhadap respon customer.

select
avg(a.[discount%]) as avg_discount, customer
from dbo.discount$ as a
left join purchase_time$ as b
on a.transaction_id= b.transaction_id
group by customer
order by customer asc

------------------------------------------------------------ Part 2: Operation and Business
------------------------------------------------------------ Jumlah pengeluaran produk per waktu
-- Identifikasi pengaruh discount sebagai strategi marketing terhadap respon customer.

select
b.weekday,
round((sum(a.[Food%]/100*a.total_items)), 0) as food_sold,
round((sum(a.[Fresh%]/100*a.total_items)), 0) as fresh_sold,
round((sum(a.[Drinks%]/100*a.total_items)), 0) as drinks_sold,
round((sum(a.[Home%]/100*a.total_items)), 0) as home_sold,
round((sum(a.[Beauty%]/100*a.total_items)), 0) as beauty_sold,
round((sum(a.[Health%]/100*a.total_items)), 0) as health_sold,
round((sum(a.[Baby%]/100*a.total_items)), 0) as baby_sold,
round((sum(a.[Pets%]/100*a.total_items)), 0) as pets_sold
from dbo.purchase_percentage$ as a
left join dbo.purchase_time$ as b
on a.transaction_id = b.transaction_id
group by b.weekday

------------------------------------------------------------ Pertumbuhan rata-rata penjualan items per hari
-- Mengidentidikasi peningkatan/penurunan jumlah item
-- Jumlah transaksi per waktu
select
b.weekday,
b.hour,
count(a.transaction_id) as transaction_amount
from dbo.purchase_percentage$ as a
left join dbo.purchase_time$ as b
on a.transaction_id = b.transaction_id
group by b.weekday, b.hour
order by b.weekday asc, b.hour asc


------------------------------------------------------------ Jumlah transaksi per hari
-- Mengidentidikasi total transaksi per hari. Dapat diketahui bahwa customer cenderung banyak melakukan transaksi pada hari senin.

select
b.weekday,
count(a.transaction_id) as transaction_amount
from dbo.purchase_percentage$ as a
left join dbo.purchase_time$ as b
on a.transaction_id = b.transaction_id
group by b.weekday
order by b.weekday asc
