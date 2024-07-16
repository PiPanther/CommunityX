import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/providers/failures.dart';
import 'package:reddit/core/providers/storage_repository_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controllers/auth_controller.dart';
import 'package:reddit/features/community/repository/community_repository.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

final userCommunityProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunity();
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  CommunityRepository communityRepository =
      ref.read(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryStorageProvider);
  return CommunityController(
      storageRepo: storageRepository,
      communityController: communityRepository,
      ref: ref);
});

final getCommunityPostProvider = StreamProvider.family((ref, String name) {
  return ref.read(communityControllerProvider.notifier).getCommunityPosts(name);
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController(
      {required CommunityRepository communityController,
      required Ref ref,
      required storageRepo})
      : _communityRepository = communityController,
        _ref = ref,
        _storageRepository = storageRepo,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? "";
    Community community = Community(
        id: name,
        name: name,
        banner: Constants.banner,
        avatar: Constants.pfp,
        members: [uid],
        mods: [uid]);

    final result = await _communityRepository.createCommunity(community);
    state = false;

    result.fold((left) => showSnackBar(context, left.message), (right) {
      showSnackBar(context, "Community created successfully !");
      Routemaster.of(context).pop();
    });
  }

  void joinCommunity(Community communityName, BuildContext context) async {
    final user = _ref.read(userProvider)!;
    Either<Failure, void> result;
    if (communityName.members.contains(user.uid)) {
      result = await _communityRepository.leaveCommunity(
          communityName.name, user.uid);
    } else {
      result = await _communityRepository.joinCommunity(
          communityName.name, user.uid);
    }

    result.fold((left) => showSnackBar(context, left.message), (right) {
      if (communityName.members.contains(user.uid)) {
        showSnackBar(context, 'Community left successfully');
      } else {
        showSnackBar(context, 'Community joined successfully');
      }
    });
  }

  Stream<List<Community>> getUserCommunity() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunity(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity(
      {required BuildContext context,
      required File? profilePic,
      required File? bannerProfile,
      required Community community}) async {
    state = true;
    if (profilePic != null) {
      final res = await _storageRepository.storeFiles(
          path: 'communities/profile', id: community.name, file: profilePic);

      res.fold((left) => showSnackBar(context, left.message),
          (right) => community = community.copyWith(avatar: right));
    }
    if (bannerProfile != null) {
      final res = await _storageRepository.storeFiles(
          path: 'communities/banner', id: community.name, file: bannerProfile);

      res.fold((left) => showSnackBar(context, left.message),
          (right) => community = community.copyWith(banner: right));
    }

    final result = await _communityRepository.editCommunity(community);
    state = false;
    result.fold(
      (left) => showSnackBar(context, left.message),
      (right) => Routemaster.of(context).pop(),
    );
  }

  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityName, uids);

    res.fold((left) => showSnackBar(context, left.message),
        (right) => Routemaster.of(context).pop());
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _communityRepository.getCommunityPost(name);
  }
}
