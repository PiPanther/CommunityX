import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/providers/failures.dart';
import 'package:reddit/core/providers/firebase_providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/comment_model.dart';
import 'package:reddit/models/community_model.dart';
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
  CollectionReference get _comments =>
      _firebaseFirestore.collection(FirebaseConstants.commentsCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(_post.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _post
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_post.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upvote(Post post, String uid) async {
    if (post.downvotes.contains(uid)) {
      _post.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([uid])
      });
    }
    if (post.upvotes.contains(uid)) {
      _post.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([uid])
      });
    } else {
      _post.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([uid])
      });
    }
  }

  void downvote(Post post, String uid) async {
    if (post.upvotes.contains(uid)) {
      _post.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([uid])
      });
    }
    if (post.downvotes.contains(uid)) {
      _post.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([uid])
      });
    } else {
      _post.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([uid])
      });
    }
  }

  Stream<Post> getPostbyId(String postId) {
    return _post
        .doc(postId)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());
      return right(_post
          .doc(comment.postId)
          .update({'commentCount': FieldValue.increment(1)}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> getCommentOfPost(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Comment.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }
}
