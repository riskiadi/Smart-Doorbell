import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DatePickerVisitor extends StatelessWidget {
  const DatePickerVisitor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    DateRangePickerSelectionChangedArgs? date;

    return Scaffold(
      appBar: AppBar(
        title: Text("Choose History"),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.pop(context, date);
            },
            icon: FaIcon(FontAwesomeIcons.check, size: 18,),
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: SfDateRangePicker(
          onSelectionChanged: (datePicker) {
            date = datePicker;
          },
          allowViewNavigation: false,
          view: DateRangePickerView.year,
          showTodayButton: false,
          showNavigationArrow: true,
          showActionButtons: false,
          headerHeight: 70,
        ),
      ),
    );
  }
}
