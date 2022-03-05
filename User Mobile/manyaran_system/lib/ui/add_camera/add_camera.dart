import 'package:bot_toast/bot_toast.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manyaran_system/models/ip_camera.dart';
import 'package:manyaran_system/repository/firebase_database.dart';
import 'package:manyaran_system/utils/helper.dart';

class AddCameraPage extends StatefulWidget {
  const AddCameraPage({Key? key}) : super(key: key);

  @override
  _AddCameraPageState createState() => _AddCameraPageState();
}

class _AddCameraPageState extends State<AddCameraPage> {

  TextEditingController nameC = TextEditingController();
  TextEditingController ipLocalC = TextEditingController();
  TextEditingController ipInternetC = TextEditingController();
  int? editedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Camera"),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                TextField(
                  controller: nameC,
                  decoration: InputDecoration(
                      hintText: "Camera Name",
                      filled: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      fillColor: Colors.white.withOpacity(0.9),
                      isCollapsed: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(100),)
                  ),
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ipLocalC,
                        decoration: InputDecoration(
                          hintText: "IP Local",
                          filled: true,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          fillColor: Colors.white.withOpacity(0.9),
                          isCollapsed: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(100),)
                        ),
                      ),
                    ),
                    SizedBox(width: 15,),
                    Expanded(
                      child: TextField(
                        controller: ipInternetC,
                        decoration: InputDecoration(
                            hintText: "IP Public",
                            filled: true,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            fillColor: Colors.white.withOpacity(0.9),
                            isCollapsed: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(100),)
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    editedIndex != null ?
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.check, color: Colors.black, size: 18,),
                      onPressed: (){
                        firebaseRepository.setIPCamera(ipInternetC.text, ipLocalC.text, nameC.text, index: editedIndex).then((value){
                          _clearInputs();
                          toastS("Update success!");
                        });
                      },
                    ) :
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.plus, color: Colors.black, size: 18,),
                      onPressed: (){
                        firebaseRepository.setIPCamera(ipInternetC.text, ipLocalC.text, nameC.text).then((value){
                          _clearInputs();
                          toastS("Camera added successfully!");
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: FutureBuilder(
            future: firebaseRepository.getIPCamera(),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return Column(
                  children: [
                    LinearProgressIndicator(minHeight: 8,),
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Please wait, we are trying to scan the local camera.",
                        style: TextStyle(
                          letterSpacing: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }
              if(snapshot.hasData){
                print("data: ${snapshot.data}");
                List<IPCamera> ipCameras = snapshot.data as  List<IPCamera>;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DataTable2(
                    columnSpacing: 10,
                    horizontalMargin: 5,
                    dataRowHeight: 90,
                    columns: [
                      DataColumn2(
                        label: Text('Name'),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text('IP Local'),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text('IP Public'),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text('Status'),
                        size: ColumnSize.S,
                      ),
                    ],
                    rows: List<DataRow>.generate(
                      ipCameras.length,
                          (index) => DataRow2(
                        onTap: (){
                          _showDialog(
                            index,
                            "${ipCameras[index].name}",
                            "${ipCameras[index].ipLocal}",
                            "${ipCameras[index].ipInternet}",
                          );
                        },
                        cells: [
                          DataCell(
                            Text(
                              "${ipCameras[index].name}",
                              maxLines: 3,
                              style: TextStyle(overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          DataCell(
                            Text(
                              "${ipCameras[index].ipLocal}",
                              maxLines: 3,
                              style: TextStyle(overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          DataCell(
                            Text(
                              "${ipCameras[index].ipInternet}",
                              maxLines: 3,
                              style: TextStyle(overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          DataCell(
                            Text(
                              ipCameras[index].isOnline ?? false
                                  ? "Online"
                                  : "Offline",
                              maxLines: 3,
                              style: TextStyle(overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }else{
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text("You haven't added a camera yet."),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  _clearInputs(){
    editedIndex = null;
    nameC.text = "";
    ipLocalC.text = "";
    ipInternetC.text = "";
    setState(() {});
  }

  _showDialog(int index, String title, String ipLocal, String ipPublic){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("IP Local", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),),
              Text(ipLocal, style: TextStyle(fontSize: 12.sp),),
              SizedBox(height: 10.h,),
              Text("IP Public", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),),
              Text(ipPublic, style: TextStyle(fontSize: 12.sp),),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red),),
              onPressed: () {
                firebaseRepository.deleteIPCamera(index).then((value){
                  toastS("Camera deleted!");
                  setState(() {});
                });
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Edit"),
              onPressed: () {
                nameC.text = title;
                ipLocalC.text = ipLocal;
                ipInternetC.text = ipPublic;
                editedIndex = index;
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

}
