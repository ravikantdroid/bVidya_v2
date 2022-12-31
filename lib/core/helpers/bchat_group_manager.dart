import 'dart:convert';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';

import '../../data/models/conversation_model.dart';

class BchatGroupManager {
  static Future<ChatGroup?> createNewGroup(
      String name, String? desc, List<String> ids, String image) async {
    try {
      ChatGroup group = await ChatClient.getInstance.groupManager.createGroup(
          groupName: name,
          desc: desc,
          inviteMembers: ids,
          options: ChatGroupOptions());

      Map<String, dynamic> ext = {
        'image': image,
      };

      await ChatClient.getInstance.groupManager
          .updateGroupExtension(group.groupId, jsonEncode(ext));
      return group;
    } catch (e) {
      print('Error creating group $e');
    }
    return null;
  }

  static Future<List<GroupConversationModel>> loadGroupConversationsList(
      {bool firstTime = false}) async {
    List<GroupConversationModel> conversations = [];
    final groups = await ChatClient.getInstance.groupManager.getJoinedGroups();
    for (ChatGroup group in groups) {
      GroupConversationModel model;


      try {
        final conv = await ChatClient.getInstance.chatManager.getConversation(
            group.groupId,
            type: ChatConversationType.GroupChat);
        if (conv == null) continue;
        final lastMessage = await conv.latestMessage();

        final ext = group.extension;
        String? image;
        if(ext?.isNotEmpty==true){
          final map = jsonDecode(ext!);
          image= map['image'];
        }
        model = GroupConversationModel(
            id: group.groupId,
            badgeCount: await conv.unreadCount(),
            groupInfo: group,
            conversation: conv,
            lastMessage: lastMessage,
            image: image??'',
            isOnline: null);
      } catch (e) {
        continue;
      }
      conversations.add(model);
    }
    return conversations;
  }
}
