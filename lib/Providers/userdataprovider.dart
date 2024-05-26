import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Userdataprovider extends ChangeNotifier {
  Map<String, dynamic> userData = {};
  String userId = '';
  Future<void> loaduserdata(String? phoneno) async {
    if (FirebaseAuth.instance.currentUser == null) {
      CollectionReference mobileUsers =
          FirebaseFirestore.instance.collection('mobileusers');
      userId = phoneno!.codeUnits.join('-');
      DocumentSnapshot snapshot = await mobileUsers.doc(userId).get();
      userData = snapshot.data() as Map<String, dynamic>;
    } else {
      userId = FirebaseAuth.instance.currentUser!.uid;
      CollectionReference googleUsers =
          FirebaseFirestore.instance.collection('googleusers');
      DocumentSnapshot snapshot = await googleUsers.doc(userId).get();
      userData = snapshot.data() as Map<String, dynamic>;
    }
  }
}
