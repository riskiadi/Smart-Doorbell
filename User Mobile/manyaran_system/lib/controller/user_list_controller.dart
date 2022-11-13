import 'package:get/get.dart';
import 'package:manyaran_system/data/models/user_registered_list.dart';
import 'package:manyaran_system/data/repository/firebase_database.dart';

class UserListController extends GetxController {

  final _firebaseDatabaseRepository = FirebaseDatabaseRepository().obs;
  final _userList = <UserRegisteredList>[].obs;
  final _isLoading = RxStatus.empty().obs;

  FirebaseDatabaseRepository get firebaseDatabaseRepository => _firebaseDatabaseRepository.value;

  set firebaseDatabaseRepository(value) {
    _firebaseDatabaseRepository.value = value;
  }

  List<UserRegisteredList> get userList => _userList;

  set userList(value) {
    _userList.value = value;
  }

  RxStatus get isLoading => _isLoading.value;

  set isLoading(value) {
    _isLoading.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    getAppUsers();
  }

  getAppUsers() async{

    isLoading = RxStatus.loading();
    userList.clear();

    final tempList = await firebaseDatabaseRepository.getUserRegistered();
    Map<String, dynamic> userListTemp = Map.from(tempList?.value);

    userListTemp.forEach((key, value) {
      final user = UserRegisteredList.fromJson(value);
      userList.add(UserRegisteredList(
        idToken: key,
        email: user.email,
        name: user.name,
        access: user.access,
        avatar: user.avatar,
        createdDate: user.createdDate,
        createdUnix: user.createdUnix,
      ));
    });

    userList.sort((a,b){
      if(a.access == true){
        return -1;
      }else{
       return 1;
      }
    });

    isLoading = RxStatus.success();

  }

  setUserAccess(String userToken, bool isAllowed) async{
    await firebaseDatabaseRepository.setAccess(userToken, isAllowed);
    getAppUsers();
  }

}