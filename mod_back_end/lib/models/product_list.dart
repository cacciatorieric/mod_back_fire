import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mod_back_end/models/product.dart';
import 'package:http/http.dart' as http;

//Essa classe é a observavel... os observadores serão notificados

class ProductList with ChangeNotifier {
  final _url =
      'https://fire-flutter-ypp-default-rtdb.firebaseio.com/products.json';

  final List<Product> _items = [];

  List<Product> get items => [..._items];
  List<Product> get favoriteItens =>
      _items.where((prod) => prod.isFavorite!).toList();

  int get itemCount {
    return _items.length;
  }

  Future<void> loadProduct() async {
    _items.clear();
    final resposta = await http.get(
      Uri.parse(_url),
    );
    if (resposta.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(resposta.body);
    data.forEach(
      (productId, productData) {
        _items.add(
          Product(
            id: productId,
            name: productData['name'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite: productData['isFavorite'],
          ),
        );
      },
    );
    notifyListeners();
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;
    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> addProduct(Product product) async {
// url/colecao -> objeto
    final future = await http.post(
      Uri.parse(
        _url,
      ), //Uri representa uma string que faz alguma coisa, assim como a URL, sempre precisa ser .json
      body: jsonEncode(
        //O objeto que passaremos precisará passar por uma conversão, o jsonEncode faz essa conversão
        //
        {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
        },
      ),
    );

    final id = jsonDecode(
        future.body)['name']; //Estamos pegando o dado da chave 'name'.
    _items.add(
      Product(
          id: id,
          name: product.name,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          isFavorite: product.isFavorite),
    );
    notifyListeners();

    //Como colocamos o async / await, a estrutura de resposta deixa de ser Future e já está respondendo ao await, que força o método a aguardar a resposta chegar antes de continuar
    // return future.then((resposta) {
    //   final id = jsonDecode(
    //       resposta.body)['name']; //Estamos pegando o dado da chave 'name'.
    //   _items.add(
    //     Product(
    //         id: id,
    //         name: product.name,
    //         description: product.description,
    //         price: product.price,
    //         imageUrl: product.imageUrl,
    //         isFavorite: product.isFavorite),
    //   );
    //   notifyListeners();
    //   //debugPrint('Gravado na memoria ->  ${resposta.body}');
    // });
  }

  //Aqui, o método é chamado diretamente após o POST, sem esperar a resposta.
  // debugPrint('Método chamado na sequencia do post sem esperar resposta');
  // _items.add(product);
  // notifyListeners(); //Ele vai notificar todas as mudanças para o estado fazer as mudanças

  Future<void> updateProduct(Product product) {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      _items[index] = product;
      notifyListeners();
    }
    return Future.value();
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
