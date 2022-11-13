import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:manyaran_system/controller/add_camera_controller.dart';
import 'package:manyaran_system/data/models/ip_camera.dart';
import 'package:manyaran_system/utils/helper.dart';

class AddCameraPage extends GetView<AddCameraController> {

  @override
  Widget build(BuildContext context) {
    return GetX<AddCameraController>(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Manage Camera"),
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(150),
              child: Container(
                height: 150,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                      controller: _.nameC,
                      decoration: InputDecoration(
                          hintText: "Camera Name",
                          filled: true,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          fillColor: Colors.white.withOpacity(0.9),
                          isCollapsed: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius
                              .circular(100),)
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              TextField(
                                controller: _.ipLocalC,
                                decoration: InputDecoration(
                                    hintText: "IP Local",
                                    filled: true,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    fillColor: Colors.white.withOpacity(0.9),
                                    isCollapsed: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),)
                                ),
                              ),
                              SizedBox(height: 5),
                              TextField(
                                controller: _.ipInternetC,
                                decoration: InputDecoration(
                                    hintText: "IP Public",
                                    filled: true,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    fillColor: Colors.white.withOpacity(0.9),
                                    isCollapsed: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),)
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 15),
                        _.editedKey != null ?
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.check, color: Colors.black,
                            size: 18,),
                          onPressed: ()=>_.addCamera(editedKey: _.editedKey),
                        ) :
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.plus, color: Colors.black,
                            size: 18,),
                          onPressed: ()=> _.addCamera(),
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                  if (snapshot.hasData) {
                    print("data: ${snapshot.data}");
                    List<IPCamera> ipCameras = snapshot.data as List<IPCamera>;
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
                              (index) =>
                              DataRow2(
                                onTap: () {
                                  _.openDialog(
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
                                      style: TextStyle(
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      "${ipCameras[index].ipLocal}",
                                      maxLines: 3,
                                      style: TextStyle(
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      "${ipCameras[index].ipInternet}",
                                      maxLines: 3,
                                      style: TextStyle(
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      ipCameras[index].isOnline ?? false
                                          ? "Online"
                                          : "Offline",
                                      maxLines: 3,
                                      style: TextStyle(
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    );
                  } else {
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
      },
    );
  }

}

