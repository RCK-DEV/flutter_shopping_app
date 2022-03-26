import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/orders_screen.dart';
import '../screens/products_overview_screen.dart';
import '../screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          buildDrawerTitle('Hello friend!'),
          Divider(),
          buildDrawerItem(context, Icons.shop, 'Shop', ProductsOverviewScreen.routeName),
          Divider(),
          buildDrawerItem(context, Icons.payment, 'Orders', OrdersScreen.routeName),
          Divider(),
          buildDrawerItem(context, Icons.person, 'Your products', UserProductsScreen.routeName),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logOut();
            },
          )
        ],
      ),
    );
  }

  AppBar buildDrawerTitle(String title) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: false,
    );
  }

  ListTile buildDrawerItem(BuildContext context, IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pushReplacementNamed(routeName);
      },
    );
  }
}
