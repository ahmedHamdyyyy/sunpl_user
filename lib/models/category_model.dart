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
    return CategoryModel(
        title: json['title'],
        image: '${AppConst.url}/${json['image']}',
        id: int.parse(json['id'].toString()),
        showToUser: int.parse(json['showToUser'].toString()));
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
