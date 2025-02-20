import 'package:flutter/material.dart';

class ScrollPercentListenableBuilder extends StatelessWidget {
  const ScrollPercentListenableBuilder({
    super.key,
    required ValueNotifier<double> scrollNotifier,
    required this.builder,
    this.minExtent = 0,
    this.maxExtent = 1,
    this.child,
  }) : _scrollNotifier = scrollNotifier,
       assert(minExtent >= 0 && maxExtent >= minExtent && minExtent <= 1);

  final ValueNotifier<double> _scrollNotifier;
  final double minExtent;
  final double maxExtent;
  final Widget Function(BuildContext context, double percent, Widget? child)
  builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _scrollNotifier,
      builder: (context, scrollPercent, child) {
        final percent = ((scrollPercent - minExtent) / (maxExtent - minExtent))
            .clamp(0.0, 1.0);
        // log('scrollPercent: $percent');
        return builder.call(context, percent, child);
      },
      child: child,
    );
  }
}
