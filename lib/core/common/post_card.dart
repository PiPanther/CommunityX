import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkable/linkable.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controllers/auth_controller.dart';
import 'package:reddit/features/community/controllers/community_controllers.dart';
import 'package:reddit/features/posts/screen/controller/post_controller.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void navigateToUserProfile(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunityProfile(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/posts/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider);
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    return Column(children: [
      Container(
        color: currentTheme.secondaryHeaderColor,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
                child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                          .copyWith(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  navigateToCommunityProfile(context);
                                },
                                child: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(post.communityProfile),
                                  radius: 16,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "r/${post.communityName}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        navigateToUserProfile(context);
                                      },
                                      child: Text(
                                        "u/${post.username}",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (post.uid == user!.uid)
                            IconButton(
                              onPressed: () {
                                deletePost(ref, context);
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Pallete.redColor,
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          post.title,
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isTypeImage)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          child: Image.network(
                            post.link!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (isTypeLink)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          height: MediaQuery.of(context).size.height * 0.12,
                          width: double.infinity,
                          decoration:
                              BoxDecoration(color: currentTheme.cardColor),
                          child: Linkable(text: post.link!),
                        ),
                      if (isTypeText)
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              post.description!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  upvotePost(ref);
                                },
                                icon: Icon(
                                  Constants.up,
                                  size: 30,
                                  color: post.upvotes.contains(user.uid)
                                      ? Pallete.redColor
                                      : null,
                                ),
                              ),
                              Text(
                                  style: const TextStyle(fontSize: 17),
                                  '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}'),
                              IconButton(
                                onPressed: () {
                                  downvotePost(ref);
                                },
                                icon: Icon(
                                  Constants.down,
                                  size: 30,
                                  color: post.downvotes.contains(user.uid)
                                      ? Pallete.redColor
                                      : null,
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  navigateToComments(context);
                                },
                                icon: Icon(
                                  Icons.comment,
                                  size: 30,
                                  color: post.upvotes.contains(user.uid)
                                      ? Pallete.blueColor
                                      : null,
                                ),
                              ),
                              Text(
                                style: const TextStyle(fontSize: 17),
                                '${post.commentCounts == 0 ? 'Comment' : post.commentCounts}',
                              ),
                            ],
                          ),
                          ref
                              .watch(getCommunityByNameProvider(
                                  post.communityName))
                              .when(
                                data: (data) {
                                  if (data.mods.contains(user.uid)) {
                                    return IconButton(
                                        onPressed: () =>
                                            deletePost(ref, context),
                                        icon: const Icon(Icons
                                            .admin_panel_settings_outlined));
                                  }
                                  return const SizedBox();
                                },
                                error: (error, stackTrace) =>
                                    ErrorText(error: error.toString()),
                                loading: () => const Loader(),
                              ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ))
          ],
        ),
      )
    ]);
  }
}
