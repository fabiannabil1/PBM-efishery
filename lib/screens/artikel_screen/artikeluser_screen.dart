import 'package:flutter/material.dart';

class Artikel {
  final String judul;
  final String isi;

  Artikel({required this.judul, required this.isi});
}

class ArtikelUserScreen extends StatelessWidget {
  final List<Artikel> artikels = [
    Artikel(
      judul: 'Penggunaan Obat ikan dengan kandungan Chloramphenicol dapat meninggalkan residu pada tubuh ikan',
      isi:
          'Peraturan Menteri Perikanan dan Kelautan Republik Indonesia No.1/PERMEN-KP/2019 tentang obat ikan diketahui bahwa Obat Ikan adalah sediaan yang dapat digunakan untuk mengobati Ikan, membebaskan gejala, atau memodifikasi proses kimia dalam tubuh Ikan. Obat Ikan berdasarkan tujuan pemakaiannya digunakan untuk: a. mencegah dan/atau mengobati Ikan, b. membebaskan gejala penyakit Ikan, dan c. memodifikasi proses kimia dalam tubuh Ikan. Obat Ikan berdasarkan jenis sediaan digolongkan dalam sediaan: a. biologi, farmasetik, premiks, probiotik dan obat alami. Obat Ikan berdasarkan klasifikasi bahaya yang ditimbulkan dalam penggunaannya, digolongkan menjadi: a. obat keras; b. obat bebas terbatas; dan c. obat bebas.',
    ),
    Artikel(
      judul: 'Contoh Artikel Kedua',
      isi: 'Isi dari artikel kedua yang bisa kamu sesuaikan sesuai kebutuhan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artikel User')),
      body: ListView.builder(
        itemCount: artikels.length,
        itemBuilder: (context, index) {
          final artikel = artikels[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 120,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    artikel.judul,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArtikelDetailPage(artikel: artikel),
                          ),
                        );
                      },
                      child: const Text('Lihat selengkapnya'),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ArtikelDetailPage extends StatelessWidget {
  final Artikel artikel;

  const ArtikelDetailPage({super.key, required this.artikel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artikel User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              artikel.judul,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  artikel.isi,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('KEMBALI'),
            )
          ],
        ),
      ),
    );
  }
}



