// Copyright (c) 2022, Kato Shinya. All rights reserved.
// Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:github/github.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:github_follow_status/src/component/common_app_bar_title.dart';
import 'package:github_follow_status/src/component/common_nested_scroll_view.dart';

class UnfollowerListView extends StatefulWidget {
  const UnfollowerListView({Key? key}) : super(key: key);

  @override
  State<UnfollowerListView> createState() => _UnfollowerListViewState();
}

class _UnfollowerListViewState extends State<UnfollowerListView> {
  /// The text editing controller for GitHub token
  final _tokenTextController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CommonNestedScrollView(
          title: const CommonAppBarTitle(title: 'Unfollow User'),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(350, 20, 350, 10),
                child: TextField(
                  controller: _tokenTextController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: "GitHub OAuth Access Token",
                    hintText: "Enter your access token here",
                  ),
                  onSubmitted: (value) {
                    super.setState(() {
                      _tokenTextController.text = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: _fetchUnfollowers(
                    token: _tokenTextController.text,
                  ),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final List<User> unfollowers = snapshot.data;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(200, 0, 200, 0),
                      child: ListView.builder(
                        itemCount: unfollowers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 5,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30),
                                bottom: Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title:
                                          Text('${unfollowers[index].login}'),
                                      subtitle:
                                          Text('${unfollowers[index].id}'),
                                      onTap: () async {
                                        await launch(
                                          'https://github.com/${unfollowers[index].login}',
                                        );
                                      },
                                    ),
                                  ),
                                  ElevatedButton(
                                    child: const Text('Unfollow'),
                                    onPressed: () async {
                                      final unfollowed = await _unfollow(
                                        token: _tokenTextController.text,
                                        username: '${unfollowers[index].login}',
                                      );

                                      if (!unfollowed) {
                                        // do somthing when it's failed
                                      }

                                      super.setState(() {});
                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Future<bool> _unfollow({
    required String token,
    required String username,
  }) async {
    final github = GitHub(
      auth: Authentication.withToken(token),
    );

    return await github.users.unfollowUser(username);
  }

  Future<List<User>> _fetchUnfollowers({
    required String token,
  }) async {
    final github = GitHub(
      auth: Authentication.withToken(token),
    );

    final followers = await github.users.listCurrentUserFollowers().toList();
    final followings = await github.users.listCurrentUserFollowing().toList();

    final unfollowers = <User>[];
    for (final following in followings) {
      bool followed = false;
      for (final follower in followers) {
        if (following.id == follower.id) {
          followed = true;
          break;
        }
      }

      if (!followed) {
        unfollowers.add(following);
      }
    }

    return unfollowers;
  }
}
