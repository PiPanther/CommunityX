import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/providers/storage_repository_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controllers/auth_controller.dart';
import 'package:reddit/features/user_profile/repositories/user_profile_repository.dart';
import 'package:reddit/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.read(userProfileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryStorageProvider);
  return UserProfileController(
      storageRepo: storageRepository,
      communityController: userProfileRepository,
      ref: ref);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  UserProfileController(
      {required UserProfileRepository communityController,
      required Ref ref,
      required storageRepo})
      : _userProfileRepository = communityController,
        _ref = ref,
        _storageRepository = storageRepo,
        super(false);

  void editCommunity({
    required BuildContext context,
    required File? profilePic,
    required File? bannerProfile,
    required String name,
  }) async {
    state = true;

    UserModel user = _ref.read(userProvider)!;
    state = true;
    if (profilePic != null) {
      final res = await _storageRepository.storeFiles(
          path: 'users/profile', id: user.uid, file: profilePic);

      res.fold((left) => showSnackBar(context, left.message),
          (right) => user = user.copyWith(profilePic: right));
    }
    if (bannerProfile != null) {
      final res = await _storageRepository.storeFiles(
          path: 'communities/banner', id: user.uid, file: bannerProfile);

      res.fold((left) => showSnackBar(context, left.message),
          (right) => user = user.copyWith(banner: right));
    }

    user = user.copyWith(name: name);

    final result = await _userProfileRepository.editProfile(user);
    state = false;
    result.fold(
      (left) => showSnackBar(context, left.message),
      (right) {
        _ref.read(userProvider.notifier).update((state) => user);
        Routemaster.of(context).pop();
      },
    );
  }
}
