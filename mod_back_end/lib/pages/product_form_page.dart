import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mod_back_end/models/product.dart';
import 'package:mod_back_end/models/product_list.dart';
import 'package:provider/provider.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({Key? key}) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _urlFocus = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _urlFocus.addListener(updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final product = arg as Product;
        _formData['id'] = product.id!;
        _formData['name'] = product.name!;
        _formData['price'] = product.price!;
        _formData['description'] = product.description!;
        _formData['imageUrl'] = product.imageUrl!;
        _imageUrlController.text = product.imageUrl!;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _urlFocus.removeListener(updateImage);
    _urlFocus.dispose();
  }

  void updateImage() {
    setState(() {});
  }

  bool isValidImageUrl(String url) {
    bool isValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;
    bool endsWithFile = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg');
    return isValidUrl && endsWithFile;
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();
    //A função save() vem do FormState e trabalha junto com o 'OnSaved', que é um parametro dos TextFormField

    setState(() {
      _isLoading = true;
    });
//Já que não podemos utilizar o catchError para fazer o tratamento de erros utilizando o async / await, utilizamos a estrutura padrão. Try and Catch

    try {
      await Provider.of<ProductList>(
        context,
        listen: false,
      ).saveProduct(_formData);
    } catch (erro) {
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text(
                  'Ocorreu um erro',
                ),
                content: const Text(
                    'Ocorreu um erro ao incluir o produto. Se erro erro continuar, informe o código 0x1 ao suporte.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ));
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulário de Produto'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formData['name']?.toString(),
                      onSaved: (name) => _formData['name'] = name ?? '',
                      validator: (_name) {
                        final name = _name ?? '';
                        //name sempre vai receber algo, ou o _name ou uma string vazia
                        if (name.trim().isEmpty) {
                          return 'Nome é obrigatório';
                        }
                        if (name.trim().length < 3) {
                          return 'Coloque seu nome completo';
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        focusColor: Theme.of(context).colorScheme.primary,
                      ),
                      /* OnSubmitted é o que ele vai fazer quando for clicado para terminar no teclado, e o FocusScope seta o id (_priceFocus) que foi identificado no form abaixo. */
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocus);
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      initialValue: _formData['price']?.toString(),
                      onSaved: (price) =>
                          _formData['price'] = double.parse(price ?? '0'),
                      focusNode: _priceFocus,
                      decoration: InputDecoration(
                        labelText: 'Preço',
                        focusColor: Theme.of(context).colorScheme.primary,
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_descriptionFocus);
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['description']?.toString(),

                      onSaved: (description) =>
                          _formData['description'] = description ?? '',
                      focusNode: _descriptionFocus,
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        focusColor: Theme.of(context).colorScheme.primary,
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      //textInputAction: TextInputAction.next,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            onSaved: (image) =>
                                _formData['imageUrl'] = image ?? '',
                            validator: (_imageUrl) {
                              final imageUrl = _imageUrl ?? '';
                              if (!isValidImageUrl(imageUrl)) {
                                return 'Informe uma url válida';
                              }
                              return null;
                            },
                            focusNode: _urlFocus,
                            decoration: InputDecoration(
                              labelText: 'Imagem',
                              focusColor: Theme.of(context).colorScheme.primary,
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            onFieldSubmitted: (_) => _submitForm(),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 10, left: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: _imageUrlController.text.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    'Informe a URL',
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child:
                                        Image.network(_imageUrlController.text),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
