class UserProfile {
  String? bio;
  String? firstName;
  String? lastName;
  String? pfpURL;
  String? profileCoverURL;
  String? uid;
  String? year;

  List<String?>? bookmarks;
  List<String?>? chats;
  List<String?>? completedModules;
  List<String?>? currentModules;
  List<String?>? friendList;
  List<String?>? friendReqList;
  List<String?>? myComments;
  List<String?>? myPosts;
  List<String?>? myLikedComments;
  List<String?>? myLikedPosts;

  UserProfile({
    this.bio,
    this.firstName,
    this.lastName,
    this.pfpURL,
    this.profileCoverURL,
    this.uid,
    this.year,
    this.bookmarks,
    this.chats,
    this.completedModules,
    this.currentModules,
    this.friendList,
    this.friendReqList,
    this.myComments,
    this.myLikedComments,
    this.myPosts,
    this.myLikedPosts,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    bio = json['bio'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    pfpURL = json['pfpURL'];
    profileCoverURL = json['profileCoverURL'];
    uid = json['uid'];
    year = json['year'];
    bookmarks = json['bookmarks'] != null ? List<String>.from(json['bookmarks']) : [];
    chats = json['chats'] != null ? List<String>.from(json['chats']) : [];
    completedModules = json['completedModules'] != null
        ? List<String>.from(json['completedModules'])
        : [];
    currentModules = json['currentModules'] != null
        ? List<String>.from(json['currentModules'])
        : [];
    friendList =
        json['friendList'] != null ? List<String>.from(json['friendList']) : [];
    friendReqList = json['friendReqList'] != null
        ? List<String>.from(json['friendReqList'])
        : [];
    myComments =
        json['myComments'] != null ? List<String>.from(json['myComments']) : [];
    myLikedComments = json['myLikedComments'] != null
        ? List<String>.from(json['myLikedComments'])
        : [];
    myPosts = json['myPost'] != null ? List<String>.from(json['myPosts']) : [];
    myLikedPosts = json['myLikedPosts'] != null
        ? List<String>.from(json['myLikedPosts'])
        : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bio'] = bio;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['pfpURL'] = pfpURL;
    data['profileCoverURL'] = profileCoverURL;
    data['uid'] = uid;
    data['year'] = year;
    data['bookmarks'] = bookmarks;
    data['chats'] = chats;
    data['completedModules'] = completedModules;
    data['currentModules'] = currentModules;
    data['friendList'] = friendList;
    data['friendReqList'] = friendReqList;
    data['myComments'] = myComments;
    data['myLikedComments'] = myLikedComments;
    data['myPosts'] = myPosts;
    data['myLikedPosts'] = myLikedPosts;

    return data;
  }
}
