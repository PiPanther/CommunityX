import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/providers/failures.dart';
import 'package:reddit/core/providers/firebase_providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/post_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(
    firestore: ref.watch(fireStoreProvider),
  );
});

class PostRepository {
  final FirebaseFirestore _firebaseFirestore;
  PostRepository({required FirebaseFirestore firestore})
      : _firebaseFirestore = firestore;

  CollectionReference get _post =>
      _firebaseFirestore.collection(FirebaseConstants.postsCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(_post.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
