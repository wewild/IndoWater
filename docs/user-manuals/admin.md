# Manual Pengguna IndoWater - Admin

## Daftar Isi
1. [Pendahuluan](#pendahuluan)
2. [Memulai](#memulai)
3. [Login dan Autentikasi](#login-dan-autentikasi)
4. [Dashboard Admin](#dashboard-admin)
5. [Manajemen Pengguna](#manajemen-pengguna)
6. [Manajemen Meter Air](#manajemen-meter-air)
7. [Manajemen Transaksi](#manajemen-transaksi)
8. [Laporan dan Analitik](#laporan-dan-analitik)
9. [Pengaturan Sistem](#pengaturan-sistem)
10. [Manajemen Konten](#manajemen-konten)
11. [Dukungan Teknis](#dukungan-teknis)

## Pendahuluan

Selamat datang di Panel Admin IndoWater! Panel ini dirancang untuk memudahkan administrator dalam mengelola seluruh aspek sistem IndoWater, termasuk pengguna, meter air, transaksi, dan pengaturan sistem.

### Peran dan Tanggung Jawab Admin
- Mengelola akun pengguna
- Memantau dan mengelola meter air
- Memverifikasi dan mengelola transaksi
- Menganalisis data penggunaan dan transaksi
- Mengonfigurasi pengaturan sistem
- Mengelola konten aplikasi dan situs web
- Memberikan dukungan teknis kepada pengguna

## Memulai

### Persyaratan Sistem
- Komputer dengan sistem operasi Windows 10/11, macOS 10.15+, atau Linux
- Browser web modern (Google Chrome, Mozilla Firefox, Microsoft Edge, atau Safari versi terbaru)
- Koneksi internet yang stabil
- Resolusi layar minimal 1366 x 768 piksel

### Mengakses Panel Admin
1. Buka browser web Anda
2. Kunjungi https://admin.indowater.com
3. Masukkan kredensial login Anda

## Login dan Autentikasi

### Login ke Panel Admin
1. Kunjungi https://admin.indowater.com
2. Masukkan nama pengguna (username) dan kata sandi (password) Anda
3. Klik tombol "Masuk"
4. Jika diminta, masukkan kode autentikasi dua faktor (2FA) yang dikirim ke perangkat Anda

### Autentikasi Dua Faktor (2FA)
1. Setelah memasukkan nama pengguna dan kata sandi, Anda akan diminta untuk memasukkan kode 2FA
2. Buka aplikasi autentikator di smartphone Anda (Google Authenticator, Microsoft Authenticator, atau Authy)
3. Masukkan kode 6 digit yang ditampilkan di aplikasi
4. Klik tombol "Verifikasi"

### Mengatur Ulang Kata Sandi
1. Di halaman login, klik "Lupa Kata Sandi"
2. Masukkan alamat email yang terkait dengan akun admin Anda
3. Klik tombol "Kirim Tautan Reset"
4. Periksa email Anda untuk tautan reset kata sandi
5. Klik tautan tersebut dan ikuti petunjuk untuk membuat kata sandi baru

## Dashboard Admin

Dashboard admin adalah halaman utama yang menampilkan ringkasan informasi penting tentang sistem IndoWater.

### Elemen Dashboard
- **Ringkasan Statistik**: Jumlah pengguna aktif, meter air terdaftar, transaksi hari ini, dan pendapatan
- **Grafik Penggunaan Air**: Visualisasi penggunaan air harian, mingguan, dan bulanan
- **Grafik Transaksi**: Visualisasi jumlah dan nilai transaksi harian, mingguan, dan bulanan
- **Daftar Transaksi Terbaru**: Transaksi terbaru yang terjadi di sistem
- **Daftar Pengguna Baru**: Pengguna yang baru mendaftar
- **Pemberitahuan Sistem**: Peringatan dan notifikasi penting tentang sistem
- **Status Sistem**: Status komponen sistem (server, database, gateway pembayaran, dll.)

### Menyesuaikan Dashboard
1. Klik ikon roda gigi di pojok kanan atas dashboard
2. Pilih widget yang ingin ditampilkan atau disembunyikan
3. Atur tata letak dengan menyeret dan melepas widget
4. Klik "Simpan" untuk menyimpan perubahan

## Manajemen Pengguna

### Melihat Daftar Pengguna
1. Dari menu utama, klik "Pengguna"
2. Halaman daftar pengguna akan menampilkan semua pengguna terdaftar
3. Gunakan fitur pencarian dan filter untuk menemukan pengguna tertentu:
   - Filter berdasarkan status (aktif, tidak aktif, terverifikasi, belum terverifikasi)
   - Filter berdasarkan tanggal pendaftaran
   - Cari berdasarkan nama, email, atau nomor telepon

### Melihat Detail Pengguna
1. Dari daftar pengguna, klik nama pengguna yang ingin dilihat detailnya
2. Halaman detail pengguna akan menampilkan:
   - Informasi profil (nama, email, nomor telepon, alamat)
   - Meter air terdaftar
   - Riwayat transaksi
   - Log aktivitas

### Menambahkan Pengguna Baru
1. Dari halaman daftar pengguna, klik tombol "Tambah Pengguna"
2. Isi formulir dengan informasi pengguna:
   - Nama lengkap
   - Alamat email
   - Nomor telepon
   - Alamat
   - Kata sandi (atau pilih "Kirim email pengaturan kata sandi")
   - Peran pengguna (pelanggan, admin, teknisi)
3. Klik tombol "Simpan" untuk membuat pengguna baru

### Mengedit Pengguna
1. Dari daftar pengguna, temukan pengguna yang ingin diedit
2. Klik ikon pensil di samping nama pengguna
3. Edit informasi yang diperlukan
4. Klik tombol "Simpan" untuk menyimpan perubahan

### Menonaktifkan atau Mengaktifkan Pengguna
1. Dari daftar pengguna, temukan pengguna yang ingin dinonaktifkan/diaktifkan
2. Klik tombol toggle di kolom "Status"
3. Konfirmasi tindakan Anda
4. Pengguna yang dinonaktifkan tidak akan dapat login ke sistem

### Menghapus Pengguna
1. Dari daftar pengguna, temukan pengguna yang ingin dihapus
2. Klik ikon tempat sampah di samping nama pengguna
3. Konfirmasi penghapusan
4. **Catatan**: Penghapusan pengguna bersifat permanen dan akan menghapus semua data terkait

## Manajemen Meter Air

### Melihat Daftar Meter Air
1. Dari menu utama, klik "Meter Air"
2. Halaman daftar meter air akan menampilkan semua meter air terdaftar
3. Gunakan fitur pencarian dan filter untuk menemukan meter air tertentu:
   - Filter berdasarkan status (aktif, tidak aktif, terhubung, tidak terhubung)
   - Filter berdasarkan lokasi
   - Cari berdasarkan nomor seri atau ID meter

### Melihat Detail Meter Air
1. Dari daftar meter air, klik nomor seri meter yang ingin dilihat detailnya
2. Halaman detail meter air akan menampilkan:
   - Informasi meter (nomor seri, model, tanggal instalasi)
   - Pengguna terkait
   - Lokasi pemasangan
   - Status saat ini
   - Saldo pulsa
   - Riwayat penggunaan
   - Log aktivitas

### Mendaftarkan Meter Air Baru
1. Dari halaman daftar meter air, klik tombol "Tambah Meter Air"
2. Isi formulir dengan informasi meter air:
   - Nomor seri
   - Model
   - Lokasi pemasangan
   - Pengguna terkait (opsional)
   - Saldo awal (opsional)
3. Klik tombol "Simpan" untuk mendaftarkan meter air baru

### Mengedit Meter Air
1. Dari daftar meter air, temukan meter air yang ingin diedit
2. Klik ikon pensil di samping nomor seri meter
3. Edit informasi yang diperlukan
4. Klik tombol "Simpan" untuk menyimpan perubahan

### Menonaktifkan atau Mengaktifkan Meter Air
1. Dari daftar meter air, temukan meter air yang ingin dinonaktifkan/diaktifkan
2. Klik tombol toggle di kolom "Status"
3. Konfirmasi tindakan Anda
4. Meter air yang dinonaktifkan tidak akan dapat digunakan untuk transaksi

### Menambahkan Pulsa ke Meter Air
1. Dari daftar meter air, temukan meter air yang ingin ditambahkan pulsanya
2. Klik ikon "Tambah Pulsa" di samping nomor seri meter
3. Masukkan jumlah pulsa yang ingin ditambahkan (dalam m³)
4. Pilih alasan penambahan pulsa (promosi, kompensasi, koreksi)
5. Tambahkan catatan jika diperlukan
6. Klik tombol "Tambah" untuk menambahkan pulsa

### Melihat Riwayat Penggunaan Meter Air
1. Dari halaman detail meter air, klik tab "Riwayat Penggunaan"
2. Halaman riwayat akan menampilkan penggunaan air dari waktu ke waktu
3. Gunakan filter tanggal untuk melihat penggunaan dalam periode tertentu
4. Lihat grafik penggunaan untuk analisis visual

## Manajemen Transaksi

### Melihat Daftar Transaksi
1. Dari menu utama, klik "Transaksi"
2. Halaman daftar transaksi akan menampilkan semua transaksi
3. Gunakan fitur pencarian dan filter untuk menemukan transaksi tertentu:
   - Filter berdasarkan jenis transaksi (pembelian pulsa, penggunaan air)
   - Filter berdasarkan status (berhasil, gagal, pending)
   - Filter berdasarkan metode pembayaran
   - Filter berdasarkan tanggal
   - Cari berdasarkan ID transaksi atau pengguna

### Melihat Detail Transaksi
1. Dari daftar transaksi, klik ID transaksi yang ingin dilihat detailnya
2. Halaman detail transaksi akan menampilkan:
   - Informasi transaksi (ID, tanggal, waktu)
   - Pengguna terkait
   - Meter air terkait
   - Jumlah transaksi
   - Metode pembayaran
   - Status transaksi
   - Riwayat status
   - Catatan sistem

### Memverifikasi Transaksi Manual
1. Dari daftar transaksi, temukan transaksi yang perlu diverifikasi
2. Klik tombol "Verifikasi" di samping ID transaksi
3. Periksa bukti pembayaran yang diunggah oleh pengguna
4. Pilih tindakan:
   - Terima: Transaksi diverifikasi dan pulsa ditambahkan ke meter air
   - Tolak: Transaksi ditolak dan pengguna diberitahu
   - Minta informasi tambahan: Pengguna diminta untuk memberikan informasi tambahan
5. Tambahkan catatan jika diperlukan
6. Klik tombol "Simpan" untuk menyelesaikan verifikasi

### Membatalkan Transaksi
1. Dari daftar transaksi, temukan transaksi yang ingin dibatalkan
2. Klik tombol "Batalkan" di samping ID transaksi
3. Masukkan alasan pembatalan
4. Konfirmasi pembatalan
5. **Catatan**: Hanya transaksi dengan status "Pending" yang dapat dibatalkan

### Mengunduh Laporan Transaksi
1. Dari halaman daftar transaksi, klik tombol "Ekspor"
2. Pilih format laporan (CSV, Excel, PDF)
3. Pilih periode laporan
4. Klik tombol "Unduh" untuk mengunduh laporan

## Laporan dan Analitik

### Jenis Laporan
- **Laporan Pengguna**: Statistik pendaftaran dan aktivitas pengguna
- **Laporan Meter Air**: Statistik penggunaan air dan status meter
- **Laporan Transaksi**: Statistik transaksi dan pendapatan
- **Laporan Keuangan**: Ringkasan keuangan dan rekonsiliasi
- **Laporan Performa Sistem**: Statistik kinerja dan ketersediaan sistem

### Membuat Laporan
1. Dari menu utama, klik "Laporan"
2. Pilih jenis laporan yang ingin dibuat
3. Pilih periode laporan (harian, mingguan, bulanan, tahunan, atau kustom)
4. Pilih parameter laporan tambahan jika diperlukan
5. Klik tombol "Buat Laporan"
6. Laporan akan ditampilkan di layar

### Menyimpan dan Mengunduh Laporan
1. Setelah laporan ditampilkan, klik tombol "Simpan" untuk menyimpan laporan ke sistem
2. Untuk mengunduh laporan, klik tombol "Ekspor" dan pilih format yang diinginkan (CSV, Excel, PDF)
3. Laporan yang disimpan dapat diakses kembali dari menu "Laporan Tersimpan"

### Menjadwalkan Laporan Otomatis
1. Dari halaman laporan, klik tombol "Jadwalkan"
2. Pilih jenis laporan
3. Pilih frekuensi laporan (harian, mingguan, bulanan)
4. Pilih format laporan (CSV, Excel, PDF)
5. Masukkan alamat email penerima laporan
6. Klik tombol "Simpan" untuk menjadwalkan laporan otomatis

### Analitik Lanjutan
1. Dari menu utama, klik "Analitik"
2. Pilih jenis analitik yang ingin dilihat:
   - Analitik Pengguna
   - Analitik Penggunaan Air
   - Analitik Transaksi
   - Analitik Keuangan
3. Gunakan filter dan parameter untuk menyesuaikan tampilan analitik
4. Lihat visualisasi data dalam bentuk grafik dan diagram
5. Gunakan fitur drill-down untuk melihat detail lebih lanjut

## Pengaturan Sistem

### Pengaturan Umum
1. Dari menu utama, klik "Pengaturan" > "Umum"
2. Konfigurasikan pengaturan umum sistem:
   - Nama sistem
   - Logo
   - Zona waktu
   - Format tanggal dan waktu
   - Bahasa default
3. Klik tombol "Simpan" untuk menyimpan perubahan

### Pengaturan Tarif Air
1. Dari menu utama, klik "Pengaturan" > "Tarif Air"
2. Konfigurasikan struktur tarif air:
   - Tarif dasar per m³
   - Tarif bertingkat (jika ada)
   - Pajak dan biaya tambahan
3. Klik tombol "Simpan" untuk menyimpan perubahan

### Pengaturan Pembayaran
1. Dari menu utama, klik "Pengaturan" > "Pembayaran"
2. Konfigurasikan metode pembayaran:
   - Gateway pembayaran (Midtrans, DOKU, dll.)
   - Kunci API dan kredensial
   - Metode pembayaran yang diaktifkan
   - Biaya transaksi
3. Klik tombol "Simpan" untuk menyimpan perubahan

### Pengaturan Notifikasi
1. Dari menu utama, klik "Pengaturan" > "Notifikasi"
2. Konfigurasikan pengaturan notifikasi:
   - Template email
   - Template SMS
   - Template notifikasi push
   - Pengaturan SMTP untuk email
   - Pengaturan SMS gateway
3. Klik tombol "Simpan" untuk menyimpan perubahan

### Pengaturan Keamanan
1. Dari menu utama, klik "Pengaturan" > "Keamanan"
2. Konfigurasikan pengaturan keamanan:
   - Kebijakan kata sandi
   - Pengaturan autentikasi dua faktor
   - Batas percobaan login
   - Durasi sesi
   - Daftar IP yang diizinkan
3. Klik tombol "Simpan" untuk menyimpan perubahan

### Pengaturan Backup
1. Dari menu utama, klik "Pengaturan" > "Backup"
2. Konfigurasikan pengaturan backup:
   - Jadwal backup otomatis
   - Lokasi penyimpanan backup
   - Retensi backup
   - Enkripsi backup
3. Klik tombol "Simpan" untuk menyimpan perubahan

## Manajemen Konten

### Mengelola Halaman Statis
1. Dari menu utama, klik "Konten" > "Halaman"
2. Halaman daftar akan menampilkan semua halaman statis
3. Untuk menambahkan halaman baru, klik tombol "Tambah Halaman"
4. Untuk mengedit halaman, klik judul halaman
5. Edit konten menggunakan editor WYSIWYG
6. Klik tombol "Simpan" untuk menyimpan perubahan

### Mengelola Berita dan Pengumuman
1. Dari menu utama, klik "Konten" > "Berita"
2. Halaman daftar akan menampilkan semua berita dan pengumuman
3. Untuk menambahkan berita baru, klik tombol "Tambah Berita"
4. Untuk mengedit berita, klik judul berita
5. Edit konten menggunakan editor WYSIWYG
6. Klik tombol "Simpan" untuk menyimpan perubahan

### Mengelola FAQ
1. Dari menu utama, klik "Konten" > "FAQ"
2. Halaman daftar akan menampilkan semua FAQ
3. Untuk menambahkan FAQ baru, klik tombol "Tambah FAQ"
4. Untuk mengedit FAQ, klik pertanyaan FAQ
5. Edit pertanyaan dan jawaban
6. Klik tombol "Simpan" untuk menyimpan perubahan

### Mengelola Banner dan Promosi
1. Dari menu utama, klik "Konten" > "Banner"
2. Halaman daftar akan menampilkan semua banner dan promosi
3. Untuk menambahkan banner baru, klik tombol "Tambah Banner"
4. Untuk mengedit banner, klik judul banner
5. Edit konten banner, termasuk gambar, teks, dan tautan
6. Klik tombol "Simpan" untuk menyimpan perubahan

## Dukungan Teknis

### Melihat Tiket Dukungan
1. Dari menu utama, klik "Dukungan" > "Tiket"
2. Halaman daftar akan menampilkan semua tiket dukungan
3. Gunakan filter untuk melihat tiket berdasarkan status, prioritas, atau kategori
4. Klik ID tiket untuk melihat detail tiket

### Menangani Tiket Dukungan
1. Dari halaman detail tiket, baca deskripsi masalah yang dilaporkan
2. Tambahkan tanggapan internal (hanya terlihat oleh admin) jika diperlukan
3. Tambahkan tanggapan untuk pengguna
4. Perbarui status tiket:
   - Buka: Tiket baru atau sedang ditinjau
   - Dalam Proses: Tiket sedang ditangani
   - Menunggu Tanggapan: Menunggu tanggapan dari pengguna
   - Diselesaikan: Masalah telah diselesaikan
   - Ditutup: Tiket ditutup tanpa resolusi
5. Tetapkan tiket ke admin lain jika diperlukan
6. Klik tombol "Simpan" untuk menyimpan perubahan

### Membuat Tiket Dukungan Internal
1. Dari halaman daftar tiket, klik tombol "Tambah Tiket"
2. Pilih pengguna terkait (jika ada)
3. Pilih kategori tiket
4. Masukkan subjek dan deskripsi masalah
5. Tetapkan prioritas tiket
6. Lampirkan file jika diperlukan
7. Klik tombol "Simpan" untuk membuat tiket

### Laporan Dukungan Teknis
1. Dari menu utama, klik "Dukungan" > "Laporan"
2. Pilih jenis laporan dukungan:
   - Laporan Tiket
   - Laporan Waktu Respons
   - Laporan Resolusi
   - Laporan Kepuasan Pengguna
3. Pilih periode laporan
4. Klik tombol "Buat Laporan" untuk melihat laporan

---

Untuk bantuan lebih lanjut, silakan hubungi tim dukungan teknis IndoWater di support@indowater.com atau telepon 0800-1234-5678 (bebas pulsa).