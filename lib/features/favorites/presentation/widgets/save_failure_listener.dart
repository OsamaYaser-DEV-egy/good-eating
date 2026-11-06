import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/features/favorites/presentation/cubit/favorites_cubit.dart';

/// Shows a snackbar whenever a favorite could not be saved, on whichever
/// screen the user is looking at.
///
/// Place it inside `MaterialApp.builder`, where there is a messenger above it
/// and every screen below it.
class SaveFailureListener extends StatefulWidget {
  const SaveFailureListener({required this.child, super.key});

  final Widget child;

  @override
  State<SaveFailureListener> createState() => _SaveFailureListenerState();
}

class _SaveFailureListenerState extends State<SaveFailureListener> {
  StreamSubscription<Failure>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = context.read<FavoritesCubit>().saveFailures.listen(_show);
  }

  void _show(Failure failure) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(failure.message)));
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
