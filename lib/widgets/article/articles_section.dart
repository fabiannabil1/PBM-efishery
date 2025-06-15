import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/article_provider.dart';
import 'article_preview_card.dart';
import '../../screens/artikel_screen/artikeluser_screen.dart';

class ArticlesSection extends StatelessWidget {
  const ArticlesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ), // Dikurangi dari 20
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Artikel Terbaru',
                style: TextStyle(
                  fontSize: 17, // Dikurangi dari 18
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ArtikelUserScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ), // Mengurangi padding
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize:
                            13, // Menambahkan ukuran font yang lebih kecil
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 3), // Dikurangi dari 4
                    Icon(
                      Icons.arrow_forward,
                      size: 14, // Dikurangi dari 16
                      color: Color(0xFF1565C0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12), // Dikurangi dari 16
        SizedBox(
          height:
              240, // Dikurangi dari 280 untuk menyesuaikan dengan card yang lebih kecil
          child: Consumer<ArticleProvider>(
            builder: (context, articleProvider, child) {
              if (articleProvider.isLoading) {
                return const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (articleProvider.error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gagal memuat artikel',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          articleProvider.error!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => articleProvider.fetchArticles(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text(
                            'Coba Lagi',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (articleProvider.articles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        color: Colors.grey[400],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ada artikel tersedia',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              // Show only the first 5 articles
              final articles = articleProvider.articles.take(5).toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ), // Dikurangi dari 20
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  return ArticlePreviewCard(article: articles[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
