import 'package:flutter/widgets.dart';

import 'package:good_eating/core/constants/app_durations.dart';
import 'package:good_eating/core/error/failure.dart';
import 'package:good_eating/core/state/data_state.dart';
import 'package:good_eating/core/widgets/app_error_view.dart';

/// Renders a [DataState]: a skeleton while it loads, a compact error with a
/// retry button if it failed, and [builder] once it has data.
///
/// The three outcomes cross-fade, so a section never snaps between them.
class DataStateView<T> extends StatelessWidget {
  const DataStateView({
    required this.state,
    required this.loadingBuilder,
    required this.builder,
    required this.onRetry,
    this.errorBuilder,
    super.key,
  });

  final DataState<T> state;
  final WidgetBuilder loadingBuilder;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback onRetry;

  /// Replaces the default [AppInlineError].
  final Widget Function(BuildContext context, Failure failure)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.fast,
      child: switch (state) {
        DataInitial<T>() || DataLoading<T>() => KeyedSubtree(
          key: const ValueKey('loading'),
          child: loadingBuilder(context),
        ),
        DataFailure<T>(:final failure) => KeyedSubtree(
          key: const ValueKey('error'),
          child:
              errorBuilder?.call(context, failure) ??
              AppInlineError(failure: failure, onRetry: onRetry),
        ),
        DataSuccess<T>(:final data) => KeyedSubtree(
          key: const ValueKey('data'),
          child: builder(context, data),
        ),
      },
    );
  }
}
