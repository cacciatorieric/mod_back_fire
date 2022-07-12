import 'package:flutter/material.dart';
import 'package:mod_back_end/models/cart.dart';
import 'package:mod_back_end/models/order_list.dart';
import 'package:mod_back_end/models/product_list.dart';
import 'package:mod_back_end/pages/cart_page.dart';
import 'package:mod_back_end/pages/orders_page.dart';
import 'package:mod_back_end/pages/product_detail_page.dart';
import 'package:mod_back_end/pages/product_form_page.dart';
import 'package:mod_back_end/pages/products_overview_page.dart';
import 'package:mod_back_end/pages/products_page.dart';
import 'package:mod_back_end/utils/app_routes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductList(),
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderList(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gerenciamento de Estados',
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange,
              secondary: Colors.white,
              background: Color.fromARGB(255, 238, 238, 238)),
        ),
        //home: ProductsOverViewPage(),
        routes: {
          AppRoutes.HOME: (ctx) => ProductsOverViewPage(),
          AppRoutes.CART: (ctx) => const CartPage(),
          AppRoutes.PRODUCT_DETAIL: (ctx) => const ProductDetailPage(),
          AppRoutes.ORDERS: (ctx) => const OrdersPage(),
          AppRoutes.PRODUCTS_MANAGEMENT: (ctx) => const ProductsPage(),
          AppRoutes.PRODUCT_FORM: (ctx) => const ProductFormPage(),
        },
      ),
    );
  }
}
