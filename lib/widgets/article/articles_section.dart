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
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: Provider.of<ArticleProvider>(context).articles.length,
            itemBuilder: (context, index) {
              return _buildEnhancedArticleCard(index, context);
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildEnhancedArticleCard(int index, BuildContext context) {
    final articleProvider = Provider.of<ArticleProvider>(context);

    // Handle loading state
    if (articleProvider.isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Handle error state
    if (articleProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey[400], size: 32),
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
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                child: const Text('Coba Lagi', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      );
    }

    // Handle empty state
    if (articleProvider.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text(
              'Tidak ada artikel tersedia',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Return the actual article card
    return ArticlePreviewCard(article: articleProvider.articles[index]);
  }
}
