import 'package:flutter/material.dart';
import 'package:flutter_shopping_app/screens/cart_screen.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';

enum FilterOptions { favorites, all }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final productsContainer = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          buildPopupMenuButton(),
          Consumer<Cart>(
              builder: (_, cart, child) => Badge(
                    child: child,
                    value: cart.itemCount.toString(),
                  ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: Icon(Icons.shopping_cart),
              )),
        ],
      ),
      body: ProductsGrid(_isFavorite),
    );
  }

  PopupMenuButton<FilterOptions> buildPopupMenuButton() {
    return PopupMenuButton(
      onSelected: (FilterOptions selectedFilter) {
        setState(() {
          if (selectedFilter == FilterOptions.favorites) {
            _isFavorite = true;
          } else {
            _isFavorite = false;
          }
        });
      },
      icon: Icon(Icons.more_vert),
      itemBuilder: (_) => [
        PopupMenuItem(
          child: Text('Only favorites'),
          value: FilterOptions.favorites,
        ),
        PopupMenuItem(
          child: Text('Show all'),
          value: FilterOptions.all,
        ),
      ],
    );
  }
}
