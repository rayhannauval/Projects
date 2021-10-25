-- Data source adalah rekap data mahasiswa dan mata kuliah tambahan. 
-- Data source yang diupload pada github telah dinormalisasi untuk mengurangi redudansi. Hasil normalisasi data adalah tiga table
-- dengan judul mahasiswa, mata_kuliah, dan nilai.
-- Beberapa insight yang bisa didapat melalui project ini, terkait dengan demografi mahasiswa, dan kondisi pembelajaran mahasiswa tersebut.
-- Query dilakukan menggunakan software SQL Server 2019 dan Microsoft SQL Server Management Studio 18.

------------------------------------------------------------ Update pembobotan nilai akhir
UPDATE dbo.nilai$
SET na = 0.4 * uts + 0.6 * uas;

------------------------------------------------------------ Demografi mahasiswa: distribusi jenis kelamin, daerah asal, umur
with umur_jk as (
select DATEDIFF(year,ttl,GETDATE()) as umur, jk, nim
from dbo.mahasiswa$)

select concat(b.nama_depan, ' ', b.nama_belakang) as nama_lengkap, a.umur, b.alamat, b.jk from umur_jk as a
inner join dbo.mahasiswa$ as b
on a.nim = b.nim
order by nama_lengkap asc

------------------------------------------------------------ Jumlah mahasiswa yang mengambil mata kuliah pilihan
select a.kode_mk, b.mk, count(a.nim) as jumlah_mahasiswa
from dbo.nilai$ as a
inner join dbo.mata_kuliah$ as b
on a.kode_mk= b.kode_mk
group by a.kode_mk, b.mk


------------------------------------------------------------ Mmengetahui semester berjalan tiap mahasiswa
select a.nim, 
concat(c.nama_depan, ' ', c.nama_belakang) as nama_lengkap, 
max(b.semester) as semester_berjalan
from dbo.nilai$ as a
inner join
dbo.mata_kuliah$ as b
on a.kode_mk = b.kode_mk
	inner join
	dbo.mahasiswa$ as c
	on a.nim = c.nim
group by a.nim, c.nama_depan, c.nama_belakang

------------------------------------------------------------ Mencari nilai rata-rata kelas per mata - kuliah
select b.mk, round(avg(a.na), 2) as avg_na
from dbo.nilai$ as a
left join dbo.mata_kuliah$ as b
on a.kode_mk = b.kode_mk
	left join dbo.mahasiswa$ as c
	on a.nim = c.nim
group by b.kode_mk, b.mk

------------------------------------------------------------ Mencari mahasiswa yang memiliki nilai akhir kurang dari rata-rata, per mata kuliah
with average_nilai_mk as (
select round(avg(na), 1) as average_nilai_mk, kode_mk from dbo.nilai$ group by kode_mk)

select b.mk as mata_kuliah, concat(c.nama_depan, ' ', c.nama_belakang) as nama_lengkap, a.nim, average_nilai_mk, a.na as nilai_akhir_mahasiswa
from dbo.nilai$ as a
inner join
dbo.mata_kuliah$ as b
on a.kode_mk = b.kode_mk
	inner join dbo.mahasiswa$ as c
	on a.nim = c.nim
		inner join average_nilai_mk as d
		on b.kode_mk = d.kode_mk
where na < average_nilai_mk
order by b.mk asc

------------------------------------------------------------ Mencari mahasiswa yang nilainya mengalami penurunan
with average_nilai_mk as (
select avg(na) as average_nilai_mk, kode_mk from dbo.nilai$ group by kode_mk)

select b.mk as mata_kuliah, concat(c.nama_depan, ' ', c.nama_belakang) as nama_lengkap, a.nim, a.uts, a.uas, a.na as nilai_akhir_mahasiswa
from dbo.nilai$ as a
inner join
dbo.mata_kuliah$ as b
on a.kode_mk = b.kode_mk
	inner join dbo.mahasiswa$ as c
	on a.nim = c.nim
		inner join average_nilai_mk as d
		on b.kode_mk = d.kode_mk
where uas - uts < 0
order by b.mk asc

------------------------------------------------------------ Mencari mahasiswa yang memiliki nilai C lebih dari 1
select a.nim, concat(b.nama_depan, ' ', b.nama_belakang) as nama_lengkap
from dbo.nilai$ as a
left join dbo.mahasiswa$ as b
on a.nim = b.nim
	left join dbo.mata_kuliah$ as c
	on a.kode_mk = c.kode_mk
group by a.nim, a.hm, b.nama_belakang, b.nama_depan
HAVING COUNT(a.hm) > 1 and a.hm = 'C'