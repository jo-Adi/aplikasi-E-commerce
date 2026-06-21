BinMart - Aplikasi Marketplace Lokal Binjai
BinMart adalah aplikasi marketplace berbasis mobile yang dikembangkan sebagai proyek akhir untuk membantu para pelaku usaha lokal di kota Binjai dalam memasarkan produk mereka secara digital. Aplikasi ini mencakup sistem untuk pembeli dan dashboard manajemen khusus untuk penjual (mitra).

🚀 Fitur Utama
Untuk Pembeli:
Autentikasi Aman: Sistem masuk dan daftar yang terintegrasi.

Antarmuka Ramah Pengguna: Pencarian dan penelusuran produk yang intuitif.

Untuk Penjual (Mitra):
Dashboard Penjual Profesional: Memantau statistik toko, total produk, dan pendapatan secara real-time.

Manajemen Produk: Kemudahan menambah, mengaktifkan, dan menghapus produk dagangan.

Manajemen Pesanan: Sistem kelola pesanan masuk hingga selesai.

Profil Toko Dinamis: Pengaturan banner toko dan foto profil yang terintegrasi dengan sistem cloud storage.

🛠 Teknologi yang Digunakan
Framework: Flutter

State Management: BLoC (Business Logic Component)

Backend & Database: Supabase (untuk database dan storage gambar)

Autentikasi: Firebase Auth

Integrasi Lainnya: Image Picker untuk kebutuhan unggah gambar produk/profil.

📦 Struktur Proyek
Proyek ini dikembangkan dengan arsitektur yang modular untuk memastikan kode tetap bersih dan mudah dikembangkan:

core/: Berisi model, repository, dan service utama.

features/: Berisi fitur-fitur aplikasi (Auth, Home, Seller Dashboard, Profile).

cubit/: Logic state management untuk setiap fitur.