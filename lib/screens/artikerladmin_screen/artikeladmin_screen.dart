import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/article_model.dart';
import '../../providers/article_provider.dart';

class ArtikelAdminScreen extends StatefulWidget {
  const ArtikelAdminScreen({Key? key}) : super(key: key);

  @override
  _ArtikelAdminScreenState createState() => _ArtikelAdminScreenState();
}

class _ArtikelAdminScreenState extends State<ArtikelAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleProvider>().fetchArticles();
    });
  }

  void _showActionDialog(BuildContext context, ArticleModel article) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kelola Artikel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Artikel'),
                onTap: () {
                  Navigator.pop(context); // Close action dialog
                  _navigateToEditArticle(article);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Artikel'),
                onTap: () {
                  Navigator.pop(context); // Close action dialog
                  _showDeleteConfirmation(context, article);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToAddArticle() async {
    final result = await Navigator.pushNamed(context, '/articles/add');
    if (result == true) {
      context.read<ArticleProvider>().fetchArticles();
    }
  }

  void _navigateToEditArticle(ArticleModel article) async {
    final result = await Navigator.pushNamed(
      context,
      '/articles/edit',
      arguments: article,
    );
    if (result == true) {
      context.read<ArticleProvider>().fetchArticles();
    }
  }

  void _showDeleteConfirmation(BuildContext context, ArticleModel article) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: Text(
              'Apakah Anda yakin ingin menghapus artikel "${article.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final provider = context.read<ArticleProvider>();
                    await provider.deleteArticle(article.id);
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Artikel berhasil dihapus'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola Artikel',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, articleProvider, child) {
          if (articleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (articleProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${articleProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => articleProvider.fetchArticles(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (articleProvider.articles.isEmpty) {
            return const Center(child: Text('Tidak ada artikel tersedia'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: articleProvider.articles.length,
            itemBuilder: (context, index) {
              final article = articleProvider.articles[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => _showActionDialog(context, article),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              article.authorName,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              article.createdAt,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddArticle,
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
