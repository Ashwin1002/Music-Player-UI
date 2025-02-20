import 'package:flutter/material.dart';

class CustomDelegate extends SliverPersistentHeaderDelegate {
  const CustomDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.builder,
  });

  final double maxHeight;
  final double minHeight;
  final Widget Function(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  )
  builder;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return builder.call(context, shrinkOffset, overlapsContent);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => maxHeight;

  @override
  bool shouldRebuild(covariant CustomDelegate oldDelegate) =>
      maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight;
}
