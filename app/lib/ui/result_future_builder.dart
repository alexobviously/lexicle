import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// Retrieves an `Entity` from a `Store`, and constructs a `FutureBuilder`.
/// Can take either an [id] and a [store], or an explicit [future].
class ResultFutureBuilder<T> extends StatefulWidget {
  final Future<Result<T>>? future;
  final Widget loadingWidget;
  final Widget Function(String) errorWidget;
  final Widget Function(T) resultWidget;

  const ResultFutureBuilder({
    super.key,
    this.future,
    required this.loadingWidget,
    required this.errorWidget,
    required this.resultWidget,
  });

  @override
  State<ResultFutureBuilder<T>> createState() => _ResultFutureBuilderState<T>();
}

class _ResultFutureBuilderState<T> extends State<ResultFutureBuilder<T>> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<T>>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingWidget;
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return widget.errorWidget(snapshot.error.toString());
        }

        if (!snapshot.data!.ok) {
          return widget.errorWidget(snapshot.data!.error!.toString());
        }

        return widget.resultWidget(snapshot.data!.object!);
      },
    );
  }
}
