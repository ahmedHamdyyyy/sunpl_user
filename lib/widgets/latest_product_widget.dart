import 'package:userapp/models/product_model.dart';
import 'package:userapp/utils/app_helper.dart';
import 'package:userapp/widgets/product_grid_item.dart';
import 'package:userapp/widgets/product_list_item.dart';
import 'package:flutter/material.dart';
import 'package:userapp/utils/helpers_replacement.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class LatestProductWidget extends StatefulWidget {
  final bool productViewGrid;

  const LatestProductWidget({Key? key, required this.productViewGrid})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LatestProductWidgetState createState() => _LatestProductWidgetState();
}

class _LatestProductWidgetState extends State<LatestProductWidget> {
  late Future<List<ProductModel>> futureProductList;

  @override
  void initState() {
    futureProductList = AppData().getLatestProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: futureProductList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return widget.productViewGrid
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.8),
                  itemBuilder: (context, index) {
                    ProductModel product = snapshot.data![index];
                    return ProductGridItem(product: product);
                  })
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    ProductModel product = snapshot.data![index];
                    return ProductListItem(product: product);
                  });
        } else if (snapshot.hasError) {
          return Card(
            elevation: 0.0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Ionicons.planet_outline,
                      size: 50,
                    ),
                    Subtitle1(
                      "sww".tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          );
        }
        return GridView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: 3,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.8),
            itemBuilder: (context, index) {
              return Shimmer(
                color: Colors.grey,
                child: const Card(
                  margin: EdgeInsets.all(4),
                ),
              );
            });
      },
    );
  }
}
