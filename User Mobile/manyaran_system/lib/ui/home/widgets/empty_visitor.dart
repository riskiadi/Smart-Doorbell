import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyVisitorWidget extends StatelessWidget {
  const EmptyVisitorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Text(
        "You have no visitors this month.",
        style: TextStyle(
          color: Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }
}
