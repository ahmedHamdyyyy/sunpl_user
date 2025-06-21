import 'package:userapp/utils/app_const.dart';

class CategoryModel {
  CategoryModel({
    required this.title,
    required this.image,
    this.id,
    required this.showToUser,
  });

  final String title;
  final String image;
  final int showToUser;
  final int? id;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle null or missing values
      final title = json['title']?.toString() ?? 'Unknown Category';
      final image = json['image']?.toString() ?? '';
      final id = json['id']?.toString();
      final showToUser = json['showToUser']?.toString() ?? '1';
      
      // Build image URL safely
      String imageUrl = '';
      if (image.isNotEmpty) {
        if (image.startsWith('http')) {
          imageUrl = image;
        } else {
          imageUrl = '${AppConst.url}/${image.replaceFirst('/', '')}';
        }
      }
      
      return CategoryModel(
        title: title,
        image: imageUrl,
        id: id != null ? int.tryParse(id) : null,
        showToUser: int.tryParse(showToUser) ?? 1,
      );
    } catch (e) {
      print('Error parsing CategoryModel: $e');
      print('JSON data: $json');
      // Return a default category if parsing fails
      return CategoryModel(
        title: 'Unknown Category',
        image: '',
        id: null,
        showToUser: 1,
      );
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['image'] = image;
    data['id'] = id;
    data['showToUser'] = showToUser;
    return data;
  }
}
