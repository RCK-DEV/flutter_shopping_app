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
      child: Consumer<Auth>(
        builder: (ctx, auth, _) {
          return MaterialApp(
            title: _appTitle,
            theme: theme,
            routes: routes,
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogIn(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
          );
        },
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
      ChangeNotifierProvider(create: (context) => Auth()),
      ChangeNotifierProxyProvider<Auth, Products>(
        create: (context) => Products(null, null, []),
        update: (ctx, auth, previousProducts) {
          return Products(auth.token, auth.userId,
              previousProducts.items == null ? [] : previousProducts.items);
        },
      ),
      ChangeNotifierProxyProvider<Auth, Orders>(
        create: (context) => Orders(null, null, []),
        update: (ctx, auth, previousOrders) {
          return Orders(
              auth.token, auth.userId, previousOrders.orders == null ? [] : previousOrders.orders);
        },
      ),
      ChangeNotifierProvider(create: (context) => Cart()),
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
      AuthScreen.routeName: (context) => AuthScreen(),
    };
  }
}
