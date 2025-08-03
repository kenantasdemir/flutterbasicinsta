import 'package:get_it/get_it.dart';
import 'package:instagramcloneapp/repository/user_repository.dart';
import 'package:instagramcloneapp/services/firebase_auth_service.dart';
import 'package:instagramcloneapp/services/firebase_firestore_service.dart';
import 'package:instagramcloneapp/services/firebase_storage_service.dart';

GetIt locator = GetIt.I;  // GetIt.I -  GetIt.instance - nin kisaltmasidir

void setupLocator() {
  locator.registerLazySingleton(() => FirebaseFirestoreService());

  locator.registerLazySingleton(() => FirebaseAuthService());
  locator.registerLazySingleton(() => FirebaseStorageService());
  locator.registerLazySingleton(() => UserRepository());

}