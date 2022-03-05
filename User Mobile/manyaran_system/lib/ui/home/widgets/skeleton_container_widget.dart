import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonContainerWidget extends StatelessWidget {

  final double height;

  const SkeletonContainerWidget({Key? key, this.height = 170}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.2,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
