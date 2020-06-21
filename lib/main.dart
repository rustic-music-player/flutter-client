import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rustic/api/api.dart';
import 'package:rustic/api/http.dart';
import 'package:rustic/bloc_logger.dart';
import 'package:rustic/notifications.dart';
import 'package:rustic/state/media_bloc.dart';
import 'package:rustic/state/provider_bloc.dart';
import 'package:rustic/state/queue_bloc.dart';
import 'package:rustic/views/album/album.dart';
import 'package:rustic/views/library/library.dart';
import 'package:rustic/views/player/player.dart';
import 'package:rustic/views/player/queue.dart';
import 'package:rustic/views/playlist/playlist.dart';
import 'package:rustic/views/playlists/playlists.dart';
import 'package:rustic/views/search/albums.dart';
import 'package:rustic/views/search/playlists.dart';
import 'package:rustic/views/search/search.dart';
import 'package:rustic/views/search/search_bloc.dart';

// TODO: get from config
const apiHost = '192.168.1.13:8080';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = BlocLoggerDelegate();
  var notificationsService = NotificationsService(host: apiHost);
  await notificationsService.setup();
  runApp(MyApp(
    notificationsService: notificationsService,
  ));
}

class MyApp extends StatelessWidget {
  final NotificationsService notificationsService;
  final CurrentMediaBloc mediaBloc;

  MyApp({this.mediaBloc, this.notificationsService});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Api>(
        create: (context) => HttpApi(baseUrl: '$apiHost'),
        child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (BuildContext context) {
                var bloc = QueueBloc(api: context.repository());
                bloc.add(FetchQueue());
                return bloc;
              }),
              BlocProvider(create: (BuildContext context) {
                var bloc = CurrentMediaBloc(api: context.repository());
                bloc.add(FetchPlayer());

                return bloc;
              }),
              BlocProvider(create: (BuildContext context) {
                var bloc = ProviderBloc(api: context.repository());
                bloc.add(FetchProviders());
                return bloc;
              }),
              BlocProvider(
                create: (BuildContext context) => SearchBloc(
                    api: context.repository(), providerBloc: context.bloc()),
              ),
            ],
            child: BlocListener<CurrentMediaBloc, Playing>(
              listener: (context, state) {
                this.notificationsService.showNotification(state);
              },
              child: MaterialApp(
                title: 'Rustic',
                theme: ThemeData(
                    brightness: Brightness.dark,
                    primarySwatch: Colors.blueGrey,
                    accentColor: Colors.deepOrangeAccent,
                    visualDensity: VisualDensity.adaptivePlatformDensity),
                initialRoute: '/',
                routes: {
                  Navigator.defaultRouteName: (context) => LibraryView(),
                  AlbumView.routeName: (context) => AlbumView(),
                  PlaylistsView.routeName: (context) => PlaylistsView(),
                  PlaylistView.routeName: (context) => PlaylistView(),
                  SearchView.routeName: (context) => SearchView(),
                  SearchAlbumView.routeName: (context) => SearchAlbumView(),
                  SearchPlaylistView.routeName: (context) =>
                      SearchPlaylistView(),
                  PlayerView.routeName: (context) => PlayerView(),
                  QueueView.routeName: (context) => QueueView(),
                },
              ),
            )));
  }
}
