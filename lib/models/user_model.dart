class UserModel {
  UserModel({required this.uid, required this.phone});
  final String uid;
  final String phone;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['phone'] = phone;
    return data;
  }
}
