import 'package:userapp/models/product_model.dart';

class OrderItemModel {
  OrderItemModel({required this.product, required this.qty});

  final ProductModel product;
  int qty;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      product: ProductModel.fromJson(json['product']),
      qty: json['qty'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['product'] = product.toJson();
    data['qty'] = qty;
    return data;
  }
}
