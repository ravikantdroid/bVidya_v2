import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';

// import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_picker_plus/image_picker_plus.dart' as ipp;

import '/app.dart';
import '/controller/providers/chat_messagelist_provider.dart';
import '/controller/providers/bchat/chat_conversation_provider.dart';
import '/controller/providers/bchat/chat_messeges_provider.dart';
import '/core/utils/chat_utils.dart';
import '/core/helpers/call_helper.dart';
import '/core/sdk_helpers/bchat_handler.dart';
import '/core/utils.dart';
import '/core/constants.dart';
import '/core/state.dart';
import '/core/ui_core.dart';
import '/core/utils/date_utils.dart';
import '/data/models/models.dart';
import 'models/attach_type.dart';
import 'models/reply_model.dart';
import 'widgets/attached_file.dart';
import 'widgets/chat_message_bubble.dart';
import '/ui/dialog/message_menu_popup.dart';
import '../../base_back_screen.dart';
import '../../widgets.dart';
import '../../widget/chat_input_box.dart';
// import 'widgets/typing_indicator.dart';

final attachedFile = StateProvider.autoDispose<AttachedFile?>((_) => null);
final sendingFileProgress = StateProvider.autoDispose<int>((_) => 0);

// ignore: must_be_immutable
class ChatScreen extends HookConsumerWidget {
  final ConversationModel model;
  final bool direct;
  ChatScreen({Key? key, required this.model, this.direct = false})
      : super(key: key);

  // late String _myChatPeerUserId;
  late final ScrollController _scrollController;

  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  late Contacts _me;

  // User? _me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      // print('useEffect Called');
      _scrollController = ScrollController();
      ref.read(bhatMessagesProvider(model)).init();
      _loadMe();
      _scrollController.addListener(() => _onScroll(_scrollController, ref));
      registerForNewMessage('chat_screen', (msg) {
        onMessagesReceived(msg, ref);
      });
      return () {
        unregisterForNewMessage('chat_screen');

        _scrollController.dispose();
      };
    }, const []);

    ref.listen(bhatMessagesProvider(model), (previous, next) {
      _isLoadingMore = next.isLoadingMore;
      _hasMoreData = next.hasMoreData;
    });

    final selectedItems = ref.watch(selectedChatMessageListProvider);
    return BaseWilPopupScreen(
      onBack: () async {
        if (selectedItems.isNotEmpty) {
          ref.read(selectedChatMessageListProvider.notifier).clear();
          return false;
        }
        if (direct) {
          Navigator.pushReplacementNamed(context, RouteList.splash);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: ColouredBoxBar(
          topBar: selectedItems.isNotEmpty
              ? _menuBar(context, selectedItems, ref)
              : _topBar(context, ref),
          body: _chatList(context),
        ),
      ),
    );
  }

  _loadMe() async {
    final user = await getMeAsUser();
    if (user != null) {
      _me = Contacts(
          name: user.name,
          profileImage: user.image,
          userId: user.id,
          email: user.email,
          fcmToken: user.fcmToken,
          phone: user.phone,
          status: ContactStatus.self);
      // _myChatPeerUserId =
      //     ChatClient.getInstance.currentUserId ?? user.id.toString();
    }
  }

  Widget _chatList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          return _buildMessageList(ref);
                        },
                      ),
                    ),
                    // if (typingUsers != null && typingUsers!.isNotEmpty)
                    //   ...typingUsers!.map((ChatUserInfo user) {
                    //     return _buildUserTyping(user.nickName ?? user.userId);
                    //   }).toList(),
                  ],
                ),
                Positioned(
                  top: 8.0,
                  right: 0,
                  left: 0,
                  child: Consumer(
                    builder: (context, ref, child) {
                      bool isLoadingMore = ref.watch(bhatMessagesProvider(model)
                          .select((value) => value.isLoadingMore));
                      return isLoadingMore
                          ? const Center(
                              child: SizedBox(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        _buildReplyBox(),
        // _buildChatInputBox(),
        _buildAttachedFile()
      ],
    );
  }

  Widget _buildAttachedFile() {
    return Consumer(
      builder: (context, ref, child) {
        AttachedFile? attFile = ref.watch(attachedFile);
        int progress = ref.watch(sendingFileProgress);
        return attFile == null
            ? _buildChatInputBox()
            : Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(width: 4.w),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      alignment: Alignment.center,
                      constraints: BoxConstraints(
                        minHeight: 2.h,
                        maxHeight: 20.h,
                      ),
                      decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.all(Radius.circular(3.w))),
                      child: Stack(
                        children: [
                          AttachedFileView(
                            attFile: attFile,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              onPressed: () {
                                ref.read(attachedFile.notifier).state = null;
                              },
                              icon: const Icon(Icons.close, color: Colors.red),
                            ),
                          ),
                          if (progress > 0)
                            Center(
                              child: CircularProgressIndicator(
                                  value: progress.toDouble()),
                            )
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(width: 2.w),
                  InkWell(
                    onTap: () async {
                      final ChatMessage msg;
                      // final String content;
                      if (attFile.messageType == MessageType.IMAGE) {
                        msg = ChatMessage.createImageSendMessage(
                          targetId: model.contact.userId.toString(),
                          filePath: attFile.file.path,
                          fileSize: attFile.file.size.toInt(),
                        );
                        // content = 'Image file';
                      } else if (attFile.messageType == MessageType.VIDEO) {
                        msg = ChatMessage.createVideoSendMessage(
                          targetId: model.contact.userId.toString(),
                          filePath: attFile.file.path,
                          fileSize: attFile.file.size.toInt(),
                        );
                        // content = 'Video file';
                      } else {
                        msg = ChatMessage.createFileSendMessage(
                          targetId: model.contact.userId.toString(),
                          filePath: attFile.file.path,
                          fileSize: attFile.file.size.toInt(),
                        );
                        // content = 'File';
                      }
                      msg.attributes = {
                        "em_apns_ext": {
                          // "em_push_title":
                          //     "${_me.name} sent you a ${attFile.messageType.name.toLowerCase()}",
                          // "em_push_content": content,
                          'type': 'chat',
                          'name': _me.name,
                          'image': _me.profileImage,
                          'content_type': msg.body.type.name,
                        },
                        // Adds the push template to the message.
                        // "em_push_template": {
                        //   // Sets the template name.
                        //   "name": "default",
                        //   // Sets the template title by specifying the variable.
                        //   "title_args": [
                        //     "${model.contact.name} sent you a ${attFile.messageType.name.toLowerCase()}"
                        //   ],
                        //   // Sets the template content by specifying the variable.
                        //   "content_args": [
                        //     (attFile.messageType.name.toLowerCase())
                        //   ],
                        // }
                      };
                      await _sendMessage(msg, ref);
                      ref.read(attachedFile.notifier).state = null;
                    },
                    child: CircleAvatar(
                      radius: 5.w,
                      backgroundColor: AppColors.primaryColor,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20.0,
                      ),
                    ),
                  )
                ],
              );
      },
    );
  }

  Widget _buildReplyBox() {
    return Consumer(
      builder: (context, ref, child) {
        bool show = ref.watch(chatModelProvider).isReplyBoxVisible;
        if (show) {
          ReplyModel replyOf = ref.watch(chatModelProvider).replyOn!;
          return Container(
            width: 90.w,
            margin: EdgeInsets.only(bottom: 1.h),
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppColors.chatBoxBackgroundMine,
              borderRadius: BorderRadius.all(Radius.circular(3.w)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Replying to ${replyOf.fromName}',
                      style: textStyleWhite,
                    ),
                    InkWell(
                      onTap: () {
                        ref.read(chatModelProvider).clearReplyBox();
                      },
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Container(
                    // padding: EdgeInsets.all(1.w),
                    constraints:
                        BoxConstraints(minHeight: 5.h, maxHeight: 25.h),
                    decoration: BoxDecoration(
                      color: AppColors.chatBoxBackgroundOthers,
                      borderRadius: BorderRadius.all(Radius.circular(3.w)),
                    ),
                    child: ChatMessageBodyWidget(message: replyOf.message)
                    //  Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     ChatMessageBodyWidget(message: replyOf.message)
                    //   ],
                    // ),
                    ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildChatInputBox() {
    return Consumer(
      builder: (context, ref, child) {
        return ChatInputBox(
          onSend: (input) async {
            final ChatMessage msg = ChatMessage.createTxtSendMessage(
                targetId: model.id.toString(), content: input);
            // ..from = _myChatPeerUserId;
            msg.attributes = {
              "em_apns_ext": {
                // "em_push_title": "${_me.name} sent you a message",
                // "em_push_content": input,
                'type': 'chat',
                'name': _me.name,
                'image': _me.profileImage,
                'content_type': msg.body.type.name,
              },
              //   // Adds the push template to the message.
              //   // "em_push_template": {
              //   //   // Sets the template name.
              //   //   "name": "default",
              //   //   // Sets the template title by specifying the variable.
              //   //   "title_args": ["${model.contact.name} sent you a message"],
              //   //   // Sets the template content by specifying the variable.x
              //   //   "content_args": [input],
              //   // }
            };
            // ref.read(chatMessageListProvider.notifier).addChat(msg);
            return await _sendMessage(msg, ref);
          },
          onCamera: () {
            _pickFile(AttachType.cameraPhoto, ref, context);
          },
          onAttach: (type) => _pickFile(type, ref, context),
        );
      },
    );
  }

  _pickFile(AttachType type, WidgetRef ref, BuildContext context) async {
    ImagePicker picker = ImagePicker();
    switch (type) {
      case AttachType.cameraPhoto:
        // SelectedImagesDetails? details =
        //     await picker.pickImage(source: ImageSource.camera);
        XFile? xFile = await picker.pickImage(source: ImageSource.camera);
        if (xFile != null) {
          // File file = xFile.path;
          final Media media = Media(
              path: xFile.path,
              size: (await xFile.length()).toDouble(),
              thumbPath: xFile.path);
          ref.read(attachedFile.notifier).state =
              AttachedFile(media, MessageType.IMAGE);
        }
        break;
      case AttachType.cameraVideo:
        XFile? xFile = await picker.pickImage(source: ImageSource.camera);
        if (xFile != null) {
          final thumb = await VideoThumbnail.thumbnailFile(
            video: xFile.path,
            thumbnailPath: Directory.systemTemp.path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 128,
            quality: 25,
          );
          final Media media = Media(
              path: xFile.path,
              size: (await xFile.length()).toDouble(),
              thumbPath: thumb);
          ref.read(attachedFile.notifier).state =
              AttachedFile(media, MessageType.VIDEO);
        }
        break;
      case AttachType.media:
        ipp.ImagePickerPlus pickerPlus = ipp.ImagePickerPlus(context);
        ipp.SelectedImagesDetails? details =
            await pickerPlus.pickBoth(source: ipp.ImageSource.gallery);
        if (details != null && details.selectedFiles.isNotEmpty) {
          File file = details.selectedFiles.first.selectedFile;
          bool isImage = file.path.toLowerCase().endsWith('png') ||
              file.path.toLowerCase().endsWith('jpg') ||
              file.path.toLowerCase().endsWith('jpeg');
          if (isImage) {
            final Media media = Media(
                path: file.absolute.path,
                size: (await file.length()).toDouble(),
                thumbPath: file.absolute.path);
            ref.read(attachedFile.notifier).state =
                AttachedFile(media, MessageType.IMAGE);
          } else {
            final thumb = await VideoThumbnail.thumbnailFile(
              video: file.path,
              thumbnailPath: Directory.systemTemp.path,
              imageFormat: ImageFormat.JPEG,
              maxWidth: 128,
              quality: 25,
            );
            final Media media = Media(
                path: file.absolute.path,
                size: (await file.length()).toDouble(),
                thumbPath: thumb);
            ref.read(attachedFile.notifier).state =
                AttachedFile(media, MessageType.VIDEO);
          }
        }
        break;
      case AttachType.audio:
        break;
      case AttachType.docs:
        break;
    }
  }

  _pickFiles(AttachType type, WidgetRef ref) async {
    switch (type) {
      case AttachType.cameraPhoto:
        List<Media>? res = await ImagesPicker.openCamera(
          quality: 0.8,
          pickType: PickType.image,
          maxSize: 5000, //5 MB
        );
        print(res);
        if (res != null) {
          final Media media = res.first;
          ref.read(attachedFile.notifier).state =
              AttachedFile(media, MessageType.IMAGE);
        }
        return;
      case AttachType.cameraVideo:
        List<Media>? res = await ImagesPicker.openCamera(
          quality: 0.8,
          pickType: PickType.video,
          maxSize: 10000, //10 MB
        );
        print(res);
        if (res != null) {
          final Media media = res.first;
          ref.read(attachedFile.notifier).state =
              AttachedFile(media, MessageType.VIDEO);
        }
        return;
      case AttachType.media:
        List<Media>? res = await ImagesPicker.pick(
          count: 1,
          pickType: PickType.all,
          language: Language.System,
          maxSize: 5000,
        );
        print(res);
        if (res != null) {
          final Media media = res.first;
          bool isImage = media.path.toLowerCase().endsWith('png') ||
              media.path.toLowerCase().endsWith('jpg') ||
              media.path.toLowerCase().endsWith('jpeg');
          ref.read(attachedFile.notifier).state = AttachedFile(
              media, isImage ? MessageType.IMAGE : MessageType.VIDEO);
        }
        break;
      // ;
      case AttachType.audio:
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['aac', 'mp3', 'wav'],
        );
        if (result != null) {
          PlatformFile file = result.files.first;
          final Media media = Media(
              path: file.path!,
              size: (await File(file.path!).length()).toDouble());
          ref.read(attachedFile.notifier).state =
              AttachedFile(media, MessageType.VOICE);
        }
        // fileExts = ['aac', 'mp3', 'wav'];
        break;
      case AttachType.docs:
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'txt'],
        );
        if (result != null) {
          PlatformFile file = result.files.first;
          final Media media = Media(
              path: file.path!,
              size: (await File(file.path!).length()).toDouble());
          ref.read(attachedFile.notifier).state =
              AttachedFile(media, MessageType.FILE);
        }
        // docPaths = await DocumentsPicker.pickDocuments;
        // fileExts = ['txt', 'pdf', 'doc', 'docx', 'ppt', 'xls'];
        break;
    }
  }

  Widget _buildMessageList(WidgetRef ref) {
    final chatList = ref
        .watch(bhatMessagesProvider(model).select((value) => value.messages))
        .reversed
        .toList();
    final selectedItems = ref.watch(selectedChatMessageListProvider);

    return ListView.builder(
      shrinkWrap: true,
      reverse: true,
      controller: _scrollController,
      itemCount: chatList.length,
      itemBuilder: (context, i) {
        final ChatMessage? previousMessage =
            i < chatList.length - 1 ? chatList[i + 1] : null;
        final ChatMessage? nextMessage = i > 0 ? chatList[i - 1] : null;
        final ChatMessage message = chatList[i];
        final bool isAfterDateSeparator =
            shouldShowDateSeparator(previousMessage, message);
        bool isBeforeDateSeparator = false;
        if (nextMessage != null) {
          isBeforeDateSeparator = shouldShowDateSeparator(message, nextMessage);
        }
        bool isPreviousSameAuthor = false;
        bool isNextSameAuthor = false;
        if (previousMessage?.from == message.from) {
          isPreviousSameAuthor = true;
        }
        if (nextMessage?.from == message.from) {
          isNextSameAuthor = true;
        }
        bool isSelected = selectedItems.contains(message);

        bool isOwnMessage = message.from != model.id;
        isOwnMessage ? _markOwnRead(message) : _markRead(message);

        bool notReply = message.body.type == MessageType.CMD ||
            message.body.type == MessageType.CUSTOM;
        // print('notReply -> $notReply , type=> ${message.chatType} ');

        return Column(
          // crossAxisAlignment:
          //     isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isAfterDateSeparator)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  formatDateSeparator(
                      DateTime.fromMillisecondsSinceEpoch(message.serverTime)),
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    color: Colors.grey,
                    fontSize: 8.sp,
                  ),
                ),
              ),
            SwipeTo(
              rightSwipeWidget: const SizedBox.shrink(),
              onRightSwipe: notReply
                  ? null
                  : () {
                      ref.read(chatModelProvider.notifier).setReplyOn(
                          message,
                          isOwnMessage
                              ? S.current.bmeet_user_you
                              : model.contact.name);
                      // print('open replyBox');
                    },
              child: GestureDetector(
                onLongPress: () =>
                    _onMessageLongPress(message, isSelected, ref),
                onTap: () => selectedItems.isNotEmpty
                    ? _onMessageTapSelect(message, isSelected, ref)
                    : notReply
                        ? null
                        : _onMessageTap(message, context, ref),
                child: Container(
                  margin: const EdgeInsets.only(top: 2, bottom: 4),
                  width: double.infinity,
                  color: isSelected ? Colors.grey.shade200 : Colors.transparent,
                  child: ChatMessageBubble(
                    message: message,
                    isOwnMessage: isOwnMessage,
                    senderUser: isOwnMessage ? _me : model.contact,
                    isPreviousSameAuthor: isPreviousSameAuthor,
                    isNextSameAuthor: isNextSameAuthor,
                    isAfterDateSeparator: isAfterDateSeparator,
                    isBeforeDateSeparator: isBeforeDateSeparator,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _onMessageLongPress(ChatMessage message, bool selected, WidgetRef ref) {
    // ChatClient.getInstance.chatManager.a
    if (selected) {
      ref.read(selectedChatMessageListProvider.notifier).remove(message);
    } else {
      ref.read(selectedChatMessageListProvider.notifier).addChat(message);
    }
  }

  _onMessageTap(
      ChatMessage message, BuildContext context, WidgetRef ref) async {
    // if (message.body.type == MessageType.IMAGE) {
    //   //open image
    //   showImageViewer(
    //       context,
    //       getImageProviderChatImage(message.body as ChatImageMessageBody,
    //           loadThumbFirst: false), onViewerDismissed: () {
    //     // print("dismissed");
    //   });

    //   // Navigator.pushNamed(context, RouteList.bViewImage,
    //   //     arguments: message.body as ChatImageMessageBody);
    // } else if (message.body.type == MessageType.VIDEO) {
    //   Navigator.pushNamed(context, RouteList.bViewVideo,
    //       arguments: message.body as ChatVideoMessageBody);
    // } else if (message.body.type == MessageType.FILE) {
    // } else
    {
      final action = await showMessageMenu(context, message);
      if (action == 0) {
        //Copy
        AppSnackbar.instance.message(context, 'Need to implement');
      } else if (action == 1) {
        //Forward
        AppSnackbar.instance.message(context, 'Need to implement');
      } else if (action == 2) {
        //Reply
        bool isOwnMessage = message.from != model.id;
        ref.read(chatModelProvider.notifier).setReplyOn(message,
            isOwnMessage ? S.current.bmeet_user_you : model.contact.name);
      } else if (action == 3) {
        //Delete
        ref
            .read(bhatMessagesProvider(model).notifier)
            .deleteMessages([message]);
      }
    }
  }

  _onMessageTapSelect(ChatMessage message, bool selected, WidgetRef ref) {
    if (selected) {
      ref.read(selectedChatMessageListProvider.notifier).remove(message);
    } else {
      ref.read(selectedChatMessageListProvider.notifier).addChat(message);
    }
  }

  Future<String?> _sendMessage(ChatMessage msg, WidgetRef ref) async {
    // if (_me == null) return 'User details not loaded yet';
    try {
      msg.attributes?.addAll({"em_force_notification": true});
      ReplyModel? replyOf = ref.read(chatModelProvider).replyOn;
      if (replyOf != null) {
        msg.attributes?.addAll({'reply_of': replyOf.toJson()});
        ref.read(chatModelProvider).clearReplyBox();
      }

      msg.setMessageStatusCallBack(
        MessageStatusCallBack(
          onSuccess: () {
            hideLoading(ref);
            ref.read(sendingFileProgress.notifier).state = 0;
            // FCMApiService.instance.sendChatPush(
            //     msg, 'toToken', _myUserId, _me!.name, NotificationType.chat);
            // Occurs when the message sending succeeds. You can update the message and add other operations in this callback.
          },
          onError: (error) {
            hideLoading(ref);
            ref.read(sendingFileProgress.notifier).state = 0;
            AppSnackbar.instance
                .error(navigatorKey.currentContext!, error.description);
            // Occurs when the message sending fails. You can update the message status and add other operations in this callback.
          },
          onProgress: (progress) {
            showLoading(ref);
            ref.read(sendingFileProgress.notifier).state = progress;
            // For attachment messages such as image, voice, file, and video, you can get a progress value for uploading or downloading them in this callback.
          },
        ),
      );
      // final chat = await ChatClient.getInstance.chatManager.sendMessage(msg);
      final chat =
          await ref.read(bhatMessagesProvider(model).notifier).sendMessage(msg);
      if (chat != null) {
        ref
            .read(chatConversationProvider.notifier)
            .updateConversationMessage(msg);
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return null;
      }
    } on ChatError catch (e) {
      print("send failed, code: ${e.code}, desc: ${e.description}");
      AppSnackbar.instance.error(navigatorKey.currentContext!,
          "Error while sending message: ${e.code}");
      return e.description;
    } catch (e) {
      print("send failed, code: $e");
      AppSnackbar.instance
          .error(navigatorKey.currentContext!, "Error while sending message");
      return e.toString();
    }
    return 'Error while sending message';
  }

  // Widget _buildUserTyping(String name) {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 15, top: 25),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.end,
  //       children: <Widget>[
  //         const Padding(
  //           padding: EdgeInsets.only(right: 2),
  //           child: TypingIndicator(),
  //         ),
  //         RichText(
  //           text: TextSpan(
  //             children: [
  //               TextSpan(
  //                   text: name,
  //                   style: const TextStyle(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.bold,
  //                   )),
  //               const TextSpan(
  //                 text: ' is typing',
  //                 style: TextStyle(fontSize: 12),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void onMessagesReceived(List<ChatMessage> messages, WidgetRef ref) {
    ref.read(bhatMessagesProvider(model)).addChats(messages);
  }

  Future<void> _onScroll(
      ScrollController scrollController, WidgetRef ref) async {
    // print('has _isLoadingMore :$_isLoadingMore');
    // print('has More Data :$_hasMoreData');
    if (!_isLoadingMore && _hasMoreData) {
      bool topReached = scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange;
      if (topReached) {
        ref.watch(bhatMessagesProvider(model).notifier).loadMore();
      }
    }

    // bool topReached =
    //     scrollController.offset >= scrollController.position.maxScrollExtent &&
    //         !scrollController.position.outOfRange;
    // if (topReached && !_isLoadingMore && _hasMoreData) {
    //   ref.watch(chatLoadingPreviousProvider.notifier).state = true;
    //   // showScrollToBottom();
    //   await onLoadEarlier(ref);
    //   ref.watch(chatLoadingPreviousProvider.notifier).state = false;
    // }
    //  else if (scrollController.offset > 200) {
    //   showScrollToBottom();
    // } else {
    //   hideScrollToBottom();
    // }
  }

  void showScrollToBottom() {
    // if (!scrollToBottomIsVisible) {
    //   setState(() {
    //     scrollToBottomIsVisible = true;
    //   });
    // }
  }

  void hideScrollToBottom() {
    // if (scrollToBottomIsVisible) {
    //   setState(() {
    //     scrollToBottomIsVisible = false;
    //   });
    // }
  }

  // _navigateBack(BuildContext context) {
  //   Navigator.pop(context);
  // }

  // ChatUserInfo _getUser() {
  //   Map map = {
  //     'userId': '1',
  //     'nickName': model.contact.name??'',
  //     'avatarUrl': model.contact.profileImage??''
  //   };

  //   //map["userId"],
  //   // nickName: map.getStringValue("nickName"),
  //   // avatarUrl: map.getStringValue("avatarUrl"),
  //   // mail: map.getStringValue("mail"),
  //   // phone: map.getStringValue("phone"),
  //   // gender: map.getIntValue("gender", defaultValue: 0)!,
  //   // sign: map.getStringValue("sign"),
  //   // birth: map.getStringValue("birth"),
  //   // ext: map.getStringValue("ext"),

  //   return ChatUserInfo.fromJson(map);
  // }
  Widget _menuBar(BuildContext context, final List<ChatMessage> selectedItems,
      WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      // color: AppColors.primaryColor,
      child: Row(
        children: [
          // SizedBox(width: 6.w,)
          Expanded(
            child: Text(
              selectedItems.length > 1
                  ? '${selectedItems.length} Messages selected'
                  : '${selectedItems.length} Message',
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // const Spacer(),
          Visibility(
            visible: (selectedItems
                .where((e) => e.body.type != MessageType.TXT)
                .isEmpty),
            child: IconButton(
              onPressed: () async {
                // ref
                //     .read(bhatMessagesProvider(model).notifier)
                //     .deleteMessages(selectedItems);
                ref.read(selectedChatMessageListProvider.notifier).clear();
                AppSnackbar.instance.message(context, 'Need to implement');
                // ChatClient.getInstance.chatManager.del
              },
              padding: EdgeInsets.all(1.w),
              tooltip: S.current.chat_menu_copy,
              icon: getSvgIcon(
                'icon_chat_copy.svg',
                width: 5.w,
                color: Colors.white,
              ),
            ),
          ),
          Visibility(
            visible: selectedItems.length == 1 &&
                selectedItems.first.body.type != MessageType.CUSTOM,
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    // ref
                    //     .read(bhatMessagesProvider(model).notifier)
                    //     .deleteMessages(selectedItems);
                    ref.read(selectedChatMessageListProvider.notifier).clear();
                    AppSnackbar.instance.message(context, 'Need to implement');
                    // ChatClient.getInstance.chatManager.del
                  },
                  padding: EdgeInsets.all(1.w),
                  tooltip: S.current.chat_menu_forward,
                  icon: getSvgIcon(
                    'icon_chat_forward.svg',
                    width: 5.w,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    ChatMessage message = selectedItems.first;
                    bool isOwnMessage = message.from != model.id;
                    ref.read(chatModelProvider.notifier).setReplyOn(
                        message,
                        isOwnMessage
                            ? S.current.bmeet_user_you
                            : model.contact.name);
                    // ref
                    //     .read(bhatMessagesProvider(model).notifier)
                    //     .deleteMessages(selectedItems);
                    ref.read(selectedChatMessageListProvider.notifier).clear();
                    // ChatClient.getInstance.chatManager.del
                  },
                  padding: EdgeInsets.all(1.w),
                  tooltip: S.current.chat_menu_reply,
                  icon: getSvgIcon(
                    'icon_chat_reply.svg',
                    width: 5.w,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              ref
                  .read(bhatMessagesProvider(model).notifier)
                  .deleteMessages(selectedItems);
              ref.read(selectedChatMessageListProvider.notifier).clear();
              // ChatClient.getInstance.chatManager.del
            },
            padding: EdgeInsets.all(1.w),
            tooltip: S.current.chat_menu_delete,
            icon: getSvgIcon(
              'icon_delete_conv.svg',
              width: 5.w,
              color: Colors.white,
            ),
          ),
          // IconButton(
          //   onPressed: () async {
          //     ref
          //         .read(bhatMessagesProvider(model).notifier)
          //         .deleteMessages(selectedItems);
          //     ref.read(selectedChatMessageListProvider.notifier).clear();
          //     // ChatClient.getInstance.chatManager.del
          //   },
          //   icon: const Icon(
          //     Icons.delete,
          //     color: Colors.white,
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context, WidgetRef ref) {
    // final value = ref.watch(onlineStatusProvier);
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: (() {
                if (direct) {
                  Navigator.pushReplacementNamed(context, RouteList.splash);
                } else {
                  Navigator.pop(context);
                }
              }),
              icon: getSvgIcon('arrow_back.svg', width: 6.w),
            ),
            // SizedBox(width: 2.w),

            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 2.w),
            //   child: ,
            // ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, RouteList.contactProfile,
                      arguments: model.contact);
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 2.w, top: 1.h, bottom: 1.h),
                  child: Row(
                    children: [
                      // SizedBox(width: 2.w),
                      getRectFAvatar(
                        model.contact.name,
                        model.contact.profileImage,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.contact.name,
                              style: TextStyle(
                                  fontFamily: kFontFamily,
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              parseChatPresenceToReadable(ref.watch(
                                  bhatMessagesProvider(model)
                                      .select((value) => value.onlineStatus))),
                              // parseChatPresenceToReadable(value),
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                color: AppColors.yellowAccent,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                final msg = await makeAudioCall(model.contact, ref, context);
                if (msg != null) {
                  ref.read(bhatMessagesProvider(model).notifier).addChat(msg);
                }
                // Navigator.pushNamed(context, RouteList.bChatAudioCall);
              },
              icon: getSvgIcon(
                'icon_audio_call.svg',
                width: 6.w,
              ),
            ),
            SizedBox(width: 2.w),
            IconButton(
              onPressed: () async {
                // receiveAudioCall(
                //   'YcJ5uHP31M8sMyAZ1msC',
                //   model.contact.profileImage,
                //   ref,
                //   context,
                // );
                final msg = await makeVideoCall(model.contact, ref, context);
                if (msg != null) {
                  ref.read(bhatMessagesProvider(model).notifier).addChat(msg);
                }
                // Navigator.pushNamed(context, RouteList.bChatVideoCall);
                // makeFakeCallInComing();
              },
              icon: getSvgIcon(
                'icon_video_call.svg',
                width: 6.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markRead(ChatMessage message) async {
    if (!message.hasRead) {
      await ChatClient.getInstance.chatManager.sendMessageReadAck(message);
      await model.conversation?.markMessageAsRead(message.msgId);
    }
  }

  void _markOwnRead(ChatMessage message) async {
    if (!message.hasRead) {
      await model.conversation?.markMessageAsRead(message.msgId);
    }
  }
}
