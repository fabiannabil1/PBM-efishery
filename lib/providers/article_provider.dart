import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';
import 'dart:io';

class ArticleProvider extends ChangeNotifier {
  final ArticleService _articleService = ArticleService();
  List<ArticleModel> _articles = [];
  bool _isLoading = false;
  String? _error;

  List<ArticleModel> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchArticles() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final articlesData = await _articleService.fetchArticles();
      _articles =
          articlesData.map((json) => ArticleModel.fromJson(json)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createArticle({
    required String title,
    required String content,
    File? image,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _articleService.createArticle(
        title: title,
        content: content,
        image: image,
      );

      if (result) {
        await fetchArticles(); // Refresh the articles list
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateArticle({
    required int articleId,
    required String title,
    required String content,
    File? image,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _articleService.updateArticle(
        articleId: articleId,
        title: title,
        content: content,
        image: image,
      );

      if (result) {
        await fetchArticles(); // Refresh the articles list
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteArticle(int articleId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _articleService.deleteArticle(articleId);

      if (result) {
        _articles.removeWhere((article) => article.id == articleId);
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
