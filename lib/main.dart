import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import './screens/screens.dart';
import './providers/providers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String _appTitle = 'MyShop';
  final String _appFontFamily = 'Lato';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: _appTitle,
        theme: theme,
        routes: routes,
      ),
    );
  }

  ThemeData get theme {
    return ThemeData(
      fontFamily: _appFontFamily,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
      ).copyWith(
        secondary: Colors.deepOrange,
      ),
    );
  }

  List<SingleChildWidget> get providers {
    return [
      ChangeNotifierProvider(create: (context) => Products()),
      ChangeNotifierProvider(create: (context) => Cart()),
      ChangeNotifierProvider(create: (context) => Orders()),
    ];
  }

  Map<String, WidgetBuilder> get routes {
    return {
      OrdersScreen.routeName: (context) => OrdersScreen(),
      ProductsOverviewScreen.routeName: (context) => ProductsOverviewScreen(),
      ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
      CartScreen.routeName: (context) => CartScreen(),
      UserProductsScreen.routeName: (context) => UserProductsScreen(),
      EditProductScreen.routeName: (context) => EditProductScreen(),
    };
  }
}
