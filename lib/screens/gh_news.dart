import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:git_touch/models/github.dart';
import 'package:git_touch/models/notification.dart';
import 'package:git_touch/scaffolds/list_stateful.dart';
import 'package:git_touch/utils/utils.dart';
import 'package:git_touch/widgets/app_bar_title.dart';
import 'package:provider/provider.dart';
import 'package:git_touch/widgets/event_item.dart';
import 'package:git_touch/models/auth.dart';

class GhNewsScreen extends StatefulWidget {
  @override
  GhNewsScreenState createState() => GhNewsScreenState();
}

class GhNewsScreenState extends State<GhNewsScreen> {
  @override
  initState() {
    super.initState();
    Future.microtask(() async {
      // Check if there are unread notification items.
      // 1 item is enough since count is not displayed for now.
      var items = await Provider.of<AuthModel>(context)
          .ghClient
          .getJSON('/notifications?per_page=1');

      if (items is List && items.isNotEmpty) {
        Provider.of<NotificationModel>(context).setCount(1);
      }
    });
  }

  Future<ListPayload<GithubEvent, int>> fetchEvents([int page = 1]) async {
    final auth = Provider.of<AuthModel>(context);
    final login = auth.activeAccount.login;

    final events = await auth.ghClient.getJSON(
      '/users/$login/received_events?page=$page&per_page=$pageSize',
      convert: (vs) => [for (var v in vs) GithubEvent.fromJson(v)],
    );
    return ListPayload(
      cursor: page + 1,
      hasMore: events.length == pageSize,
      items: events,
    );
  }

  @override
  Widget build(context) {
    return ListStatefulScaffold<GithubEvent, int>(
      title: AppBarTitle('News'),
      itemBuilder: (payload) => EventItem(payload),
      onRefresh: fetchEvents,
      onLoadMore: (page) => fetchEvents(page),
    );
  }
}
