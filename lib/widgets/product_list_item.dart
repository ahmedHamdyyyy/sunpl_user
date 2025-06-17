import 'package:userapp/main.dart';
import 'package:userapp/models/order_item_model.dart';
import 'package:userapp/models/product_model.dart';
import 'package:userapp/pages/product_details.dart';
import 'package:userapp/utils/app_const.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:userapp/utils/helpers_replacement.dart';
import 'package:ionicons/ionicons.dart';

class ProductListItem extends StatefulWidget {
  final ProductModel product;
  const ProductListItem({Key? key, required this.product}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProductListItemState createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => ProductDetails(product: widget.product));
      },
      child: Card(
        elevation: 0.0,
        // color: Colors.blueGrey.shade50,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        //color: Colors.black,
        child: Row(
          children: [
            Hero(
              tag: "product${widget.product.id}",
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.product.image,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Ionicons.image, size: 48),
                      width: Get.size.width / 4,
                      height: Get.size.width / 4,
                      fit: BoxFit.cover,
                    )),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyText1(
                    widget.product.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  BodyText2(
                    "${widget.product.price} ${AppConst.appCurrency}",
                    maxLines: 1,
                    style: TextStyle(
                        color: context.color.primary,
                        fontWeight: FontWeight.bold),
                  ),
                  BodyText2(
                    "${widget.product.unitSize} ${widget.product.unit}",
                    maxLines: 1,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Ionicons.bag_add,
                color: context.color.primary,
              ),
              onPressed: () {
                List<OrderItemModel> tmpList = cartItemsNotifier.value;
                OrderItemModel? cartProduct = tmpList.firstWhereOrNull(
                    (element) => element.product.id == widget.product.id);

                if (cartProduct != null) {
                  cartProduct.qty++;
                } else {
                  tmpList.add(OrderItemModel(product: widget.product, qty: 1));
                }
                cartItemsNotifier.value = tmpList;
              },
            ),
          ],
        ),
      ),
    );
  }
}
