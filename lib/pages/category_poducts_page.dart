import 'package:userapp/models/product_model.dart';
import 'package:userapp/utils/app_helper.dart';
import 'package:userapp/utils/app_themes.dart';
import 'package:userapp/utils/app_widgets.dart';
import 'package:userapp/widgets/product_grid_item.dart';
import 'package:userapp/widgets/product_list_item.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../utils/helpers_replacement.dart';

class CategoryProductPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  const CategoryProductPage(
      {Key? key, required this.categoryId, required this.categoryName})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CategoryProductPageState createState() => _CategoryProductPageState();
}

class _CategoryProductPageState extends State<CategoryProductPage> {
  late Future<List<ProductModel>> futureProductByCategoryList;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool productViewGrid = true;

  @override
  void initState() {
    futureProductByCategoryList =
        AppData().getProductByCategory(categoryId: widget.categoryId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        title: Headline6(widget.categoryName,
            style: const TextStyle(
                color: AppThemes.lightGreyColor, fontWeight: FontWeight.bold)),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () {
          setState(() {
            futureProductByCategoryList =
                AppData().getProductByCategory(categoryId: widget.categoryId);
          });
          _refreshController.refreshCompleted();
        },
        child: Column(
          children: [
            ListTile(
              title: Headline6(
                "products".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      productViewGrid = !productViewGrid;
                    });
                  },
                  icon: Icon(!productViewGrid ? Ionicons.grid : Ionicons.list)),
            ),
            FutureBuilder<List<ProductModel>>(
              future: futureProductByCategoryList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return productViewGrid
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                  return AppWidgets().EmptyDataWidget(
                      title: "sww".tr(), icon: Ionicons.bug_outline);
                }
                return GridView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: 3,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 0.8),
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
