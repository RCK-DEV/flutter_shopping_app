import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    print('CartScreen Widget tree rebuild..');

    return Scaffold(
      appBar: AppBar(
        title: Text('Your cart'),
      ),
      body: Column(
        children: [
          buildTotal(cart, context),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (context, index) {
                return CartItem(
                    cart.items.values.toList()[index].id,
                    cart.items.keys.toList()[index],
                    cart.items.values.toList()[index].price,
                    cart.items.values.toList()[index].quantity,
                    cart.items.values.toList()[index].title);
              },
            ),
          )
        ],
      ),
    );
  }

  Card buildTotal(Cart cart, BuildContext context) {
    return Card(
      margin: EdgeInsets.all(15),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(fontSize: 20),
            ),
            Spacer(),
            Chip(
              label: Text(
                '\$${cart.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(color: Theme.of(context).primaryTextTheme.titleMedium.color),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            FlatButton(
              child: Text('ORDER NOW'),
              onPressed: () {
                Provider.of<Orders>(context, listen: false).addOrder(
                  cart.items.values.toList(),
                  cart.totalAmount,
                );
                cart.clear();
              },
              textColor: Theme.of(context).primaryColor,
            )
          ],
        ),
      ),
    );
  }
}