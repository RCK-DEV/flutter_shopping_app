import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    final productUrl = Uri.parse(
        'https://flutter-shopping-app-97d29-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$authToken');

    var previousIsFavoriteState = isFavorite;
    isFavorite = !isFavorite;

    http.put(productUrl, body: json.encode(isFavorite)).then((response) {
      if (response.statusCode >= 400) {
        isFavorite = previousIsFavoriteState;
        throw HttpException('Could not delete product. Server error occurred.');
      } else {
        previousIsFavoriteState = null;
        notifyListeners();
      }
    });

    notifyListeners();
  }
}
