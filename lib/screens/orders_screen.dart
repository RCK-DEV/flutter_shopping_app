import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFeature;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFeature = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your orders'),
      ),
      body: FutureBuilder(
          future: _ordersFeature,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.error != null) {
                return Center(
                  child: Text('Error occured while loading orders from the server.'),
                );
              } else {
                return Consumer<Orders>(builder: (ctx, ordersProvider, child) {
                  return ListView.builder(
                    itemCount: ordersProvider.orders.length,
                    itemBuilder: (context, index) => OrderItem(ordersProvider.orders[index]),
                  );
                });
              }
            }
          }),
      drawer: AppDrawer(),
    );
  }
}
