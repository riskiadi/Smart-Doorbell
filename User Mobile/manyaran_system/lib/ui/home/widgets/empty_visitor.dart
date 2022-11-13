import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyContentWidget extends StatelessWidget {

  final title;

  const EmptyContentWidget({Key? key, this.title="-"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black.withOpacity(0.5),
        ),
      ),
    );
  }
}
