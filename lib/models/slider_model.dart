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
    return SliderModel(
      title: json['title'],
      subtitle: json['subtitle'],
      image: '${AppConst.url}/${json['image']}',
      color: json['color'],
      id: int.parse(json['id'].toString()),
      showToUser: int.parse(json['showToUser'].toString()),
    );
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
