import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ridemate/Providers/completeprofileprovider.dart';
import 'package:ridemate/view/Authentication/view/Completeprofile/completeprofile.dart';
import '../../routing/routing.dart';
import '../../view/Homepage/homepage.dart';

class Googleloginprovider extends ChangeNotifier {
  bool loading = false;

  Future<void> signInWithGoogle(BuildContext context) async {
    loading = true;
    notifyListeners();
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((userCredential) async {
      final userid = FirebaseAuth.instance.currentUser!.uid;
      CollectionReference googleUsers =
          FirebaseFirestore.instance.collection('googleusers');
      bool documentExists =
          await googleUsers.doc(userid).get().then((doc) => doc.exists);

      if (!documentExists) {
        await googleUsers.doc(userid).set({
          'Email': userCredential.user!.email,
          'role': 'User',
        }).then((value) {
          loading = false;
          notifyListeners();
          final cnicprovider =
              Provider.of<Completeprofileprovider>(context, listen: false);
          navigateToScreen(
            context,
            Completeprofile(
              onPressed1: () {
                Navigator.pop(context);
                cnicprovider.scanCnic(
                    ImageSource.camera, context, googleUsers, userid);
              },
            ),
          );
        });
      } else {
        loading = false;
        notifyListeners();
        // ignore: use_build_context_synchronously
        navigateandremove(context, const Homepage());
      }
    });
  }
}
