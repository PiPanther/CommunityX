import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/providers/firebase_providers.dart';
import 'package:reddit/models/user_model.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
    firestore: ref.read(fireStoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider)));

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository(
      {required FirebaseFirestore firestore,
      required FirebaseAuth auth,
      required GoogleSignIn googleSignIn})
      : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  void signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final credential = GoogleAuthProvider.credential(
          accessToken: (await googleUser?.authentication)?.accessToken,
          idToken: (await googleUser?.authentication)?.idToken);

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print(userCredential.user?.email ?? "");

      UserModel userModel = UserModel(
          name: userCredential.user?.displayName ?? "No Name",
          profilePic: userCredential.user?.photoURL ?? Constants.pfp,
          banner: Constants.banner,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          karma: 0,
          awards: []);
    } catch (E) {
      print(E.toString());
    }
  }
}
