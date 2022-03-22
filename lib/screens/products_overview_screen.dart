import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/cart_screen.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';

enum FilterOptions { favorites, all }

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/';

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _isFavorite = false;
  bool _isInit = false;
  bool _isLoading = false;
  bool _failedFetchingProductsFromServer = false;
  String _errorMessage = '';

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((value) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        _failedFetchingProductsFromServer = true;
        _errorMessage = error;
      });

      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _failedFetchingProductsFromServer
              ? Center(child: Text(_errorMessage))
              : ProductsGrid(_isFavorite),
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
