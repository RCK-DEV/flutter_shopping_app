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
  bool _isInit = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Orders>(context).fetchAndSetOrders().then((value) {
        setState(() {
          _isLoading = false;
        });
      });

      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<Orders>(context).orders;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your orders'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) => OrderItem(orders[index]),
            ),
      drawer: AppDrawer(),
    );
  }
}
