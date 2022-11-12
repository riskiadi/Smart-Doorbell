class UserRegisteredList {
  bool? _access;
  String? _createdDate;
  String? _name;
  String? _avatar;
  int? _createdUnix;
  String? _email;
  String? _idToken;


  bool? get access => _access;

  String? get createdDate => _createdDate;

  String? get name => _name;

  String? get avatar => _avatar;

  int? get createdUnix => _createdUnix;

  String? get email => _email;

  String? get idToken => _idToken;

  UserRegisteredList(
      {bool? access,
      String? createdDate,
      String? name,
      String? avatar,
      int? createdUnix,
      String? email,
      String? idToken,}) {
    _access = access;
    _createdDate = createdDate;
    _name = name;
    _avatar = avatar;
    _createdUnix = createdUnix;
    _email = email;
    _idToken = idToken;
  }

  UserRegisteredList.fromJson(dynamic json) {
    _access = json["access"];
    _createdDate = json["createdDate"];
    _name = json["name"];
    _avatar = json["avatar"];
    _createdUnix = json["createdUnix"];
    _email = json["email"];
    _idToken = json["idToken"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["access"] = _access;
    map["createdDate"] = _createdDate;
    map["name"] = _name;
    map["avatar"] = _avatar;
    map["createdUnix"] = _createdUnix;
    map["email"] = _email;
    map["idToken"] = _idToken;
    return map;
  }

}
