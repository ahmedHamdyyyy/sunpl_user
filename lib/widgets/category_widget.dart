import 'package:userapp/models/category_model.dart';
import 'package:userapp/utils/app_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:userapp/utils/helpers_replacement.dart';

import '../pages/category_poducts_page.dart';

class CategoryWidget extends StatefulWidget {
  final int? maxCategory;
  final int? childPerLine;

  const CategoryWidget({Key? key, this.maxCategory, this.childPerLine})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  late Future<List<CategoryModel>> futureCategoryList;

  @override
  void initState() {
    futureCategoryList = AppData().getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryModel>>(
      future: futureCategoryList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GridView.builder(
              padding: const EdgeInsets.all(10),
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: (widget.maxCategory != null &&
                      snapshot.data!.length < widget.maxCategory!)
                  ? snapshot.data!.length
                  : (widget.maxCategory ?? snapshot.data!.length),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.childPerLine ?? 2,
                  childAspectRatio: 2),
              itemBuilder: (context, index) {
                CategoryModel category = snapshot.data![index];
                return InkWell(
                  onTap: () {
                    Get.to(() => CategoryProductPage(
                          categoryId: category.id!,
                          categoryName: category.title,
                        ));
                  },
                  child: Card(
                    elevation: 0.0,
                    color: Colors.blueGrey.shade50,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    //color: Colors.black,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: category.image,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(),
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3)),
                        ),
                        Center(
                          child: Headline1(
                            category.title,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                );
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
                crossAxisCount: 2, childAspectRatio: 2),
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
