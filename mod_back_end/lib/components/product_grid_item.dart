import 'package:flutter/material.dart';
import 'package:mod_back_end/models/cart.dart';
import 'package:mod_back_end/models/product.dart';
import 'package:mod_back_end/utils/app_routes.dart';
import 'package:provider/provider.dart';

class ProductGridItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(
      context,
      listen: false,
    );

    final cart = Provider.of<Cart>(
      context,
    );

    /****** ALTERNARIVA PARA A LINHA DE CIMA *****/
    //Utilizar o widget consumer diretamente no item que vai ser modificado para a tela renderizar apenas ele

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          leading: Consumer<Product>(
            //O impacto na interface grafica será apenas aqui, então ele nao fica renderizando a tela toda quando modificado, apenas o necessário
            builder: (cxt, product, _) => IconButton(
              onPressed: () {
                product.toggleFavorite();
              },
              icon: Icon(
                  product.isFavorite! ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red),
            ),
          ),
          title: Text(product.name!),
          trailing: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              cart.addItem(product);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Produto adicionado com sucesso!'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'DESFAZER',
                    textColor: Colors.red,
                    onPressed: () {
                      cart.removeSingleItem(product.id!);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        child: GestureDetector(
          child: Image.network(
            product.imageUrl!,
            fit: BoxFit.cover,
          ),
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.PRODUCT_DETAIL,
            arguments: product,
          ),
        ),
      ),
    );
  }
}
