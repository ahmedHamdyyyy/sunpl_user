import 'package:userapp/utils/app_const.dart';
class ProductModel {
  ProductModel({
    required this.title,
    required this.image,
    required this.description,
    required this.price,
    required this.unit,
    required this.unitSize,
    this.id,
    required this.categoryId,
    required this.showToUser,
    this.images,
  });

  final String title;
  final String image;
  final String description;
  final double price;
  final String unit;
  final double unitSize;
  final int? id;
  final int categoryId;
  final int showToUser;
  final List<String>? images;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'] ?? '';
    List<String> imageUrls = [];
    
    // Handle multiple images if available
    if (json['images'] != null) {
      if (json['images'] is List) {
        // Proper JSON array
        for (var img in json['images']) {
          String url = img.toString();
          if (url.startsWith('http://') || url.startsWith('https://')) {
            imageUrls.add(url);
          } else if (url.isNotEmpty) {
            imageUrls.add('${AppConst.url}/${url}');
          }
        }
      } else if (json['images'] is String) {
        // Comma-separated string
        String imagesString = json['images'].toString();
        List<String> splitImages = imagesString.split(',');
        for (String url in splitImages) {
          url = url.trim();
          if (url.isNotEmpty) {
            if (url.startsWith('http://') || url.startsWith('https://')) {
              imageUrls.add(url);
            } else {
              imageUrls.add('${AppConst.url}/${url}');
            }
          }
        }
      }
    }
    
    // Also check if the main image field contains multiple URLs
    if (imageUrl.contains(',')) {
      List<String> splitMainImages = imageUrl.split(',');
      for (String url in splitMainImages) {
        url = url.trim();
        if (url.isNotEmpty) {
          if (url.startsWith('http://') || url.startsWith('https://')) {
            imageUrls.add(url);
          } else {
            imageUrls.add('${AppConst.url}/${url}');
          }
        }
      }
    }
    
    // Check if the main image URL is already a full URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Already a full URL, use as is
    } else if (imageUrl.isNotEmpty && !imageUrl.contains(',')) {
      // Relative URL, prepend base URL
      imageUrl = '${AppConst.url}/${imageUrl}';
    } else if (imageUrl.isEmpty || imageUrl.contains(',')) {
      // Empty or contains multiple URLs, use a placeholder
      imageUrl = '${AppConst.url}/placeholder.jpg';
    }
    
    // If we have multiple images, add the main image to the list if it's not already there
    if (imageUrls.isNotEmpty && !imageUrls.contains(imageUrl) && !imageUrl.contains('placeholder.jpg')) {
      imageUrls.insert(0, imageUrl);
    }
    
    return ProductModel(
        title: json['title'],
        image: imageUrl,
        description: json['description'],
        price: double.parse(json['price'].toString()),
        unit: json['unit'],
        unitSize: double.parse(json['unitSize'].toString()),
        id: int.parse(json['id'].toString()),
        categoryId: int.parse(json['categoryId'].toString()),
        showToUser: int.parse(json['showToUser'].toString()),
        images: imageUrls.isNotEmpty ? imageUrls : null);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['image'] = image;
    data['description'] = description;
    data['price'] = price;
    data['unit'] = unit;
    data['unitSize'] = unitSize;
    data['id'] = id;
    data['categoryId'] = categoryId;
    data['showToUser'] = showToUser;
    if (images != null) {
      data['images'] = images;
    }

    return data;
  }

  // Helper to get the first image, for compatibility
  String get firstImage => image;
  
  // Helper to get all images including the main image
  List<String> get allImages {
    if (images != null && images!.isNotEmpty) {
      return images!;
    }
    return [image];
  }
  
  // Helper to check if product has multiple images
  bool get hasMultipleImages => images != null && images!.length > 1;
}