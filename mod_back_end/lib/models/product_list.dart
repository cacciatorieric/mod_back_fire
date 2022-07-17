import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mod_back_end/errors/http_exceptions.dart';
import 'package:mod_back_end/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:mod_back_end/utils/constants.dart';

//Essa classe é a observavel... os observadores serão notificados

class ProductList with ChangeNotifier {
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
      Uri.parse('${Constants.PRODUCT_BASE_URL}.json'),
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
        '${Constants.PRODUCT_BASE_URL}.json',
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

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse(
          '${Constants.PRODUCT_BASE_URL}/${product.id}.json',
        ),
        body: jsonEncode(
          {
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          },
        ),
      );
      _items[index] = product;
      notifyListeners();
    }
    return Future.value();
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final resposte = await http.delete(
        Uri.parse('${Constants.PRODUCT_BASE_URL}/${product.id}.json'),
      );

      if (resposte.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException(
            msg: 'Não foi possível excluir o produto',
            statusCode: resposte.statusCode);
      }
    }
  }
}
