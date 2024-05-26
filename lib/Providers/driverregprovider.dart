// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridemate/Methods/drivermethods.dart';

class Driverregprovider1 extends ChangeNotifier {
  String frontimage = '';
  String backimage = '';
  bool loading = false;

  void updatefrontpath(String path) {
    frontimage = path;
    notifyListeners();
  }

  void updatebackpath(String path) {
    backimage = path;
    notifyListeners();
  }

  bool checkisempty() {
    return frontimage == '' || backimage == '';
  }

  Future<void> savedriverdetails(String userid, String datatype, String url1,
      String url2, String cnicno) async {
    final collection = FirebaseFirestore.instance.collection('drivers');
    cnicno.isEmpty
        ? await collection.doc(userid).set({
            '$datatype Frontside': url1,
            '$datatype Backside': url2,
          }, SetOptions(merge: true))
        : await collection.doc(userid).set({
            '$datatype Frontside': url1,
            '$datatype Backside': url2,
            'Cnicno': cnicno,
          }, SetOptions(merge: true));
  }

  Future<void> saveImages(String userId, String folderName, String cnicno,
      BuildContext context) async {
    loading = true;
    notifyListeners();
    final frontImageFile = File(frontimage);
    final frontImageRef = FirebaseStorage.instance
        .ref('drivers/$userId/$folderName/frontimage.png');
    await frontImageRef.putFile(frontImageFile);

    final backImageFile = File(backimage);
    final backImageRef = FirebaseStorage.instance
        .ref('drivers/$userId/$folderName/backimage.png');
    await backImageRef.putFile(backImageFile);
    final url1 = await frontImageRef.getDownloadURL();
    final url2 = await backImageRef.getDownloadURL();

    await savedriverdetails(userId, folderName, url1, url2, cnicno);
    loading = false;
    notifyListeners();
    await checkit(userId, context);
  }
}

class Cardrivercnic extends Driverregprovider1 {}

class Cardriverlicence extends Driverregprovider1 {}

class Motodrivercnic extends Driverregprovider1 {}

class Motodriverlicence extends Driverregprovider1 {}

class Driverregprovider2 extends ChangeNotifier {
  File? image;
  bool loading = false;
  void updateimage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      notifyListeners();
    }
  }

  bool checkisempty() {
    return image == null;
  }

  Future<void> savedriverdetails(
      String userid, String datatype, String url1) async {
    final collection = FirebaseFirestore.instance.collection('drivers');
    await collection.doc(userid).set({
      datatype: url1,
    }, SetOptions(merge: true));
  }

  Future<void> saveImage(
      String userId, String folderName, BuildContext context) async {
    loading = true;
    notifyListeners();
    final imageRef =
        FirebaseStorage.instance.ref('drivers/$userId/$folderName/image.jpg');
    await imageRef.putFile(image!);
    final url1 = await imageRef.getDownloadURL();
    await savedriverdetails(userId, folderName, url1);
    loading = false;
    notifyListeners();
    await checkit(userId, context);
  }
}

class Motobasicinfo extends Driverregprovider2 {}

class Carbasicinfo extends Driverregprovider2 {}

class Motoselfieid extends Driverregprovider2 {}

class Carselfieid extends Driverregprovider2 {}

class Motovehiclephoto extends Driverregprovider2 {}

class Carvehiclephoto extends Driverregprovider2 {}

class Driverregprovider3 extends ChangeNotifier {
  File? img1;
  File? img2;
  bool loading = false;
  void updateimg1() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      img1 = File(pickedFile.path);
      notifyListeners();
    }
  }

  void updateimg2() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      img2 = File(pickedFile.path);
      notifyListeners();
    }
  }

  bool checkisempty() {
    return img1 == null || img2 == null;
  }

  Future<void> savedriverdetails(
      String userid, String datatype, String url1, String url2) async {
    final collection = FirebaseFirestore.instance.collection('drivers');
    await collection.doc(userid).set({
      '$datatype Frontside': url1,
      '$datatype Backside': url2,
    }, SetOptions(merge: true));
  }

  Future<void> saveImages(
      String userId, String folderName, BuildContext context) async {
    loading = true;
    notifyListeners();
    final imageRef1 =
        FirebaseStorage.instance.ref('drivers/$userId/$folderName/img1.jpg');
    final imageRef2 =
        FirebaseStorage.instance.ref('drivers/$userId/$folderName/img2.jpg');
    await imageRef1.putFile(img1!);
    await imageRef2.putFile(img2!);
    final url1 = await imageRef1.getDownloadURL();
    final url2 = await imageRef2.getDownloadURL();
    await savedriverdetails(userId, folderName, url1, url2);
    loading = false;
    notifyListeners();
    await checkit(userId, context);
  }
}

class Carreg extends Driverregprovider3 {}

class Motoreg extends Driverregprovider3 {}

class Transportnameprovider extends ChangeNotifier {
  bool loading = false;
  Future<void> savedetail(String userId, String transportname,
      String tranposrtnumber, BuildContext context) async {
    final collection = FirebaseFirestore.instance.collection('drivers');
    loading = true;
    notifyListeners();
    await collection.doc(userId).set({
      'Transportname': transportname,
      'Vehicle_Number': tranposrtnumber,
    }, SetOptions(merge: true));
    loading = false;
    notifyListeners();
    await checkit(userId, context);
  }
}
