class UserProfile {
  String? uid;
  String? firstName;
  String? lastName;
  String? pfpURL;
  String? profileCoverURL;
  String? year;
  List<String?>? friendList;
  List<String?>? friendReqList;
  List<String?>? currentModules;
  List<String?>? completedModules;
  List<String?>? chats;

  UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.pfpURL,
    required this.year,
    required this.friendList,
    required this.friendReqList,
    required this.profileCoverURL,
    required this.completedModules,
    required this.currentModules,
    required this.chats,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    pfpURL = json['pfpURL'];
    profileCoverURL = json['profileCoverURL'];
    year = json['year'];
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
    if (json['completedModules'] != null) {
      completedModules = List<String>.from(json['completedModules']);
    } else {
      completedModules = [];
    }
    if (json['currentModules'] != null) {
      currentModules = List<String>.from(json['currentModules']);
    } else {
      currentModules = [];
    }
    if (json['chats'] != null) {
      currentModules = List<String>.from(json['chats']);
    } else {
      currentModules = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['pfpURL'] = pfpURL;
    data['profileCoverURL'] = profileCoverURL;
    data['uid'] = uid;
    data['year'] = year;
    data['friendList'] = friendList;
    data['friendReqList'] = friendReqList;
    data['completedModule'] = completedModules;
    data['currentModule'] = currentModules;
    data['chats'] = chats;
    return data;
  }
}
