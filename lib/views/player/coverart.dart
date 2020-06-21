import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rustic/api/api.dart';
import 'package:rustic/state/media_bloc.dart';

class PlayerCoverArt extends StatelessWidget {
  PlayerCoverArt({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Api api = context.repository();
    return BlocBuilder<CurrentMediaBloc, Playing>(
      condition: (prev, next) => prev.track?.coverart != next.track?.coverart,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(const Radius.circular(4)),
                child: Image(
                  key: Key(state.track.coverart),
                  image: api.fetchCoverart(state.track.coverart),
                  fit: BoxFit.contain,
                )),
          ),
        );
      },
    );
  }
}
