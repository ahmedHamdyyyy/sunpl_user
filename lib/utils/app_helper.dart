import 'dart:convert';

import 'package:userapp/models/category_model.dart';
import 'package:userapp/models/order_model.dart';
import 'package:userapp/models/product_model.dart';
import 'package:userapp/models/slider_model.dart';
import 'package:userapp/utils/app_const.dart';
import 'package:http/http.dart' as http;

class AppData {
  // ignore: constant_identifier_names
  static const String URL = AppConst.url;

  Future<String> checkUserExist({required String userPhone}) async {
    final response = await http.post(Uri.parse('$URL/api.php'),
        body: jsonEncode({
          "action": "checkUserExist",
          "userPhone": userPhone,
        }),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<List<SliderModel>> getSliders() async {
    List<SliderModel> sliders = [];
    final response = await http.post(Uri.parse('$URL/api.php'),
        body: jsonEncode({"action": "getSliders"}),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      Map resDecode = jsonDecode(response.body);

      List res = resDecode['data'];

      for (var element in res) {
        sliders.add(SliderModel.fromJson(element));
      }
      return sliders;
    } else {
      throw Exception('Failed to load album');
    }
  }

/* https://www.webberkn.com/nourmarket/api.php/getLatestProducts */
  Future<List<ProductModel>> getLatestProducts() async {
    List<ProductModel> products = [];
    final response = await http.post(Uri.parse('$URL/api.php'),
        body: jsonEncode({"action": "getLatestProducts"}),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      Map resDecode = jsonDecode(response.body);

      List res = resDecode['data'];

      for (var element in res) {
        products.add(ProductModel.fromJson(element));
      }

      return products;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    List<CategoryModel> categories = [];
    final response = await http.post(Uri.parse('$URL/api.php'),
        body: jsonEncode({"action": "getCategories"}),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      Map resDecode = jsonDecode(response.body);

      List res = resDecode['data'];

      for (var element in res) {
        categories.add(CategoryModel.fromJson(element));
      }
      return categories;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<List<ProductModel>> getProductByCategory(
      {required int categoryId}) async {
    List<ProductModel> products = [];
    final response = await http.post(Uri.parse('$URL/api.php'),
        body: jsonEncode(
            {"action": "getProductByCategory", "categoryId": categoryId}),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      Map resDecode = jsonDecode(response.body);

      List res = resDecode['data'];

      for (var element in res) {
        products.add(ProductModel.fromJson(element));
      }
      return products;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<List<OrderModel>> getUserOrders({required String userUid}) async {
    List<OrderModel> orders = [];

    final response = await http.post(Uri.parse('$URL/api.php'),
        body: jsonEncode({"action": "getUserOrders", "userUid": userUid}),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      Map resDecode = jsonDecode(response.body);

      List res = resDecode['data'];

      for (var element in res) {
        orders.add(OrderModel.fromJson(element));
      }
      return orders;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<Map<String, dynamic>> addOrder(
      {required OrderModel orderModel}) async {
    Map<String, dynamic> body = orderModel.toJson();
    final response = await http.post(Uri.parse('$URL/api.php'),
        body: jsonEncode({
          ...{"action": "addOrder"},
          ...body
        }),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });
    Map<String, dynamic> res = jsonDecode(response.body);

    return res;
  }

  Future<Map<String, dynamic>> cancelOrder({required String orderId}) async {
    final response = await http.post(Uri.parse('$URL/api.php'),
        body: jsonEncode({"action": "cancelOrder", "orderId": orderId}),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        });
    Map<String, dynamic> res = jsonDecode(response.body);

    return res;
  }

  // New method to get all products for search functionality
  Future<List<ProductModel>> getAllProducts() async {
    try {
      // First get all categories
      List<CategoryModel> categories = await getCategories();
      List<ProductModel> allProducts = [];

      // Get products from each category
      for (CategoryModel category in categories) {
        try {
          List<ProductModel> categoryProducts =
              await getProductByCategory(categoryId: category.id!);
          allProducts.addAll(categoryProducts);
        } catch (e) {
          // Continue with other categories if one fails
          continue;
        }
      }

      // Remove duplicates based on product ID
      Map<int, ProductModel> uniqueProducts = {};
      for (ProductModel product in allProducts) {
        if (product.id != null) {
          uniqueProducts[product.id!] = product;
        }
      }

      return uniqueProducts.values.toList();
    } catch (e) {
      throw Exception('Failed to load all products');
    }
  }
}
