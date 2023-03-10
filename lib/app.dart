// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controller/bchat_providers.dart';
import 'core/helpers/group_member_helper.dart';
import 'core/utils/request_utils.dart';
import 'ui/base_back_screen.dart';
import 'core/helpers/foreground_message_helper.dart';
import 'core/sdk_helpers/bchat_sdk_controller.dart';
import 'controller/providers/bchat/chat_conversation_list_provider.dart';
import 'core/sdk_helpers/bchat_handler.dart';
import 'core/state.dart';
import 'core/utils.dart';

import 'controller/providers/bchat/groups_conversation_provider.dart';
import 'controller/providers/user_auth_provider.dart';
import 'core/constants.dart';
import 'core/helpers/background_helper.dart';
import 'core/helpers/apns_handler.dart';
import 'core/routes.dart';
import 'core/theme/apptheme.dart';
import 'core/ui_core.dart';
import 'core/utils/callkit_utils.dart';
// import 'core/utils/notification_controller.dart';
import 'ui/screen/welcome/splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ResponsiveApp extends StatelessWidget {
  const ResponsiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return const BVidyaApp();
      },
    );
  }
}

initLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.hourGlass
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = AppColors.yellowAccent
    ..backgroundColor = AppColors.primaryColor
    ..indicatorColor = AppColors.yellowAccent
    ..textColor = AppColors.yellowAccent
    ..maskColor = AppColors.primaryColor
    ..userInteractions = false
    ..dismissOnTap = false;
}

class BVidyaApp extends ConsumerStatefulWidget {
  const BVidyaApp({Key? key}) : super(key: key);

  @override
  ConsumerState<BVidyaApp> createState() => _BVidyaAppState();
}

class _BVidyaAppState extends ConsumerState<BVidyaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    appLoaded = false;
    WidgetsBinding.instance.addObserver(this);
    setupCallKit();

    initLoading();
    _firebase();

    // NotificationController.startListeningNotificationEvents();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      debugPrint('Hello I m here foreground');
      // BChatSDKController.instance.loginOnlyInForeground();
      // AndroidForegroundService.stopForeground();
    } else if (state == AppLifecycleState.paused) {
      debugPrint('Hello I m here background');
      // BChatSDKController.instance.logoutOnlyInBackground();
    }
    if (state == AppLifecycleState.detached) {
      debugPrint('Hello I m here in termination');
    }
  }

  void _firebase() async {
    if (Platform.isAndroid) {
      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        debugPrint('onMessageOpenedApp => ${message.from} : ${message.data}');
        BuildContext? contx = navigatorKey.currentContext;
        if (contx != null) {
          showLoading(ref);
          ForegroundMessageHelper.onMessageOpen(message, contx);
          hideLoading(ref);
        } else {
          debugPrint('Null Context =>');
        }
      });
    } else if (Platform.isIOS) {
      ApnsPushConnectorOnly.instance.configureApns(
        onMessageTap: (message) async {
          debugPrint('foreground=>:${message.data}');
          BuildContext? contx = navigatorKey.currentContext;
          if (contx != null) {
            showLoading(ref);
            ApnsPushConnectorOnly.onMessageOpen(message, contx);
            hideLoading(ref);
          } else {
            debugPrint('Null Context =>');
          }
        },
        onMessage: (message) async {
          // print('onMessage:${message.data}');
        },
      );
    }

    FirebaseMessaging.onMessage.listen((message) async {
      print('onMessage => ${message.data} : ${message.notification}');
      if ((await getMeAsUser()) == null) return;
      //For P2P Call
      if (message.data['type'] == NotiConstants.typeCall) {
        final String? action = message.data['action'];
        if (action == NotiConstants.actionCallStart) {
          BackgroundHelper.showCallingNotification(message, false);
        } else if (action == NotiConstants.actionCallEnd) {
          closeIncomingCall(message);
        }
      } else if (message.data['type'] == NotiConstants.typeGroupCall) {
        final String? action = message.data['action'];
        if (action == NotiConstants.actionCallStart) {
          BackgroundHelper.showGroupCallingNotification(message, false);
        }
        if (action == NotiConstants.actionCallEnd) {
          closeIncomingGroupCall(message);
        }
      } else if (message.data['type'] == NotiConstants.typeContact) {
        final String? fromId = message.data['f'];
        ContactAction? action = contactActionFrom(message.data['action']);
        if (action != null && fromId != null) {
          ContactRequestHelper.handleNotification(
              message.notification, action, fromId, true,
              ref: ref);
        }
      } else if (message.data['type'] == NotiConstants.typeGroupMemberUpdate) {
        final String? fromId = message.data['f'];
        final String? grpId = message.data['g'];
        GroupMemberAction? action = groupActionFrom(message.data['action']);
        if (action != null && fromId != null && grpId != null) {
          GroupMemberHelper.handleNotification(
              message.notification, action, fromId, grpId, true,
              ref: ref);
        }
      }
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      try {
        if (Platform.isIOS) {
          String? aPNStoken = await FirebaseMessaging.instance.getAPNSToken();
          if (aPNStoken != null) {
            await ChatClient.getInstance.pushManager
                .updateAPNsDeviceToken(aPNStoken);
          }
        }
        await ChatClient.getInstance.pushManager.updateFCMPushToken(token);
      } catch (_) {}
      debugPrint('onTokenRefresh: $token');
    }, onDone: () {
      debugPrint('onTokenRefresh DONE');
    }, onError: (e) {
      debugPrint('onTokenRefresh Error $e');
    });
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    //   if (message.data['alert'] != null && message.data['e'] != null) {
    //     handleRemoteMessage(message, context, fallbackScreen: '');
    //   }
    // });
    // if ((await getMeAsUser()) == null) return;
    registerForNewMessage(
      'bVidyaApp',
      (msgs) async {
        if (!appLoaded) return;
        // if ((await getMeAsUser()) == null) return;
        for (var lastMessage in msgs) {
          if (lastMessage.conversationId == null) {
            continue;
          }
          if (lastMessage.chatType == ChatType.Chat) {
            final value = await onNewChatMessage(lastMessage, ref);
            // final value = await ref
            //     .read(chatConversationProvider.notifier)
            //     .updateConversationMessage(lastMessage,
            //         update: Routes.getCurrentScreen() == RouteList.home);
            if (lastMessage.body.type == MessageType.CUSTOM) {
              // if (activeCallId != null) return;
              ForegroundMessageHelper.handleCallNotification(lastMessage, ref);
            } else if (value != null) {
              ForegroundMessageHelper.showForegroundChatNotification(
                  value, lastMessage);
            }
          } else if (lastMessage.chatType == ChatType.GroupChat) {
            // print('on GroupChat Message=> ${lastMessage.body.toJson()} ');
            await ref
                .read(groupConversationProvider.notifier)
                .updateConversationMessage(
                    lastMessage, lastMessage.conversationId!,
                    update: Routes.getCurrentScreen() == RouteList.groups);
            // final values = ref.read(groupConversationProvider);
            final value = ref.read(groupConversationProvider).firstWhereOrNull(
                (element) => element.id == lastMessage.conversationId);
            if (value != null) {
              ForegroundMessageHelper.showForegroundGroupChatNotification(
                  value, lastMessage);
            }

            ref.invalidate(groupUnreadCountProvider); //Reset Group Unread count
            // if(values.l.contains(lastMessage.conversationId)){
            // }
            // NotificationController.handleForegroundMessage(lastMessage);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userLoginStateProvider, (previous, next) {
      if (previous != null && next == null) {
        BuildContext? cntx = navigatorKey.currentContext;
        if (cntx != null) {
          Navigator.pushNamedAndRemoveUntil(
              cntx, RouteList.login, (route) => false);
        }
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeLight,
      darkTheme: AppTheme.themeDark,
      themeMode: ThemeMode.light,
      builder: EasyLoading.init(),
      onGenerateRoute: Routes.generateRoute,
      home: const SplashScreen(),
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }

  @override
  void dispose() {
    debugPrint('Hello I m here dispose');
    try {
      unregisterForNewMessage('bVidyaApp');
      BChatSDKController.instance.destroyed();
      // ChatClient.getInstance.logout(false);
      Routes.resetScreen();
    } catch (e) {
      print('object $e');
    }
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }
}


//fPxs8N8570Rztkg73fBPve:APA91bE97WF_-tMluAyR0I77zVvha4Y1yYl5T4ceWF2xDAnP-WHJ33Tj0hHZeOLoc9owKoob3dJ2H2Hbv0_9QtGqsL6Op85cum-5vRgh_bUuLgpokoGS1twc1b0V-eB07ECMCCy2neYw


//ePJ24RCsRrSNSFfMmzr6f6:APA91bFC_SaLTKYfc0iCG2EVRau4HYzgFVz6ZO-xUzxDJ1JZ9rDdANI4t_PuJu_fJbQiK0SupXjj_vBo9erRpNaLbiH1O-BQTb4uQbkvkeFoHBP_xjGurO5tACFJdpr8UWldjGgRRzZ0