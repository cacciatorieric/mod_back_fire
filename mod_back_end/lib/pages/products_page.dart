import 'package:flutter/material.dart';
import 'package:mod_back_end/components/app_drawer.dart';
import 'package:mod_back_end/components/product_item.dart';
import 'package:mod_back_end/models/product_list.dart';
import 'package:mod_back_end/utils/app_routes.dart';
import 'package:provider/provider.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProductList products = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Produtos'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.PRODUCT_FORM);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: products.itemCount,
          itemBuilder: (ctx, i) => Column(
            children: [
              ProductItem(
                product: products.items[i],
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
