import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// Retrieves an `Entity` from a `Store`, and constructs a `FutureBuilder`.
/// Can take either an [id] and a [store], or an explicit [future].
class EntityFutureBuilder<T extends Entity> extends StatefulWidget {
  final String? id;
  final EntityStore<T>? store;
  final Future<Result<T>>? future;
  final Widget loadingWidget;
  final Widget Function(String) errorWidget;
  final Widget Function(T) resultWidget;

  const EntityFutureBuilder({
    Key? key,
    this.id,
    this.store,
    this.future,
    required this.loadingWidget,
    required this.errorWidget,
    required this.resultWidget,
  })  : assert((id != null && store != null) || future != null),
        super(key: key);

  @override
  State<EntityFutureBuilder<T>> createState() => _EntityFutureBuilderState<T>();
}

class _EntityFutureBuilderState<T extends Entity> extends State<EntityFutureBuilder<T>> {
  late final Future<Result<T>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.future ?? widget.store!.get(widget.id!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<T>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingWidget;
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return widget.errorWidget(snapshot.error.toString());
        }

        if (!snapshot.data!.ok) {
          // TODO: map error codes
          return widget.errorWidget(snapshot.data!.error!.toString());
        }

        return widget.resultWidget(snapshot.data!.object!);
      },
    );
  }
}
