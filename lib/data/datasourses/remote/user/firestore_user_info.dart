import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:instagram/core/resources/strings_manager.dart';
import 'package:instagram/data/models/message.dart';
import 'package:instagram/data/models/sender_info.dart';
import 'package:instagram/data/models/user_personal_info.dart';
import '../../../../core/utility/constant.dart';

class FirestoreUser {
  static final _fireStoreUserCollection =
      FirebaseFirestore.instance.collection('users');

  static Future<void> createUser(UserPersonalInfo newUserInfo) async {
    await _fireStoreUserCollection
        .doc(newUserInfo.userId)
        .set(newUserInfo.toMap());
  }

  static Future<UserPersonalInfo> getUserInfo(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> snap =
        await _fireStoreUserCollection.doc(userId).get();
    if (snap.exists) {
      return UserPersonalInfo.fromDocSnap(snap.data());
    } else {
      return Future.error(StringsManager.userNotExist.tr());
    }
  }

  static Future<List<UserPersonalInfo>> getAllUnFollowersUsers(
      UserPersonalInfo myPersonalInfo) async {
    QuerySnapshot<Map<String, dynamic>> snap =
        await _fireStoreUserCollection.get();
    List<UserPersonalInfo> usersInfo = [];
    for (final doc in snap.docs) {
      UserPersonalInfo formatUser = UserPersonalInfo.fromDocSnap(doc.data());
      bool isThatMe = formatUser.userId == myPersonalInfo.userId;
      bool isThatUserFollowedByMe =
          !myPersonalInfo.followedPeople.contains(formatUser.userId);
      if (!isThatMe && isThatUserFollowedByMe) {
        usersInfo.add(formatUser);
      }
    }
    return usersInfo;
  }

  /// [fieldName] , [userUid] in case one of this users not exist, it will be deleted from the list in fireStore

  static Future<List<UserPersonalInfo>> getSpecificUsersInfo({
    String fieldName = "",
    required List<dynamic> usersIds,
    String userUid = "",
  }) async {
    List<UserPersonalInfo> usersInfo = [];
    List<dynamic> ids = [];
    for (final userid in usersIds) {
      if (!ids.contains(userid)) {
        DocumentSnapshot<Map<String, dynamic>> snap =
            await _fireStoreUserCollection.doc(userid).get();
        if (snap.exists) {
          UserPersonalInfo postReformat =
              UserPersonalInfo.fromDocSnap(snap.data());
          usersInfo.add(postReformat);
        } else {
          if (fieldName.isNotEmpty && userUid.isNotEmpty) {
            await arrayRemoveOfField(
                removeThisId: userid, userUid: userUid, fieldName: fieldName);
          }
        }
        ids.add(userid);
      }
    }
    return usersInfo;
  }

  static Future<List<SenderInfo>> extractUsersIds(
      {required List<SenderInfo> usersInfo}) async {
    for (int i = 0; i < usersInfo.length; i++) {
      if (usersInfo[i].lastMessage != null) {
        String userId = usersInfo[i].lastMessage?.senderId != myPersonalId
            ? usersInfo[i].lastMessage!.senderId
            : usersInfo[i].lastMessage!.receiverId;
        UserPersonalInfo userInfo = await getUserInfo(userId);
        usersInfo[i].userInfo = userInfo;
      }
    }
    return usersInfo;
  }

  static Future<List<SenderInfo>> getChatUserInfo(
      {required String userId}) async {
    List<SenderInfo> allUsers = [];

    DocumentReference<Map<String, dynamic>> userCollection =
        _fireStoreUserCollection.doc(userId);
    userCollection.update({'numberOfNewMessages': 0});
    QuerySnapshot<Map<String, dynamic>> snap =
        await userCollection.collection("chats").get();

    for (int i = 0; i < snap.docs.length; i++) {
      QueryDocumentSnapshot<Map<String, dynamic>> doc = snap.docs[i];
      Message messageInfo = Message.fromJson(doc);
      allUsers.add(SenderInfo(lastMessage: messageInfo));
    }
    return allUsers;
  }

  static updateProfileImage(
      {required String imageUrl, required String userId}) async {
    await _fireStoreUserCollection.doc(userId).update({
      "profileImageUrl": imageUrl,
    });
  }

  static updateUserInfo(UserPersonalInfo userInfo) async {
    await _fireStoreUserCollection
        .doc(userInfo.userId)
        .update(userInfo.toMap());
  }

  static Future<UserPersonalInfo?> getUserFromUserName(
      {required String userName}) async {
    UserPersonalInfo? userPersonalInfo;
    await _fireStoreUserCollection
        .where('userName', isEqualTo: userName)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot<Map<String, dynamic>> snap = snapshot.docs[0];
        userPersonalInfo = UserPersonalInfo.fromDocSnap(snap.data());
      }
    });
    return userPersonalInfo;
  }

  static updateUserPosts(
      {required String userId, required String postId}) async {
    await _fireStoreUserCollection.doc(userId).update({
      'posts': FieldValue.arrayUnion([postId])
    });
  }

  static removeUserPost({required String postId}) async {
    QuerySnapshot<Map<String, dynamic>> document =
        await _fireStoreUserCollection
            .where("posts", arrayContains: postId)
            .get();
    for (var element in document.docs) {
      _fireStoreUserCollection.doc(element.id).update({
        'posts': FieldValue.arrayRemove([postId])
      });
    }
  }

  static updateUserStories(
      {required String userId, required String storyId}) async {
    await _fireStoreUserCollection.doc(userId).update({
      'stories': FieldValue.arrayUnion([storyId])
    });
  }

  static followThisUser(String followingUserId, String myPersonalId) async {
    await _fireStoreUserCollection.doc(followingUserId).update({
      'followers': FieldValue.arrayUnion([myPersonalId])
    });

    await _fireStoreUserCollection.doc(myPersonalId).update({
      'following': FieldValue.arrayUnion([followingUserId])
    });
  }

  static unFollowThisUser(String followingUserId, String myPersonalId) async {
    await _fireStoreUserCollection.doc(followingUserId).update({
      'followers': FieldValue.arrayRemove([myPersonalId])
    });

    await _fireStoreUserCollection.doc(myPersonalId).update({
      'following': FieldValue.arrayRemove([followingUserId])
    });
  }

  static arrayRemoveOfField({
    required String fieldName,
    required String removeThisId,
    required String userUid,
  }) async {
    await _fireStoreUserCollection.doc(userUid).update({
      fieldName: FieldValue.arrayRemove([removeThisId])
    });
  }

  static deleteThisStory({required String storyId}) async {
    await _fireStoreUserCollection.doc(myPersonalId).update({
      'stories': FieldValue.arrayRemove([storyId])
    });
  }

  static Future<List> getSpecificUsersPosts(List<dynamic> usersIds) async {
    List postsInfo = [];
    List<dynamic> usersIdsUnique = [];
    for (int i = 0; i < usersIds.length; i++) {
      if (!usersIdsUnique.contains(usersIds[i])) {
        DocumentSnapshot<Map<String, dynamic>> snap =
            await _fireStoreUserCollection.doc(usersIds[i]).get();
        if (snap.exists) {
          postsInfo += snap.get('posts');
        }
        usersIdsUnique.add(usersIds[i]);
      }
    }
    return postsInfo;
  }

  static Stream<List<UserPersonalInfo>> searchAboutUser(
      {required String name}) {
    name = name.toLowerCase();
    Stream<QuerySnapshot<Map<String, dynamic>>> snapSearch =
        _fireStoreUserCollection
            .where("charactersOfName", arrayContains: name)
            .snapshots();

    return snapSearch.map((snapshot) => snapshot.docs.map((doc) {
          UserPersonalInfo userInfo = UserPersonalInfo.fromDocSnap(doc.data());
          return userInfo;
        }).toList());
  }
}
