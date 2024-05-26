import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cnic_scanner/cnic_scanner.dart';
import 'package:cnic_scanner/model/cnic_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Completeprofileprovider extends ChangeNotifier {
  TextEditingController genderController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  bool loading = false;
  File? image;
  String url = '';
  String btntxt = 'Scan';
  bool enabled = true;

  void changebuttonstate(bool btnstate) {
    enabled = btnstate;
    notifyListeners();
  }

  void cleartextcontroller() {
    genderController.text = '';
    usernameController.text = '';
  }

  Future<void> scanCnic(ImageSource imageSource, BuildContext context,
      CollectionReference collectionName, String docid) async {
    loading = true;
    notifyListeners();
    CnicModel cnicModel =
        await CnicScanner().scanImage(imageSource: imageSource);
    genderController.text = cnicModel.cnicHolderGender;
    usernameController.text = cnicModel.cnicHolderName;
    btntxt = 'Proceed';
    notifyListeners();

    await collectionName.doc(docid).set({
      'Gender': cnicModel.cnicHolderGender,
      'Username': cnicModel.cnicHolderName,
      'Profileimage': url,
    }, SetOptions(merge: true));
    loading = false;
    notifyListeners();
  }

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      notifyListeners();
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('user_profile_pics/${DateTime.now().toString()}');
      final uploadTask = storageReference.putFile(image!);
      await uploadTask.whenComplete(() async {
        url = await storageReference.getDownloadURL();
      });
    }
  }
}
