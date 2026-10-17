# Object Cloning: Wattpad  

Wattpad adalah platform baca dan tulis cerita online yang sangat populer di dunia. Berdiri sejak Desember 2006, Wattpad menjadi tempat bagi jutaan pengguna untuk menulis dan membaca cerita dalam berbagai genre. Platform ini didirikan oleh Allen Lau dan Ivan Yuen dengan tujuan menciptakan komunitas yang menghubungkan penulis dan pembaca tanpa batas.

## Fitur Utama

* **Profil Pengguna Dinamis:** Menampilkan informasi utama kreator termasuk avatar, *username*, jumlah pengikut (*followers*), dan total daftar bacaan (*reading lists*).
* **Personalisasi Biodata (About):** Sistem edit deskripsi profil interaktif dengan batasan 2000 karakter, dilengkapi dengan informasi tanggal bergabung pengguna.
* **Sistem Percakapan (Conversations):** Fitur interaksi sosial di mana pengguna dapat mempublikasikan pesan ke pengikutnya. Dilengkapi dengan opsi lanjutan seperti *reply* dan *delete* menggunakan *dropdown menu*.
* **Manajemen Karya (Stories by User):** Ruang kerja penulis yang memisahkan karya tulis ke dalam dua kategori: **Published** (untuk cerita yang dipublikasikan) dan **Drafts** (untuk draf cerita yang belum dirilis). Termasuk pintasan untuk membuat cerita baru.
* **Arsitektur Siap API:** Kode *frontend* telah dipisahkan berdasarkan Model, Layar (Screens), dan Komponen (Widgets) dengan *dummy data* yang mudah diganti menggunakan *package* HTTP saat *backend* sudah siap.

## Teknologi yang Digunakan

* **Frontend:** Flutter (Dart)
* **Konektivitas:** Struktur disiapkan untuk integrasi RESTful API (GET, POST, DELETE).
* **Desain UI:** Replikasi antarmuka tema gelap (Dark Mode) khas Wattpad.
