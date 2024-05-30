class UserProfile {
  String? uid;
  String? firstName;
  String? lastName;
  String? pfpURL;
  String? profileCoverURL;
  List<String?>? friendList;
  List<String?>? friendReqList;

  UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.pfpURL,
    required this.friendList,
    required this.friendReqList,
    required this.profileCoverURL,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    pfpURL = json['pfpURL'];
    profileCoverURL = json['profileCoverURL'];
    if (json['friendList'] != null) {
      friendList = List<String>.from(json['friendList']);
    } else {
      friendList = [];
    }
    if (json['friendReqList'] != null) {
      friendReqList = List<String>.from(json['friendReqList']);
    } else {
      friendReqList = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['pfpURL'] = pfpURL;
    data['profileCoverURL'] = profileCoverURL;
    data['uid'] = uid;
    data['friendList'] = friendList;
    data['friendReqList'] = friendReqList;
    return data;
  }
}
