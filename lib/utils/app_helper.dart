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
    try {
      print('Fetching sliders from: $URL/api.php');
      
      final response = await http.post(
        Uri.parse('$URL/api.php'),
        body: jsonEncode({"action": "getSliders"}),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        Map resDecode = jsonDecode(response.body);
        print('Decoded response: $resDecode');
        
        if (resDecode.containsKey('data')) {
          List res = resDecode['data'];
          print('Sliders data length: ${res.length}');
          
          for (var element in res) {
            try {
              sliders.add(SliderModel.fromJson(element));
            } catch (e) {
              print('Error parsing slider: $element');
              print('Error details: $e');
            }
          }
          print('Successfully parsed ${sliders.length} sliders');
          return sliders;
        } else {
          print('No data field in response');
          throw Exception('No data field in API response');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in getSliders: $e');
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('لا يمكن الاتصال بالخادم. تحقق من اتصال الإنترنت');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('انتهت مهلة الاتصال. حاول مرة أخرى');
      } else {
        throw Exception('حدث خطأ في تحميل الشرائح: $e');
      }
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
    try {
      print('Fetching categories from: $URL/api.php');
      
      final response = await http.post(
        Uri.parse('$URL/api.php'),
        body: jsonEncode({"action": "getCategories"}),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        Map resDecode = jsonDecode(response.body);
        print('Decoded response: $resDecode');
        
        if (resDecode.containsKey('data')) {
          List res = resDecode['data'];
          print('Categories data length: ${res.length}');
          
          for (var element in res) {
            try {
              categories.add(CategoryModel.fromJson(element));
            } catch (e) {
              print('Error parsing category: $element');
              print('Error details: $e');
            }
          }
          print('Successfully parsed ${categories.length} categories');
          return categories;
        } else {
          print('No data field in response');
          throw Exception('No data field in API response');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in getCategories: $e');
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('لا يمكن الاتصال بالخادم. تحقق من اتصال الإنترنت');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('انتهت مهلة الاتصال. حاول مرة أخرى');
      } else {
        throw Exception('حدث خطأ في تحميل الفئات: $e');
      }
    }
  }

  Future<List<ProductModel>> getProductByCategory(
      {required int categoryId}) async {
    List<ProductModel> products = [];
    try {
      print('Fetching products for category: $categoryId');
      
      final response = await http.post(
        Uri.parse('$URL/api.php'),
        body: jsonEncode(
            {"action": "getProductByCategory", "categoryId": categoryId}),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        Map resDecode = jsonDecode(response.body);
        print('Decoded response: $resDecode');
        
        if (resDecode.containsKey('data')) {
          List res = resDecode['data'];
          print('Products data length: ${res.length}');
          
          for (var element in res) {
            try {
              products.add(ProductModel.fromJson(element));
            } catch (e) {
              print('Error parsing product: $element');
              print('Error details: $e');
            }
          }
          print('Successfully parsed ${products.length} products');
          return products;
        } else {
          print('No data field in response');
          throw Exception('No data field in API response');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in getProductByCategory: $e');
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('لا يمكن الاتصال بالخادم. تحقق من اتصال الإنترنت');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('انتهت مهلة الاتصال. حاول مرة أخرى');
      } else {
        throw Exception('حدث خطأ في تحميل المنتجات: $e');
      }
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
