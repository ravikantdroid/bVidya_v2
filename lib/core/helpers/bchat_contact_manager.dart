// ignore_for_file: avoid_print

import 'package:agora_chat_sdk/agora_chat_sdk.dart';

class BChatContactManager {
  BChatContactManager._();

  static Future<List<String>> getContactList({bool fromServer = false}) async {
    try {
      // final sd = ChatContactManager();
      var list =
          await ChatClient.getInstance.contactManager.getAllContactsFromDB();
      if (list.isEmpty || fromServer) {
        try {
          list = await ChatClient.getInstance.contactManager
              .getAllContactsFromServer();
        } catch (e) {
          //Avoid limitation error
        }
      }
      return list;
    } on ChatError catch (e) {
      print('chatError: ${e.code}- ${e.description}');
    } catch (e) {
      print('error: $e');
    }
    return [];
  }

  static Future<String> getContacts({bool fromServer = false}) async {
    try {
      final list = await getContactList(fromServer: fromServer);
      if (list.isEmpty) {
        return '';
      }
      String ids = list.join(',');
      print('id: $ids');
      return ids;
    } catch (e) {
      print('error: $e');
    }
    return '';
  }

  static Future<List<String>> getBlockList({bool fromServer = false}) async {
    try {
      var list =
          await ChatClient.getInstance.contactManager.getBlockListFromDB();
      if (list.isEmpty || fromServer) {
        list = await ChatClient.getInstance.contactManager
            .getBlockListFromServer();
      }
      return list;
    } on ChatError catch (e) {
      print('chatError: ${e.code}- ${e.description}');
    } catch (e) {
      print('error: $e');
    }
    return [];
  }

  static Future<String> getBlockUsers({bool fromServer = false}) async {
    try {
      final list = await getBlockList(fromServer: fromServer);
      if (list.isEmpty) {
        return '';
      }
      String ids = list.join(',');
      print('id: $ids');
      return ids;
    } catch (e) {
      print('error: $e');
    }
    return '';
  }

  static Future<String?> sendRequestToAddContact(String contactId) async {
    try {
      final list = await getContactList(fromServer: true);
      if (list.contains(contactId)) {
        return 'Already exists';
      } else {
        await ChatClient.getInstance.contactManager
            .addContact(contactId, reason: 'Hi, Please accept my invitation');
        return null;
      }
    } on ChatError catch (e) {
      print('chatError: ${e.code}- ${e.description}');
      return 'chatError: ${e.code}- ${e.description}';
    } catch (e) {
      print('error: $e');
      return 'Error : $e';
    }
  }

  static Future chageChatMuteStateFor(String userId, bool mute) async {
    try {
      final chatparam = ChatSilentModeParam.remindType(
          mute ? ChatPushRemindType.ALL : ChatPushRemindType.NONE);
      await ChatClient.getInstance.pushManager.setConversationSilentMode(
        conversationId: userId,
        param: chatparam,
        type: ChatConversationType.Chat,
      );
      // return result.remindType ?? ChatPushRemindType.ALL;
    } on ChatError catch (e) {
      print('Error: ${e.code}- ${e.description} ');
    } catch (e) {
      print('Error2: ${e} ');
    }
  }

  static Future<ChatPushRemindType> fetchChatMuteStateFor(String userId) async {
    try {
      final result = await ChatClient.getInstance.pushManager
          .fetchConversationSilentMode(
              conversationId: userId, type: ChatConversationType.Chat);
      ChatPushRemindType? remindType = result.remindType;
      print('mute style  ${remindType?.name ?? 'UNKNOWN'}');
      return remindType ?? ChatPushRemindType.ALL;
    } on ChatError catch (e) {
      print('Error: ${e.code}- ${e.description} ');
    } catch (e) {
      print('Error2: ${e} ');
    }
    return ChatPushRemindType.ALL;
  }

  static Future<String?> blockUser(String userId) async {
    try {
      if (await isUserBlocked(userId)) {
        return 'Already Blocked';
      } else {
        await ChatClient.getInstance.contactManager.addUserToBlockList(userId);
        return null;
      }
    } on ChatError catch (e) {
      print('chatError: ${e.code}- ${e.description}');
      return 'chatError: ${e.code}- ${e.description}';
    } catch (e) {
      print('error: $e');
      return 'Error : $e';
    }
  }

  static Future<String?> unBlockUser(String userId) async {
    try {
      if (await isUserBlocked(userId)) {
        await ChatClient.getInstance.contactManager
            .removeUserFromBlockList(userId);
      } else {
        return 'Not Blocked';
      }
    } on ChatError catch (e) {
      print('chatError: ${e.code}- ${e.description}');
      return 'chatError: ${e.code}- ${e.description}';
    } catch (e) {
      print('error: $e');
      return 'Error : $e';
    }
  }

  static Future<bool> isUserBlocked(String userId) async {
    final list = await getBlockList(fromServer: false);
    if (list.contains(userId)) {
      return true;
    } else {
      if ((await getBlockList(fromServer: true)).contains(userId)) {
        return true;
      }
      return false;
    }
  }
}
