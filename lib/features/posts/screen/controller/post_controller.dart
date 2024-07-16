import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/enums/enums.dart';
import 'package:reddit/core/providers/storage_repository_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controllers/auth_controller.dart';
import 'package:reddit/features/posts/screen/repository/post_repository.dart';
import 'package:reddit/features/user_profile/controllers/user_profile_controllers.dart';
import 'package:reddit/models/comment_model.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.read(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryStorageProvider);
  return PostController(
      storageRepo: storageRepository, postRepository: postRepository, ref: ref);
});

final userPostsProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPost(communities);
});

final getPostByIdProvider = StreamProvider.family((ref, String postID) {
  return ref.watch(postControllerProvider.notifier).getPostbyId(postID);
});

final getCommentOfPostProvider = StreamProvider.family((ref, String postID) {
  return ref.watch(postControllerProvider.notifier).fetchPostComments(postID);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController(
      {required PostRepository postRepository,
      required Ref ref,
      required storageRepo})
      : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepo,
        super(false);

  void shareText(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String description}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider);

    final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfile: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCounts: 0,
        username: user!.name,
        uid: user.uid,
        type: 'text',
        createdAt: DateTime.now(),
        awards: [],
        description: description);

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;

    res.fold((left) => showSnackBar(context, left.message), (right) {
      showSnackBar(context, "Posted Successfully");
      Routemaster.of(context).pop();
    });
  }

  void shareLinkPost(
      {required BuildContext context,
      required String title,
      required Community selectedCommunity,
      required String link}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider);

    final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfile: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCounts: 0,
        username: user!.name,
        uid: user.uid,
        type: 'link',
        createdAt: DateTime.now(),
        awards: [],
        link: link);

    final res = await _postRepository.addPost(post);
    state = false;
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    res.fold((left) => showSnackBar(context, left.message), (right) {
      showSnackBar(context, "Posted Successfully");
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required File? file,
    required Community selectedCommunity,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider);

    final imageResult = await _storageRepository.storeFiles(
        path: 'posts/${selectedCommunity.name}', id: postId, file: file);

    imageResult.fold((left) => showSnackBar(context, left.message),
        (right) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfile: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCounts: 0,
        username: user!.name,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        link: right,
      );

      final res = await _postRepository.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;
      res.fold((left) => showSnackBar(context, left.message), (right) {
        showSnackBar(context, "Posted Successfully");
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<Post>> fetchUserPost(List<Community> community) {
    if (community.isNotEmpty) {
      return _postRepository.fetchUserPosts(community);
    }
    return Stream.value([]);
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);

    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);

    res.fold((left) => null,
        (right) => showSnackBar(context, "Post deleted successfully"));
  }

  void upvote(Post post) async {
    final userId = _ref.read(userProvider)!.uid;
    _postRepository.upvote(post, userId);
  }

  void downvote(Post post) async {
    final userId = _ref.read(userProvider)!.uid;
    _postRepository.downvote(post, userId);
  }

  Stream<Post> getPostbyId(String postId) {
    return _postRepository.getPostbyId(postId);
  }

  void addComment(
      {required BuildContext context,
      required String text,
      required Post post}) async {
    final user = _ref.read(userProvider);
    final commentId = const Uuid().v4();
    Comment comment = Comment(
        id: commentId,
        text: text,
        createdAt: DateTime.now(),
        postId: post.id,
        username: user!.name,
        profilePic: user.profilePic);

    final res = await _postRepository.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
    res.fold((left) => showSnackBar(context, "Failed to add comment"),
        (right) => null);
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.getCommentOfPost(postId);
  }
}
