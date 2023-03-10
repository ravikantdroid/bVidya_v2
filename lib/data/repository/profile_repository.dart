import 'dart:io';

import '../models/models.dart';
import '../services/profile_api_service.dart';

class ProfileRepository {
  static const successfull = 'successfull';
  final ProfileApiService _api;
  final String _authToken;

  ProfileRepository(this._api, this._authToken);

  Future<String?> reportProblem(String module, String message) async {
    final result = await _api.reportProblem(_authToken, module, message);
    if (result.status == successfull) {
      return null;
    } else {
      return result.message ?? 'Unknown error';
    }
  }

  Future<Profile?> getUserProfile() async {
    final result = await _api.getUserProfile(_authToken);
    if (result.status == successfull) {
      return result.body;
    } else {
      return null;
    }
  }

  Future<SubscribedCourseBody?> getSubscribeCourses() async {
    final result = await _api.getSubscribedCourses(_authToken);
    // print("result inside repo :${result.body?.toJson()}");
    if (result.status == "success") {
      return result.body;
    } else {
      return null;
    }
  }

  Future<List<FollowedInstructor>?> followedInstructor() async {
    final result = await _api.followedInstructor(_authToken);
    if (result.status == 'successfully' && result.body != null) {
      return result.body!;
    } else {
      print('Error ${result.message ?? 'Error'} ');
      return null;
    }
  }

  Future<UpdatedProfile?> updateProfile(
      String name,
      String email,
      String phone,
      String address,
      String age,
      String bio,
      String language,
      String occupation,
      String city,
      String state,
      String country) async {
    final result = await _api.updateUserProfile(
        token: _authToken,
        name: name,
        email: email,
        phone: phone,
        address: address,
        age: age,
        bio: bio,
        language: language,
        occupation: occupation,
        city: city,
        state: state,
        country: country);
    if (result.status != null && result.status == successfull) {
      return result.body;
    }
    return null;
  }

//updateimage
  Future<String?> updateProfileImage(File file) async {
    final result = await _api.updateProfilePic(_authToken, file);
    if (result.status != null && result.status == successfull) {
      return result.image;
    }
    return null;
  }

//get list of requested classes of student
  Future<RequestedClassesBody> requestedClassList() async {
    final result = await _api.getRequestedClassList(_authToken);
    if (result.status == 'success' && result.body != null) {
      return result.body!;
    } else {
      return RequestedClassesBody();
    }
  }

  // Future<ScheduledClassBody> getschduledClassesAsStudent() async {
  //   final result = await _api.getSchduledClassesStudent(_authToken);
  //   if (result.status == 'success' && result.body != null) {
  //     return result.body!;
  //   } else {
  //     return ScheduledClassBody();
  //   }
  // }

  // //get List of schduled class As Instructor
  // Future<ScheduledClassInstructorBody> getschduledClassesAsInstructor() async {
  //   final result = await _api.getSchduledClassesInstructor(_authToken);
  //   if (result.status == 'success' && result.body != null) {
  //     return result.body!;
  //   } else {
  //     return ScheduledClassInstructorBody();
  //   }
  // }

  Future<StudentScheduledClassBody> getschduledClassesAsStudent() async {
    final result = await _api.getSchduledClassesStudent(_authToken);
    if (result.status == 'success' && result.body != null) {
      return result.body!;
    } else {
      return StudentScheduledClassBody();
    }
  }

  Future<SubscriptionPlansBody> getSubscriptionPlans() async {
    final result = await _api.getSubscriptionPlans(_authToken);
    if (result.status == 'success' && result.body != null) {
      return result.body!;
    } else {
      return SubscriptionPlansBody();
    }
  }

  Future<PaymentDetailBody> getpaymentId(String planId) async {
    final result = await _api.getpaymentId(_authToken, planId);
    if (result.status == 'success' && result.body != null) {
      return result.body!;
    } else {
      return PaymentDetailBody();
    }
  }

  Future<PaymentSuccessBody> getpaymentSuccessResponse(
      String orderId, String paymentId, String signature) async {
    final result = await _api.getpaymentSuccessDetails(
        _authToken, orderId, paymentId, signature);
    if (result.status == 'success' && result.body != null) {
      return result.body!;
    } else {
      return PaymentSuccessBody();
    }
  }

  Future<CreditDetailBody> getCreditsHistory() async {
    final result = await _api.getCreditsDetails(_authToken);
    if (result.status == 'success' && result.body != null) {
      return result.body!;
    } else {
      return CreditDetailBody();
    }
  }

  //get List of schduled class As Instructor
  Future<InstructorScheduledClassBody> getschduledClassesAsInstructor() async {
    final result = await _api.getSchduledClassesInstructor(_authToken);
    if (result.status == 'success' && result.body != null) {
      return result.body!;
    } else {
      return InstructorScheduledClassBody();
    }
  }
}
