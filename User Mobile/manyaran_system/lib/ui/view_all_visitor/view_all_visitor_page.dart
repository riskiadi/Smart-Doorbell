import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:manyaran_system/data/repository/firebase_database.dart';
import 'package:manyaran_system/ui/view_all_visitor/widgets/date_picker_visitor.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'widgets/visitor_all_list.dart';

class ViewAllVisitorPage extends StatefulWidget {
  const ViewAllVisitorPage({Key? key}) : super(key: key);

  @override
  _ViewAllVisitorPageState createState() => _ViewAllVisitorPageState();
}

class _ViewAllVisitorPageState extends State<ViewAllVisitorPage> {

  FirebaseDatabaseRepository _firebaseDatabaseRepository = FirebaseDatabaseRepository();
  DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#ECEBF0"),
      appBar: AppBar(
        title: Text("Visitor This Month"),
        centerTitle: true,
        elevation: 15,
        shadowColor: Colors.black.withOpacity(0.15),
        backgroundColor: Colors.amber,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 20,),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat("MMMM yyyy").format(dateTime)),
                GestureDetector(
                  onTap: () => _navigateToDatePicker(),
                  child: Text("Change", style: TextStyle(fontWeight: FontWeight.w500,),),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: FutureBuilder(
          future: _firebaseDatabaseRepository.getVisitors(date: dateTime),
          builder: (context, AsyncSnapshot<List<int>> snapshot) {
            if(snapshot.hasData){
              return ListView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                controller: ScrollController(keepScrollOffset: true),
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                    snapshot.data![index] * 1000,
                    isUtc: true,
                  );
                  var encodedPath = Uri.encodeComponent("cctv/snapshot/${DateFormat('yyyy/MM/dd').format(dateTime)}/${snapshot.data![index]}.jpg");
                  var imagePath = "https://firebasestorage.googleapis.com/v0/b/manyaran-sistem.appspot.com/o/$encodedPath?alt=media";
                  return VisitorAllListWidget(imageUrl: imagePath, dateTime: dateTime,);
                },
              );
            }else{
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }


  _navigateToDatePicker() async{
    DateRangePickerSelectionChangedArgs result = await Navigator.push(context, MaterialPageRoute(builder: (context) => DatePickerVisitor(),),);
    dateTime = result.value;
    setState(() {});
  }


}