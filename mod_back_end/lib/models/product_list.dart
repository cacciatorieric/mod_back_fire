import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:mod_back_end/data/dammy_data.dart';
import 'package:mod_back_end/models/product.dart';

//Essa classe é a observavel... os observadores serão notificados

class ProductList with ChangeNotifier {
  final List<Product> _items = dummyProducts;

  List<Product> get items => [..._items];
  List<Product> get favoriteItens =>
      _items.where((prod) => prod.isFavorite!).toList();

  int get itemCount {
    return _items.length;
  }

  void saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;
    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      updateProduct(product);
    } else {
      addProduct(product);
    }
  }

  void addProduct(Product product) {
    _items.add(product);
    notifyListeners(); //Ele vai notificar todas as mudanças para o estado fazer as mudanças
  }

  void updateProduct(Product product) {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      _items[index] = product;
      notifyListeners();
    }
  }

  void removeProduct(Product product) {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      _items.removeWhere((p) => p.id == product.id);
      notifyListeners();
    }
  }
}

//  bool _showFavoriteOnly = false;

//   List<Product> get items {
//     if (_showFavoriteOnly) {
//       return _items
//           .where((prod) => prod.isFavorite!)
//           .toList(); //Where funciona como um filter
//       //Se a flag _showFavoriteOnly for true, vai retornar os cards que estão com o isFAvorite true tbm
//     }
//     return [..._items]; //Esse [...] cria um clone da variavel chamada
//   }

//   void showFavoriteOnly() {
//     _showFavoriteOnly = true;
//     notifyListeners();
//   }

//   void showAll() {
//     _showFavoriteOnly = false;
//     notifyListeners();
//   }