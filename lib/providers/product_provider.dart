import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProductProvider extends ChangeNotifier {
  final ProdukService _produkService = ProdukService();

  List<ProductModel> _filteredProducts = [];
  List<ProductModel> get filteredProducts => _filteredProducts;

  void filterProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredProducts =
          _products.where((product) {
            return product.name.toLowerCase().contains(lowerQuery) ||
                product.description.toLowerCase().contains(lowerQuery);
          }).toList();
    }
    notifyListeners();
  }

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    try {
      final List<Map<String, dynamic>> data = await _produkService.getProduk();
      _products = data.map((item) => ProductModel.fromJson(item)).toList();
      _filteredProducts = List.from(_products);
      notifyListeners();
    } catch (e) {
      print('Error saat fetchProducts: $e');
    }
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required int stock,
    required int price,
    File? image,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _produkService.createProduk(
        name: name,
        description: description,
        stock: stock,
        price: price,
        image: image,
      );

      if (result) {
        await fetchProducts();
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

  Future<bool> updateProduct({
    required int id,
    required String name,
    required String description,
    required int price,
    File? image,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _produkService.updateProdukById(
        id: id,
        name: name,
        description: description,
        price: price,
        image: image,
      );

      if (result) {
        await fetchProducts();
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

  Future<bool> updateProductStock({
    required int id,
    required int newStock,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _produkService.updateStokProdukById(
        id: id,
        newStock: newStock,
      );

      if (result) {
        await fetchProducts();
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

  Future<bool> deleteProduct(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _produkService.deleteProdukById(id);

      if (result) {
        _products.removeWhere(
          (product) =>
              product.name ==
              _products.firstWhere((p) => p.name == product.name).name,
        );
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
