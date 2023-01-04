import 'dart:convert';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:dio/dio.dart';

import '/data/models/models.dart';
import '/core/constants.dart';

class FCMApiService {
  static final FCMApiService instance = FCMApiService._private();

  late Dio _dio;
  FCMApiService._private() {
    BaseOptions options = BaseOptions(
      baseUrl: 'https://fcm.googleapis.com',
      receiveDataWhenStatusError: true,
    );
    _dio = Dio(options);
    _dio.options.headers["Accept"] = "application/json";
    _dio.options.connectTimeout = 150000;
    _dio.options.sendTimeout = 100000;
    _dio.options.receiveTimeout = 120000;
  }

  Future<dynamic> sendChatPush(ChatMessage chat, String toToken,
      String fromUserId, String senderName, NotificationType type) async {
    _dio.options.headers['Authorization'] =
        'key=  ${'AAAAG8bzeow:APA91bEQai_ldUEZoR-i2WWNqPhjycgkH93YSE90pjKBF2LjjT6HrgtRfbTxvMh0wPsTWMquzBRHp29BX8iPykTbeMYThG4r7SVzQwGsRuVd0rOhyJsrB593XsKopDdVEjIdqyEuESxT'}';

    final data = {
      'registration_ids': [toToken],
      'type': type.name,
      'notification': {},
      'data': {
        // 'msg_id': chat.msgId,
        'content_type': chat.body.type.name,
        'body': jsonEncode(chat.toJson()),
        'from_id': fromUserId,
        'from_name': senderName,
      },
      // 'ttl': '30s',
      'android': {'priority': 'normal'},
      'priority': 10
    };
    var response =
        await _dio.post('https://fcm.googleapis.com/fcm/send', data: data);
    if (response.statusCode == 200) {
      print('fcm response.data:${response.data}');
      // EasyLoading.showToast('FCMResponse=${response.data['success']}',toastPosition: EasyLoadingToastPosition.bottom);
      // return Autogenerated.fromJson(response.data);
      return null;
    } else {
      // EasyLoading.showToast('FCMResponse=${response.statusMessage}',toastPosition: EasyLoadingToastPosition.bottom);
      return null;
    }
  }

  Future sendCallPush(
      String toToken,
      String callerFCMToken,
      // String action,
      CallBody callBody,
      String fromId,
      String fromName,
      String image,
      bool hasVideo) async {
    //p2p_call
    _dio.options.headers['Authorization'] =
        'key=  ${' AAAAgYFiXhQ:APA91bFY7G3nD7GtydIzctAaSO585gguQbbWEq5zIURsjFYRB7BBwl4ZDUU689TWAokrNfUHSAQ47zD_Wi9U26Z4jjoDsfDPF7zKjPQoD3iXJeCG5GQSDjioBNfavCHIHhiyUVZf2jlR'}';

    final data = {
      'registration_ids': [toToken],
      'type': 'p2p_call',
      'notification': {},
      'data': {
        'type': 'p2p_call',
        'action': 'START_CALL',
        'image': image,
        'has_video': hasVideo ? 'true' : 'false',
        'caller_fcm': callerFCMToken,
        'content': jsonEncode(callBody.toJson()),
        'from_id': fromId,
        'from_name': fromName,
      },
      // 'ttl': '30s',
      'android': {'priority': 'normal'},
      'priority': 10
    };
    var response =
        await _dio.post('https://fcm.googleapis.com/fcm/send', data: data);
    if (response.statusCode == 200) {
      print('fcm response.data:${response.data}');
      // EasyLoading.showToast('FCMResponse=${response.data['success']}',toastPosition: EasyLoadingToastPosition.bottom);
      // return Autogenerated.fromJson(response.data);
      return null;
    } else {
      print(
          'error code: ${response.statusCode} response.data:${response.data}');
      // EasyLoading.showToast('FCMResponse=${response.statusMessage}',toastPosition: EasyLoadingToastPosition.bottom);
      return null;
    }
  }

  Future sendCallEndPush(
    String toToken,
    String action,
    CallBody callBody,
    String fromId,
    String fromName,
    bool hasVideo,
  ) async {
    //p2p_call
    _dio.options.headers['Authorization'] =
        'key=  ${' AAAAgYFiXhQ:APA91bFY7G3nD7GtydIzctAaSO585gguQbbWEq5zIURsjFYRB7BBwl4ZDUU689TWAokrNfUHSAQ47zD_Wi9U26Z4jjoDsfDPF7zKjPQoD3iXJeCG5GQSDjioBNfavCHIHhiyUVZf2jlR'}';

    final data = {
      'registration_ids': [toToken],
      'type': 'p2p_call',
      'notification': {},
      'data': {
        'type': 'p2p_call',
        'action': action,
        'content': jsonEncode(callBody.toJson()),
        'from_id': fromId,
        'from_name': fromName,
        'image': '',
        'has_video': hasVideo ? 'true' : 'false',
        'caller_fcm': '',
      },
      // 'ttl': '30s',
      'android': {'priority': 'normal'},
      'priority': 10
    };
    var response =
        await _dio.post('https://fcm.googleapis.com/fcm/send', data: data);
    if (response.statusCode == 200) {
      print('fcm response.data:${response.data}');
      // EasyLoading.showToast('FCMResponse=${response.data['success']}',toastPosition: EasyLoadingToastPosition.bottom);
      // return Autogenerated.fromJson(response.data);
      return null;
    } else {
      print(
          'error code: ${response.statusCode} response.data:${response.data}');
      // EasyLoading.showToast('FCMResponse=${response.statusMessage}',toastPosition: EasyLoadingToastPosition.bottom);
      return null;
    }
  }
}
