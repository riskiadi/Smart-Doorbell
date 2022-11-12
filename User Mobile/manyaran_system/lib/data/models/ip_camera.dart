class IPCamera {
  IPCamera({
      String? ipLocal, 
      String? name, 
      bool? isOnline,
      String? ipInternet,}){
    _ipLocal = ipLocal;
    _name = name;
    _isOnline = isOnline;
    _ipInternet = ipInternet;
}

  IPCamera.fromJson(dynamic json) {
    _ipLocal = json['ip_local'];
    _name = json['name'];
    _isOnline = json['is_online'];
    _ipInternet = json['ip_internet'];
  }
  String? _ipLocal;
  String? _name;
  bool? _isOnline;
  String? _ipInternet;

  String? get ipLocal => _ipLocal;
  String? get name => _name;
  bool? get isOnline => _isOnline;
  String? get ipInternet => _ipInternet;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ip_local'] = _ipLocal;
    map['name'] = _name;
    map['is_online'] = _isOnline;
    map['ip_internet'] = _ipInternet;
    return map;
  }

}