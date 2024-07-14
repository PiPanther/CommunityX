import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controllers/auth_controller.dart';
import 'package:reddit/features/community/repository/community_repository.dart';
import 'package:reddit/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  CommunityRepository communityRepository =
      ref.read(communityRepositoryProvider);
  return CommunityController(
      communityController: communityRepository, ref: ref);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  CommunityController(
      {required CommunityRepository communityController, required Ref ref})
      : _communityRepository = communityController,
        _ref = ref,
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
}
