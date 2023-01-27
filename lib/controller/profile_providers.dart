import 'package:collection/collection.dart';

import '/core/state.dart';
import '/data/models/models.dart';
import '/data/repository/profile_repository.dart';
import '/data/services/profile_api_service.dart';

final apiProfileProvider = Provider<ProfileApiService>(
  (_) => ProfileApiService.instance,
);

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  String token = ref.read(loginRepositoryProvider).user?.authToken ?? '';
  return ProfileRepository(ref.read(apiProfileProvider), token);
});

final profileUserProvider = FutureProvider.autoDispose<Profile?>((ref) {
  return ref.read(profileRepositoryProvider).getUserProfile();
});

final subscribedCoursesProvider =
    FutureProvider.autoDispose<SubscribedCourseBody?>((ref) {
  return ref.read(profileRepositoryProvider).getSubscribeCourses();
});

final follwedInstructorsProvider =
    FutureProvider.autoDispose<List<FollowedInstructor>?>((ref) {
  return ref.read(profileRepositoryProvider).followedInstructor();
});

// final isFollowedInstructor =
//     FutureProvider.autoDispose.family<bool, String>((ref, id) async {
//   final list = await ref.read(profileRepositoryProvider).followedInstructor();
//   return list?.firstWhereOrNull((e) => e.instructorId?.toString() == id) !=
//       null;
// });

final isFollowedInstructor =
    FutureProvider.autoDispose.family<bool, String>((ref, id) async {
  // print("inside the loop");
  final list = await ref.read(profileRepositoryProvider).followedInstructor();
  // print("inside the loop");
  // print(list?.firstWhereOrNull((e) => e.instructorId?.toString() == id));
  return list?.firstWhereOrNull((e) => e.instructorId?.toString() == id) !=
      null;
});

final requestedClassesProvider =
    FutureProvider.autoDispose<RequestedClassesBody?>((ref) {
  return ref.read(profileRepositoryProvider).requestedClassList();
});
