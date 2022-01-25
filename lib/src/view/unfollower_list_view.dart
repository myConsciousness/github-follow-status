// Copyright (c) 2022, Kato Shinya. All rights reserved.
// Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:github/github.dart';

class UnfollowerListView extends StatefulWidget {
  const UnfollowerListView({Key? key}) : super(key: key);

  @override
  State<UnfollowerListView> createState() => _UnfollowerListViewState();
}

class _UnfollowerListViewState extends State<UnfollowerListView> {
  /// GitHub API
  final github = GitHub(
    auth: Authentication.withToken(''),
  );

  /// The text editing controller for GitHub token
  final _tokenTextController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _tokenTextController,
              onChanged: (value) {
                super.setState(() {
                  _tokenTextController.text = value;
                });
              },
              onSubmitted: (value) {
                super.setState(() {
                  _tokenTextController.text = value;
                });
              },
            ),
            FutureBuilder(
              future: _fetchUnfollowers(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final List<User> unfollowers = snapshot.data;

                return ListView.builder(
                  itemCount: unfollowers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        title: Text('${unfollowers[index].id}'),
                        subtitle: Text(unfollowers[index].login ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      );

  Future<List<User>> _fetchUnfollowers() async {
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
