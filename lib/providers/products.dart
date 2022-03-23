import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  final String authToken;
  List<Product> _items = [];

  Products(this.authToken, this._items);

  List<Product> get items => [..._items];

  Product findById(String id) => _items.firstWhere((product) => product.id == id);

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
        'https://flutter-shopping-app-97d29-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        throw ('Failed to fetch products from server.');
      }
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> fetchedProducts = [];
      extractedData.forEach((productId, productData) {
        final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite: productData['isFavorite']);

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
            'isFavorite': newProduct.isFavorite,
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
