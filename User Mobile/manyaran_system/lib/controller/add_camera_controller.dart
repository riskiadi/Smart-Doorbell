import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:manyaran_system/utils/helper.dart';

class AddCameraController extends GetxController with StateMixin{

  final _nameC = TextEditingController().obs;
  final _ipLocalC = TextEditingController().obs;
  final _ipInternetC = TextEditingController().obs;
  final _editedIndex = RxnInt();

  TextEditingController get nameC => this._nameC.value;

  set nameC(value) {
    this._nameC.value = value;
  }

  TextEditingController get ipLocalC => this._ipLocalC.value;

  set ipLocalC(value) {
    this._ipLocalC.value = value;
  }

  TextEditingController get ipInternetC => this._ipInternetC.value;

  set ipInternetC(value) {
    this._ipInternetC.value = value;
  }

  int? get editedIndex => this._editedIndex.value;

  set editedIndex(value) {
    this._editedIndex.value = value;
  }

  clearInputs(){
    editedIndex = null;
    nameC.text = "";
    ipLocalC.text = "";
    ipInternetC.text = "";
    change(null, status: RxStatus.success());
  }

  openDialog(int index, String title, String ipLocal, String ipPublic){

    if(Get.context!=null){
      showDialog(context: Get.context!, builder: (context){
        FocusScope.of(context).unfocus();
        TextEditingController().clear();
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
                });

                Get.back();

              },
            ),
            TextButton(
              child: Text("Edit"),
              onPressed: () {
                nameC.text = title;
                ipLocalC.text = ipLocal;
                ipInternetC.text = ipPublic;
                editedIndex = index;
                Get.back();
              },
            ),
          ],
        );
      });
    }

  }

}