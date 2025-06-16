import 'package:flutter/material.dart';
import '../../models/article_model.dart';
import '../../screens/artikel_screen/artikeluser_screen.dart';

class ArticlePreviewCard extends StatelessWidget {
  final ArticleModel article;

  const ArticlePreviewCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArtikelDetailPage(article: article),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12), // Sama dengan auction card
        width: 140, // Sama dengan auction card
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // Sama dengan auction card
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08), // Sama dengan auction card
              spreadRadius: 1,
              blurRadius: 4, // Sama dengan auction card
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10), // Sama dengan auction card
              ),
              child:
                  article.imageUrl != null
                      ? Image.network(
                        article.imageUrl!,
                        height: 80, // Sama dengan auction card
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                      : _buildPlaceholder(),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(10), // Sama dengan auction card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 13, // Sama dengan auction card
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                      height: 1.2,
                    ),
                    maxLines: 1, // Sama dengan auction card
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3), // Sama dengan auction card
                  Text(
                    article.content,
                    style: TextStyle(
                      fontSize: 11, // Sama dengan auction card
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 1, // Dikurangi untuk menyesuaikan ruang
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6), // Sama dengan auction card
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 12, // Sama dengan auction card timer icon
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 3), // Sama dengan auction card
                      Expanded(
                        child: Text(
                          article.authorName,
                          style: TextStyle(
                            fontSize: 11, // Sama dengan auction card
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2), // Spacing kecil untuk baris kedua
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12, // Sama dengan auction card timer icon
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 3), // Sama dengan auction card
                      Expanded(
                        child: Text(
                          article.createdAt,
                          style: TextStyle(
                            fontSize: 11, // Sama dengan auction card
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 80, // Sama dengan auction card image height
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF64B5F6), Color(0xFF42A5F5), Color(0xFF1976D2)],
        ),
      ),
      child: const Icon(
        Icons.article,
        color: Colors.white70,
        size: 32, // Disesuaikan dengan ukuran card yang lebih kecil
      ),
    );
  }
}
