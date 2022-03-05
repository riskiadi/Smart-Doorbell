import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonInfoWidget extends StatelessWidget {
  const SkeletonInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      height: 130,
      padding: const EdgeInsets.only(
        bottom: 17,
        left: 18,
        right: 18,
        top: 17,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(1, 5),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    height: 15,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 20,),
                Flexible(
                  flex: 1,
                  child: Container(
                    height: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              height: 50,
              color: Colors.white,
            ),
          ],
        )
      ),
    );
  }
}
