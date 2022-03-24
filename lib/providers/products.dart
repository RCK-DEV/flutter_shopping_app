import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  final String authToken;
  final String userId;
  List<Product> _items = [];

  Products(this.authToken, this.userId, this._items);

  List<Product> get items => [..._items];

  Product findById(String id) => _items.firstWhere((product) => product.id == id);

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    final productsUrl = Uri.parse(
        'https://flutter-shopping-app-97d29-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken$filterString');
    final userFavoritesUrl = Uri.parse(
        'https://flutter-shopping-app-97d29-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken');

    try {
      final productsResponse = await http.get(productsUrl);
      final userFavoritesResponse = await http.get(userFavoritesUrl);

      if (productsResponse.statusCode >= 400 || userFavoritesResponse.statusCode >= 400) {
        throw ('Failed to fetch products from server.');
      }

      final extractedProductsData = json.decode(productsResponse.body) as Map<String, dynamic>;
      final List<Product> fetchedProducts = [];
      final extractedUserFavoritesData = json.decode(userFavoritesResponse.body);

      extractedProductsData.forEach((productId, productData) {
        final Product product = Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: extractedUserFavoritesData == null
              ? false
              : extractedUserFavoritesData[productId] ?? false,
        );

        fetchedProducts.add(product);
      });
      _items = fetchedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product newProduct) async {
    if (newProduct == null) return Future.error('Provided product is empty.');
    final url = Uri.parse(
        'https://flutter-shopping-app-97d29-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            'creatorId': userId
          }));

      _items.add(Product(
          id: json.decode(response.body)['name'],
          title: newProduct.title,
          description: newProduct.description,
          price: newProduct.price,
          imageUrl: newProduct.imageUrl));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(Product product) async {
    final existingProductIndex = _items.indexWhere((element) => element.id == product.id);

    final productUrl = Uri.parse(
        'https://flutter-shopping-app-97d29-default-rtdb.europe-west1.firebasedatabase.app/products/${product.id}.json?auth=$authToken');

    await http
        .patch(productUrl,
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'price': product.price,
            }))
        .then((result) {});

    _items[existingProductIndex] = product;

    notifyListeners();
  }

  void deleteProduct(String productId) {
    final productUrl = Uri.parse(
        'https://flutter-shopping-app-97d29-default-rtdb.europe-west1.firebasedatabase.app/products/$productId.json?auth=$authToken');

    final existingProductIndex = _items.indexWhere((element) => productId == element.id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);

    http.delete(productUrl).then((response) {
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product. Server error occurred.');
      } else {
        existingProduct = null;
      }
    }).catchError((error) {
      _items.insert(existingProductIndex, existingProduct); // Rollback deletion
      notifyListeners();
    });

    notifyListeners();
  }
}
