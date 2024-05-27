class UserProfile {
  String? uid;
  String? name;
  String? pfpURL;
  List<String?>? friendList;
  List<String?>?  friendReqList;

  UserProfile({
    required this.uid,
    required this.name,
    required this.pfpURL,
    required this.friendList,
    required this.friendReqList,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    pfpURL = json['pfpURL'];
    friendList = [];
    friendReqList = [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['pfpURL'] = pfpURL;
    data['uid'] = uid;
    return data;
  }
}

