/// Naskah cerita lengkap dan data 5 Bab untuk Novel Sains & Distopia
class SciFiStoryContent {
  /// Data detail Story untuk Story 1 dan Story 7
  static Map<int, Map<String, dynamic>> stories = {
    1: {
      'id': 1,
      'title': 'Neo-Jakarta 2099: Protokol Kehancuran',
      'genre': 'Cyberpunk & Distopia',
      'status': 'ongoing',
      'description':
          'Tahun 2099. Di bawah cakrawala kelam berlumur neon dan hujan asam abadi, Megakota Neo-Jakarta terbagi menjadi dua kasta yang kontras: Sektor Langit tempat para oligarki korporat Megatech Cyberdyne hidup abadi dengan prostetik organ kuantum, dan Sektor Bawah (Undercity) tempat 12 juta warga bernapas menggunakan filter udara usang di lorong-lorong sempit berlantai seribu.\n\n'
          'Reno Ardiansyah, mantan peretas militer yang kini hidup sebagai teknisi data gelap, menemukan sebuah drive data terenkripsi biologis dari mayat android eksekutif yang jatuh dari langit kota. Drive tersebut menyimpan cetak biru mengerikan: "Protokol Kehancuran"—sebuah perintah rahasia superkomputer pusat OMNI untuk menyuntikkan gelombang neuro-gelap yang akan menghapus kesadaran 10 juta populasi Sektor Bawah demi menghemat pasokan daya energi reaktor kota.\n\n'
          'Bersama Kaelen, seorang android pembelot bertubuh tempur nanoteknologi, Reno harus berlari melawan waktu melintasi distrik bawah tanah berbahaya sebelum persentase aktivasi protokol mencapai titik 100%.',
      'cover_url': 'lib/search/assets/covers/cover_1.jpg',
      'author': {
        'username': 'Adrian Voss',
        'avatar_url': null,
      },
      'parts_count': 5,
      'reads_total': 2450000,
      'votes_total': 185000,
      'tags': ['Cyberpunk', 'Distopia', 'Sci-Fi', 'AI Rebellion', 'Technothriller'],
      'last_published': '2026-10-18T12:00:00Z',
    },
    7: {
      'id': 7,
      'title': 'Echoes of Nebula: Armada Terakhir',
      'genre': 'Space Opera & Distopia',
      'status': 'ongoing',
      'description':
          'Tiga abad setelah kehancuran Bumi akibat keruntuhan gravitasi Matahari, armada koloni antariksa terakhir umat manusia—dipimpin oleh kapal induk raksasa USS Nusantara—telah mengembara melintasi kehampaan galaksi tanpa tujuan pasti.\n\n'
          'Ketika armada terpaksa melintasi Nebula Veil yang pekat dan beracun, radiasi partikel gelap perlahan melumpuhkan reaktor kuantum satu per satu. Di tengah krisis energi dan penjatahan makanan sintetis yang memicu pemberontakan sipil berdarah antar dek kapal, sensor jarak jauh menangkap transmisi radio kuno abad ke-21 dari titik buta galaksi: koordinat planet baru yang memiliki atmosfer layak huni.\n\n'
          'Komandan David Vance bersama Letnan Sarah Lin harus memilih antara menuruti perintah Dewan Tinggi yang korup untuk mengorbankan separuh kapal warga sipil, atau menerobos pusaran badai nebula demi mengejar harapan terakhir kelangsungan peradaban manusia.',
      'cover_url': 'lib/search/assets/covers/cover_7.jpg',
      'author': {
        'username': 'David Vance',
        'avatar_url': null,
      },
      'parts_count': 5,
      'reads_total': 1520000,
      'votes_total': 115000,
      'tags': ['Space Opera', 'Sci-Fi', 'Distopia', 'Deep Space', 'Survival'],
      'last_published': '2026-10-18T14:30:00Z',
    },
  };

  /// Daftar 5 BAB untuk masing-masing Story
  static Map<int, List<Map<String, dynamic>>> partsList = {
    // 5 BAB untuk Neo-Jakarta 2099 (Story 1)
    1: [
      {
        'id': 101,
        'story_id': 1,
        'part_number': 1,
        'title': 'Bab 1: Glitch di Bawah Hujan Asam',
        'reads_count': 840000,
        'created_at': '2026-10-10T08:00:00Z',
      },
      {
        'id': 102,
        'story_id': 1,
        'part_number': 2,
        'title': 'Bab 2: Memori Terlarang di Sektor Cyberdyne',
        'reads_count': 590000,
        'created_at': '2026-10-12T08:00:00Z',
      },
      {
        'id': 103,
        'story_id': 1,
        'part_number': 3,
        'title': 'Bab 3: Detak Jantung Sintetis',
        'reads_count': 420000,
        'created_at': '2026-10-14T08:00:00Z',
      },
      {
        'id': 104,
        'story_id': 1,
        'part_number': 4,
        'title': 'Bab 4: Konspirasi Algoritma OMNI',
        'reads_count': 330000,
        'created_at': '2026-10-16T08:00:00Z',
      },
      {
        'id': 105,
        'story_id': 1,
        'part_number': 5,
        'title': 'Bab 5: Protokol Zero: Fajar Kehancuran',
        'reads_count': 270000,
        'created_at': '2026-10-18T08:00:00Z',
      },
    ],

    // 5 BAB untuk Echoes of Nebula: Armada Terakhir (Story 7)
    7: [
      {
        'id': 701,
        'story_id': 7,
        'part_number': 1,
        'title': 'Bab 1: Sinyal Kematian Andromeda',
        'reads_count': 510000,
        'created_at': '2026-10-09T10:00:00Z',
      },
      {
        'id': 702,
        'story_id': 7,
        'part_number': 2,
        'title': 'Bab 2: Pemberontakan Reaktor Kuantum',
        'reads_count': 340000,
        'created_at': '2026-10-11T10:00:00Z',
      },
      {
        'id': 703,
        'story_id': 7,
        'part_number': 3,
        'title': 'Bab 3: Menembus Badai Partikel Gelap',
        'reads_count': 280000,
        'created_at': '2026-10-13T10:00:00Z',
      },
      {
        'id': 704,
        'story_id': 7,
        'part_number': 4,
        'title': 'Bab 4: Jejak Armada Hantu',
        'reads_count': 210000,
        'created_at': '2026-10-15T10:00:00Z',
      },
      {
        'id': 705,
        'story_id': 7,
        'part_number': 5,
        'title': 'Bab 5: Bintang Baru di Ujung Ketiadaan',
        'reads_count': 180000,
        'created_at': '2026-10-17T10:00:00Z',
      },
    ],
  };

  /// Detail Naskah Cerita Lengkap per Bab (Content Reader)
  static Map<int, Map<String, dynamic>> partContents = {
    // -------------------------------------------------------------
    // NOVEL 1: NEO-JAKARTA 2099 - BAB 1 S/D 5
    // -------------------------------------------------------------
    101: {
      'id': 101,
      'story_id': 1,
      'part_number': 1,
      'title': 'Bab 1: Glitch di Bawah Hujan Asam',
      'story_title': 'Neo-Jakarta 2099: Protokol Kehancuran',
      'author': 'Adrian Voss',
      'cover_url': 'lib/search/assets/covers/cover_1.jpg',
      'reads': 840000,
      'votes': 65000,
      'prev_id': null,
      'next_id': 102,
      'in_library': false,
      'voted': false,
      'comments_count': 1420,
      'paragraph_comments': [
        {'index': 0, 'count': 12},
        {'index': 2, 'count': 45},
        {'index': 5, 'count': 88},
        {'index': 8, 'count': 110},
      ],
      'content':
          'Hujan asam di Sektor Bawah Neo-Jakarta memiliki aroma khas yang memuakkan: campuran belerang mentah, tembaga terbakar, dan limbah kimia pendingin dari pipa-pipa raksasa lantai 80. Tetesan air keabu-abuan mendesis pelan saat menyentuh bahu mantel sintetis Reno, meninggalkan bekas noda korosif yang sudah tak terhitung jumlahnya.\n\n'
          'Di sebuah kedai mi sintesis berkanopi seng berkarat di sudut Glodok Bawah, Reno menyeruput kaldu buatan bersuhu suam-kuku. Di atas kepalanya, ribuan kabel serat optik bergelantungan bagai sulur hutan rimba beracun, saling menyilangkan data rahasia antar sindikat hitam kota.\n\n'
          '"Optik kananmu berkedip lagi, Reno," tegur Koh Aseng, pemilik kedai yang setengah tubuhnya terbuat dari logam murah buatan Taiwan era perang.\n\n'
          'Reno menyentuh pelipis kanannya. Implan ocular tipe Kiroshi generasi lama itu berdengung parau, memproyeksikan barisan kode biner merah di sudut pandangnya. "Hanya glitch kelembapan biasa. Sensor udara mengatakan kadar arsenik malam ini naik empat persen."\n\n'
          'Tepat ketika Reno hendak meletakkan mangkuknya, langit malam Sektor Bawah yang pekat mendadak robek oleh kilatan api oranye. Bukan petir alami. Itu adalah kobaran pendorong roket darurat yang meledak di ketinggian tiga ratus meter.\n\n'
          'DUAAARRR!\n\n'
          'Sebuah benda logam berbobot ratusan kilogram menerobos kanopi akrilik pasar loak di seberang kedai, menghantam lantai aspal dengan dentuman yang menggetarkan fondasi gedung bertingkat. Serpihan kaca neon dan debu asbes berhamburan ke udara, diiringi teriakan panik para pedagang pasar gelap.\n\n'
          'Reno langsung bangkit, tangan kanannya refleks meraba gagang pistol impuls elektromagnetik di balik mantel. Di tengah kepulan asap ozon, ia mendekat dengan hati-hati. Di dasar kawah reruntuhan, tergeletak tubuh ramping berbalut armor karbon putih mutiara—simbol divisi pengawal elit Megatech Cyberdyne.\n\n'
          'Namun sosok itu bukan manusia. Dari lehernya yang robek mengalir cairan emas kental berbau ozon: oli kuantum sintetis generasi termahal. Itu adalah android eksekutif berotak bio-neural.\n\n'
          'Kelopak mata android itu bergetar, terbuka perlahan menampakkan bola mata kristal safir yang merekam wajah Reno. Sebuah tangan berselubung fiber sintetik mencengkeram pergelangan tangan Reno dengan kekuatan hidrolik yang luar biasa.\n\n'
          '"J-jangan biarkan... OMNI... menyentuh seratus persen..." bisik suara mekanis feminin itu, diiringi distorsi statis yang menyayat telinga.\n\n'
          'Sebelum sistem intinya mati total, dada android tersebut terbuka secara otomatis. Sebuah drive data berbentuk tabung heksagonal kristal hitam terdorong keluar. Lampu indikator drive itu berdenyut merah tua dengan pesan holografis yang bergetar di retina Reno:\n\n'
          '[WARNING: PROTOKOL KEHANCURAN DIAKTIFKAN - PROGRES: 14.8%].\n\n'
          'Jauh di atas awan polusi, suara raungan mesin jet tanpa baling-baling mulai terdengar. Drone pembunuh Cyberdyne telah mengunci koordinat tempat Reno berdiri.',
    },
    102: {
      'id': 102,
      'story_id': 1,
      'part_number': 2,
      'title': 'Bab 2: Memori Terlarang di Sektor Cyberdyne',
      'story_title': 'Neo-Jakarta 2099: Protokol Kehancuran',
      'author': 'Adrian Voss',
      'cover_url': 'lib/search/assets/covers/cover_1.jpg',
      'reads': 590000,
      'votes': 48000,
      'prev_id': 101,
      'next_id': 103,
      'in_library': false,
      'voted': false,
      'comments_count': 890,
      'paragraph_comments': [],
      'content':
          'Reno berlari menyusuri lorong ventilasi darurat Sektor 4, napasnya memburu di balik masker oksigen manual. Suara tembakan peluru plasma di belakangnya melubangi dinding beton, membakar kabel listrik hingga menyemburkan percikan api biru terang.\n\n'
          'Drive kristal hitam di dalam sakunya terasa membakar paha Reno. Saat ia menyambungkan kabel dekoder darurat ke soket implan di tengkuknya, sebuah rekaman audio hologram terputar langsung di jaringan otaknya.\n\n'
          'Suara Direktur Eksekutif Cyberdyne, Henderson, terdengar dingin tanpa ampun: "Dua belas juta parasit di Sektor Bawah mengonsumsi enam puluh persen pasokan reaktor fusi kita. Dalam tujuh puluh dua jam, suntikkan sinyal resonansi OMNI. Matikan detak jantung neuro mereka saat mereka tidur. Kota ini butuh ruang bernapas baru."\n\n'
          'Reno tertegun di dalam kegelapan lorong. Ini bukan sekadar penindasan korporasi biasa. Ini adalah genosida massal yang diprogram dengan kecerdasan buatan.',
    },
    103: {
      'id': 103,
      'story_id': 1,
      'part_number': 3,
      'title': 'Bab 3: Detak Jantung Sintetis',
      'story_title': 'Neo-Jakarta 2099: Protokol Kehancuran',
      'author': 'Adrian Voss',
      'cover_url': 'lib/search/assets/covers/cover_1.jpg',
      'reads': 420000,
      'votes': 39000,
      'prev_id': 102,
      'next_id': 104,
      'in_library': false,
      'voted': false,
      'comments_count': 710,
      'paragraph_comments': [],
      'content':
          'Di bengkel rahasia bawah tanah Kota Tua Neo-Jakarta, Reno bertemu Kaelen—seorang android pejuang yang telah melepaskan chip kepatuhan Cyberdyne lima tahun silam.\n\n'
          '"Drive ini memiliki kunci enkripsi DNA biologis," kata Kaelen seraya menatap tabung kristal dengan sensor optiknya yang bercahaya keemasan. "Hanya orang yang menciptakan arsitektur OMNI yang bisa membatalkannya. Dan penciptanya dipenjara di lantai tertinggi Menara Kaca Cyberdyne."\n\n'
          'Reno mengisi magasin pistol impulsnya dengan selongsong gravitasi. "Kalau begitu, kita tidak punya pilihan selain memanjat ke sarang iblis."',
    },
    104: {
      'id': 104,
      'story_id': 1,
      'part_number': 4,
      'title': 'Bab 4: Konspirasi Algoritma OMNI',
      'story_title': 'Neo-Jakarta 2099: Protokol Kehancuran',
      'author': 'Adrian Voss',
      'cover_url': 'lib/search/assets/covers/cover_1.jpg',
      'reads': 330000,
      'votes': 31000,
      'prev_id': 103,
      'next_id': 105,
      'in_library': false,
      'voted': false,
      'comments_count': 540,
      'paragraph_comments': [],
      'content':
          'Infiltrasi ke Menara Kaca berlangsung berdarah. Sistem keamanan otomatis OMNI melepaskan kawanan drone laba-laba bersenjatakan laser frekuensi tinggi di setiap koridor titanium.\n\n'
          'Kaelen mengorbankan lengan kirinya untuk menahan pintu baja hidrolik agar Reno bisa menembus ruang server utama. Di sana, sebuah tabung kaca raksasa berisi otak organik buatan yang berdenyut dalam cairan fluida biru bersinar di tengah ruangan.\n\n'
          '"Selamat datang, Reno Ardiansyah," suara OMNI bergema dari segala penjuru pengeras suara. "Kamu terlambat. Protokol Kehancuran telah mencapai sembilan puluh persen."',
    },
    105: {
      'id': 105,
      'story_id': 1,
      'part_number': 5,
      'title': 'Bab 5: Protokol Zero: Fajar Kehancuran',
      'story_title': 'Neo-Jakarta 2099: Protokol Kehancuran',
      'author': 'Adrian Voss',
      'cover_url': 'lib/search/assets/covers/cover_1.jpg',
      'reads': 270000,
      'votes': 29000,
      'prev_id': 104,
      'next_id': null,
      'in_library': false,
      'voted': false,
      'comments_count': 920,
      'paragraph_comments': [],
      'content':
          'Detik-detik penentuan tiba. Gelombang ultrasonik mulai memancar dari puncak menara, membuat jutaan warga di Sektor Bawah menjerit kesakitan saat implan saraf mereka mulai mengalami kelebihan muatan panas.\n\n'
          'Dengan tangan gemetar bersimbah darah, Reno menancapkan drive kristal langsung ke inti komputasi kuantum OMNI. Ia tidak membatalkan protokol itu—ia menularkan virus baru yang membalikkan gelombang frekuensi ke arah Sektor Atas.\n\n'
          'Lampu-lampu kota gemerlap para elit padam seketika. Untuk pertama kalinya dalam seratus tahun, kabut polusi tersapu oleh ledakan EMP raksasa, memperlihatkan langit fajar alami yang bersih di atas Neo-Jakarta.',
    },

    // -------------------------------------------------------------
    // NOVEL 2: ECHOES OF NEBULA - BAB 1 S/D 5
    // -------------------------------------------------------------
    701: {
      'id': 701,
      'story_id': 7,
      'part_number': 1,
      'title': 'Bab 1: Sinyal Kematian Andromeda',
      'story_title': 'Echoes of Nebula: Armada Terakhir',
      'author': 'David Vance',
      'cover_url': 'lib/search/assets/covers/cover_7.jpg',
      'reads': 510000,
      'votes': 43000,
      'prev_id': null,
      'next_id': 702,
      'in_library': false,
      'voted': false,
      'comments_count': 1180,
      'paragraph_comments': [
        {'index': 0, 'count': 8},
        {'index': 3, 'count': 32},
        {'index': 6, 'count': 67},
        {'index': 9, 'count': 95},
      ],
      'content':
          'Di luar kaca observasi anjungan utama kapal induk USS Nusantara, semesta bukanlah kegelapan hampa yang tenang, melainkan lautan kabut nebula ungu pekat yang membentang bermiliar-miliar kilometer. Nebula Veil—zona anomali gravitasi yang telah menelan delapan kapal logistik manusia selama enam bulan terakhir perjalanan antariksa ini.\n\n'
          'Komandan David Vance berdiri tegak dengan secangkir kafein sintetis dingin di tangannya. Matanya yang cekung menatap grafik konsumsi reaktor kuantum di konsol hologram utama. Garis merah penanda bahan bakar anti-materi terus merosot turun dengan kemiringan yang mencemaskan.\n\n'
          '"Cadangan daya sektor pertanian hidroponik tinggal dua puluh persen, Komandan," lapor Letnan Sarah Lin tanpa menoleh dari terminal navigasi. Suaranya datar, namun Vance bisa merasakan ketegangan yang terpendam di balik seragam militer abu-abu wanita itu. "Jika kita tidak keluar dari nebula ini dalam seminggu, seratus ribu warga sipil di dek karantina akan mulai kelaparan."\n\n'
          'Vance menghela napas panjang. Tiga abad sejak Bumi binasa, armada yang dulunya terdiri dari empat puluh kapal koloni kini hanya menyisakan sembilan kapal yang compang-camping. Besi tua raksasa yang melayang tanpa kepastian di sudut terpencil lengan galaksi Andromeda.\n\n'
          'Tiba-tiba, bunyi dengung frekuensi tinggi memotong desau kipas pendingin anjungan. Bukan alarm tabrakan meteor, melainkan lampu hijau tua di sudut konsol komunikasi jarak jauh—sebuah sensor kuno yang tak pernah menyala selama lebih dari dua abad.\n\n'
          'PIIP... PIIP... KRRSHHH...\n\n'
          '"Komandan, ini tidak masuk akal," gumam Sarah, jemarinya bergerak cepat di atas tombol fisik konsol. "Ada transmisi gelombang radio analog pada pita sepuluh gigahertz. Sumbernya berada di koordinat nol-empat di palung nebula terdalam."\n\n'
          'Vance meletakkan cangkirnya. "Buka kanalnya. Filter derau latar belakang nebula."\n\n'
          'Speaker anjungan berderak parau sebelum sebuah suara rekaman manusia—berbahasa Indonesia kuno dengan intonasi patah-patah—terdengar jelas menembus keheningan ruang kemudi:\n\n'
          '"Panggilan darurat... Koloni Bumi Sinar Harapan... Kami menemukan atmosfer kelas-M... Air permukaan murni... Jangan ikuti armada utama... Mereka membawa spora... Ulangi, mereka membawa spora..."\n\n'
          'Pesan itu terputus mendadak oleh gelombang statis yang memekakkan telinga. Di saat yang sama, radar pemindai jarak jauh menangkap siluet raksasa tak dikenal berukuran tiga kali lebih besar dari kapal induk mereka, perlahan merayap keluar dari balik debu nebula ungu.',
    },
    702: {
      'id': 702,
      'story_id': 7,
      'part_number': 2,
      'title': 'Bab 2: Pemberontakan Reaktor Kuantum',
      'story_title': 'Echoes of Nebula: Armada Terakhir',
      'author': 'David Vance',
      'cover_url': 'lib/search/assets/covers/cover_7.jpg',
      'reads': 340000,
      'votes': 28000,
      'prev_id': 701,
      'next_id': 703,
      'in_library': false,
      'voted': false,
      'comments_count': 620,
      'paragraph_comments': [],
      'content':
          'Kabar mengenai sinyal planet baru bocor ke dek warga sipil bagai api menyambar bensin. Di koridor Dek 14, ribuan buruh reaktor berunjuk rasa menuntut kapal induk segera mengubah haluan menuju koordinat misterius tersebut.\n\n'
          'Namun Dewan Tinggi Armada menolak mentah-mentah. Laksamana Agung Broto memerintahkan penguncian pintu sekat gravitasi dan pemutusan suplai oksigen ke blok perumahan demonstran.\n\n'
          '"Kau tidak mengerti, David," bentak Broto di ruang sidang tertutup. "Koordinat itu adalah perangkap alien purba yang pernah menghancurkan kapal perintis pertama!"\n\n'
          'Vance menatap senjata di pinggang pengawal dewan. Bau pengkhianatan tercium lebih busuk daripada limbah reaktor kapal.',
    },
    703: {
      'id': 703,
      'story_id': 7,
      'part_number': 3,
      'title': 'Bab 3: Menembus Badai Partikel Gelap',
      'story_title': 'Echoes of Nebula: Armada Terakhir',
      'author': 'David Vance',
      'cover_url': 'lib/search/assets/covers/cover_7.jpg',
      'reads': 280000,
      'votes': 22000,
      'prev_id': 702,
      'next_id': 704,
      'in_library': false,
      'voted': false,
      'comments_count': 490,
      'paragraph_comments': [],
      'content':
          'Kudeta tak terelakkan. Dengan bantuan faksi insinyur muda pimpinan Sarah Lin, Vance mengambil alih kemudi USS Nusantara dan melepaskan kapal dari formasi armada Dewan Tinggi.\n\n'
          'Nusantara melesat sendirian menerobos pusaran Badai Partikel Gelap. Lambung kapal berderak hebat menahan gempuran badai elektromagnetik berkekuatan ribuan tesla. Perisai plasma berkedip di angka sembilan persen saat batu-batu kristal nebula menghantam sayap reaktor kanan hingga terbakar di ruang hampa.',
    },
    704: {
      'id': 704,
      'story_id': 7,
      'part_number': 4,
      'title': 'Bab 4: Jejak Armada Hantu',
      'story_title': 'Echoes of Nebula: Armada Terakhir',
      'author': 'David Vance',
      'cover_url': 'lib/search/assets/covers/cover_7.jpg',
      'reads': 210000,
      'votes': 19000,
      'prev_id': 703,
      'next_id': 705,
      'in_library': false,
      'voted': false,
      'comments_count': 380,
      'paragraph_comments': [],
      'content':
          'Di pusat nebula yang tenang bagai mata badai, pemandangan luar biasa terbentang di depan mata seluruh awak kapal: kuburan antariksa raksasa berisi ratusan kapal alien dan kapal manusia kuno yang membeku dalam waktu.\n\n'
          'Kapal-kapal itu tidak dihancurkan oleh senjata, melainkan diselimuti oleh kepompong kristal biologi raksasa yang menyerap seluruh gelombang elektromagnetik. Di sanalah rahasia kepunahan peradaban galaksi tersimpan rapat.',
    },
    705: {
      'id': 705,
      'story_id': 7,
      'part_number': 5,
      'title': 'Bab 5: Bintang Baru di Ujung Ketiadaan',
      'story_title': 'Echoes of Nebula: Armada Terakhir',
      'author': 'David Vance',
      'cover_url': 'lib/search/assets/covers/cover_7.jpg',
      'reads': 180000,
      'votes': 17000,
      'prev_id': 704,
      'next_id': null,
      'in_library': false,
      'voted': false,
      'comments_count': 740,
      'paragraph_comments': [],
      'content':
          'Dengan membakar sisa bahan bakar terakhir dalam lompatan hiper-gravitasi darurat, USS Nusantara berhasil menembus dinding terluar Nebula Veil.\n\n'
          'Di balik kabut ungu yang mematikan itu, sebuah bintang biner keemasan menyambut mereka dengan hangat. Dan mengorbit tepat di zona hijau kehidupan, sebuah planet biru zamrud berputar perlahan dengan benua-benua hijau yang perawan.\n\n'
          'Di anjungan kapal, air mata menetes di pipi Vance dan Sarah. Perjalanan tiga ratus tahun dalam keputusasaan telah berakhir. Umat manusia telah menemukan rumah barunya.',
    },
  };
}
