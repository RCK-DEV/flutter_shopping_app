import 'package:flutter/material.dart';
import 'package:flutter_shopping_app/models/http_exception.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = []; // _ == private field.
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  // Prevents mutating _orders directly
  List<OrderItem> get orders {
    return [..._orders.reversed];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-shopping-app-97d29-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken');

    final response = await http.get(url);
    if (response.statusCode >= 400) {
      throw HttpException('Failed to fetch products from server.');
    }

    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) return;

    final List<OrderItem> fetchedOrderItems = [];

    extractedData.forEach((orderId, orderItemData) {
      final Iterable rawCartItems = json.decode(orderItemData['products']);

      final List<CartItem> cartItems = List<CartItem>.from(rawCartItems.map((item) => CartItem(
            id: item['id'],
            title: item['title'],
            quantity: item['quantity'],
            price: item['price'],
          )));

      final OrderItem orderItem = OrderItem(
        id: orderId,
        amount: orderItemData['amount'],
        products: cartItems,
        dateTime: DateTime.parse(orderItemData['dateTime']),
      );

      fetchedOrderItems.add(orderItem);
    });
    _orders = fetchedOrderItems;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://flutter-shopping-app-97d29-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken');

    final dateTime = DateTime.now();

    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'products': json.encode(cartProducts),
          'dateTime': dateTime.toString(),
        }));

    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: dateTime,
        ));

    notifyListeners();
  }
}
