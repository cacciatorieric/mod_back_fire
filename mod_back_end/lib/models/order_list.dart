import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:mod_back_end/models/cart_item.dart';
import 'package:mod_back_end/utils/constants.dart';
import 'cart.dart';
import 'order.dart';
import 'package:http/http.dart' as http;

class OrderList with ChangeNotifier {
  final List<Order> _items = [];

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadOrders() async {
    _items.clear();
    final resposta = await http.get(
      Uri.parse('${Constants.ORDER_BASE_URL}.json'),
    );
    if (resposta.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(resposta.body);
    data.forEach(
      (orderId, orderData) {
        _items.add(
          Order(
            id: orderId,
            date: DateTime.parse(
              orderData['date'],
            ),
            total: orderData['total'],
            products: (orderData['products'] as List<dynamic>).map((item) {
              return CartItem(
                id: item['id'],
                productId: item['productId'],
                name: item['name'],
                quantity: item['quantity'],
                price: item['price'],
              );
            }).toList(),
          ),
        );
      },
    );
    notifyListeners();
    print(data);
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final future = await http.post(
      Uri.parse(
        '${Constants.ORDER_BASE_URL}.json',
      ), //Uri representa uma string que faz alguma coisa, assim como a URL, sempre precisa ser .json
      body: jsonEncode(
        //O objeto que passaremos precisará passar por uma conversão, o jsonEncode faz essa conversão
        //
        {
          'total': cart.totalAmount,
          'date': date.toIso8601String(),
          'products': cart.itens.values
              .map(
                (cartItem) => {
                  'id': cartItem.id,
                  'productId': cartItem.productId,
                  'name': cartItem.name,
                  'quantity': cartItem.quantity,
                  'price': cartItem.price,
                },
              )
              .toList(),
        },
      ),
    );
    final id = jsonDecode(future.body)['name'];
    _items.insert(
      0,
      Order(
        id: id,
        total: cart.totalAmount,
        products: cart.itens.values.toList(),
        date: date,
      ),
    );
    notifyListeners();
  }
}
