import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/community/controllers/community_controllers.dart';
import 'package:reddit/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, Community community) {
    Routemaster.of(context).push('/r/${community.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          ListTile(
            title: const Text('Create a community'),
            leading: const Icon(Icons.add),
            onTap: () => navigateToCreateCommunity(context),
          ),
          ref.watch(userCommunityProvider).when(
              data: (communities) => Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: communities.length,
                      itemBuilder: (BuildContext context, index) {
                        final community = communities[index];
                        return ListTile(
                          onTap: () {
                            navigateToCommunity(context, community);
                          },
                          title: Text('r/${community.name}'),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(community.avatar),
                          ),
                        );
                      },
                    ),
                  ),
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader()),
        ],
      )),
    );
  }
}
