import 'package:userapp/utils/app_const.dart';

class SliderModel {
  SliderModel({
    required this.title,
    required this.subtitle,
    this.image,
    this.color,
    required this.showToUser,
    this.id,
  });

  final String title;
  final String subtitle;
  final String? image;
  final String? color;
  final int? id;
  final int? showToUser;

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle null or missing values
      final title = json['title']?.toString() ?? 'Unknown Title';
      final subtitle = json['subtitle']?.toString() ?? 'Unknown Subtitle';
      final image = json['image']?.toString();
      final color = json['color']?.toString();
      final id = json['id']?.toString();
      final showToUser = json['showToUser']?.toString() ?? '1';
      
      // Build image URL safely
      String? imageUrl;
      if (image != null && image.isNotEmpty) {
        if (image.startsWith('http')) {
          imageUrl = image;
        } else {
          imageUrl = '${AppConst.url}/${image.replaceFirst('/', '')}';
        }
      }
      
      return SliderModel(
        title: title,
        subtitle: subtitle,
        image: imageUrl,
        color: color,
        id: id != null ? int.tryParse(id) : null,
        showToUser: int.tryParse(showToUser) ?? 1,
      );
    } catch (e) {
      print('Error parsing SliderModel: $e');
      print('JSON data: $json');
      // Return a default slider if parsing fails
      return SliderModel(
        title: 'Unknown Title',
        subtitle: 'Unknown Subtitle',
        image: null,
        color: null,
        id: null,
        showToUser: 1,
      );
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['subtitle'] = subtitle;
    data['image'] = image;
    data['color'] = color;
    data['id'] = id;
    data['showToUser'] = showToUser;
    return data;
  }
}
