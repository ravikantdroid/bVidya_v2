import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:permission_handler/permission_handler.dart';

import '/core/helpers/bmeet_helper.dart';
import '/core/helpers/call_helper.dart';
import '/core/helpers/duration.dart';
import '/core/ui_core.dart';
import '/core/utils.dart';
import '/data/models/models.dart';

class P2PCallProvider extends ChangeNotifier {
  final DurationNotifier _read;
  P2PCallProvider(this._read);

  RtcEngine? _engine;
  RtcEngine? get engine => _engine;

  bool _remoteMute = false;
  bool get remoteMute => _remoteMute;

  bool _remoteVideoOn = false;
  bool get remoteVideoOn => _remoteVideoOn;

  bool _isInitialized = false;
  bool _speakerOn = false;

  bool get speakerOn => _speakerOn;

  bool _mute = false;
  bool get mute => _mute;

  bool _videoOn = false;
  bool get videoOn => _videoOn;

  bool _disconnected = false;

  bool _endCall = false;
  bool get isCallEnded => _endCall;

  String _status = 'Calling...';

  String get status => _status;

  CallType _currentCallType = CallType.audio;

  CallType get updateCallType => _currentCallType;

  Timer? _timer;

  late CallDirectionType _callDirection;
  late CallBody _body;
  late CallType _callType;

  int _localId = -1;
  int _remoteId = -1;

  int get remoteId => _remoteId;
  int get localId => _localId;

  AudioPlayer? _player;

  init(CallBody body, CallDirectionType type, CallType callType) {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    _callType = callType;
    _currentCallType = callType;
    _callDirection = type;
    _body = body;

    _initEngine();
  }

  _outgoingTimer() async {
    _player = AudioPlayer();
    //  String audioasset = "assets/audio/Basic.mp3";
    // ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
    // Uint8List soundbytes =
    // bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    _timer = Timer(const Duration(seconds: 30), () {
      _endCall = true;
      notifyListeners();
    });
    try {
      // _player?.repe
      await _player?.play(AssetSource('audio/Basic.mp3'));
    } catch (e) {
      print('$e');
    }
  }

  Future _initEngine() async {
    int userId = (await getMeAsUser())?.id ?? 0;
    try {
      final engine = createAgoraRtcEngine();
      await engine.initialize(
        RtcEngineContext(
          appId: _body.appid,
          channelProfile: ChannelProfileType.channelProfileCommunication1v1,
        ),
      );
      engine.registerEventHandler(RtcEngineEventHandler(
        onUserEnableVideo: (connection, remoteUid, enabled) {
          if (remoteId == _remoteId) {
            _remoteVideoOn = enabled;
            if (_remoteVideoOn && _currentCallType == CallType.audio) {
              _switchToVideoCall();
            }
            notifyListeners();
            print('remote video state: $enabled ');
          }
        },
        onUserMuteAudio: (connection, remoteUid, muted) {},
        onUserMuteVideo: (connection, remoteUid, muted) {},
        onJoinChannelSuccess: (connection, elapsed) {
          _localId = connection.localUid ?? 0;
          if (_callDirection == CallDirectionType.outgoing) {
            _status = 'Ringing';
            _outgoingTimer();
          }
          notifyListeners();
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          _remoteId = remoteUid;
          if (_callDirection == CallDirectionType.outgoing) {
            _timer?.cancel();
            _player?.stop();
          }
          _status = 'Connected';
          notifyListeners();
          _read.start();
        },
        onUserOffline: (connection, remoteUid, reason) {
          _endCall = true;
          notifyListeners();
        },
        onRemoteAudioStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
          if (remoteId == _remoteId) {
            _remoteMute = state != RemoteAudioState.remoteAudioStateDecoding;
            print('remote audio state: $state ');
          }
        },
        // onRemoteVideoStateChanged:
        //     (connection, remoteUid, state, reason, elapsed) {
        //   if (remoteId == _remoteId) {
        //     _remoteVideoOn = state == RemoteVideoState.remoteVideoStateDecoding;
        //     if (_remoteVideoOn && _currentCallType == CallType.audio) {
        //       _switchToVideoCall();
        //     }
        //     notifyListeners();
        //     print('remote video state: ${state.name} ');
        //   }
        // },
      ));

      if (_callType == CallType.video) {
        await engine.enableLocalVideo(true);
        await engine.enableVideo();
        _videoOn = true;
        _speakerOn = true;
      } else {
        await engine.enableLocalVideo(false);
        await engine.disableVideo();
      }
      await engine.enableAudio();

      await engine.muteLocalAudioStream(_mute);
      await engine.setDefaultAudioRouteToSpeakerphone(_speakerOn);

      // await engine.setEnableSpeakerphone(_speakerOn);
      await engine.joinChannel(
        token: _body.callToken,
        channelId: _body.callChannel,
        uid: userId,
        options: ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication1v1,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          publishScreenTrack: false,
          token: _body.callToken,
        ),
      );
      _engine = engine;
      notifyListeners();
    } catch (e) {
      print('Error on join channel: $e');
    }
  }

  _switchToVideoCall() async {
    try {
      // await _engine?.updateChannelMediaOptions(
      //   ChannelMediaOptions(
      //     channelProfile: ChannelProfileType.channelProfileCommunication1v1,
      //     clientRoleType: ClientRoleType.clientRoleBroadcaster,
      //     autoSubscribeAudio: true,
      //     autoSubscribeVideo: true,
      //     publishCameraTrack: true,
      //     publishMicrophoneTrack: true,
      //     publishScreenTrack: false,
      //     token: _body.callToken,
      //   ),
      // );
      _currentCallType = CallType.video;
    } catch (e) {
      print('error in switching mode');
      return;
    }
  }

  toggleVideo(BuildContext context) async {
    try {
      if (_currentCallType == CallType.audio) {
        if (!await handleCameraAndMic(Permission.camera)) {
          // if (defaultTargetPlatform == TargetPlatform.android) {
          AppSnackbar.instance.error(context, 'Need camera permission');
          return;
          // }
        }
        // try {
        //   await _engine?.updateChannelMediaOptions(
        //     ChannelMediaOptions(
        //       channelProfile: ChannelProfileType.channelProfileCommunication1v1,
        //       clientRoleType: ClientRoleType.clientRoleBroadcaster,
        //       autoSubscribeAudio: true,
        //       autoSubscribeVideo: true,
        //       publishCameraTrack: true,
        //       publishMicrophoneTrack: true,
        //       publishScreenTrack: false,
        //       token: _body.callToken,
        //     ),
        //   );
        // } catch (e) {
        //   print('error in switching mode: $e');
        //   return;
        // }
        _currentCallType = CallType.video;
        _remoteVideoOn = true;
      }
      if (_videoOn) {
        await _engine?.disableVideo();
      } else {
        await _engine?.enableVideo();
      }

      await _engine?.enableLocalVideo(!_videoOn);
      _videoOn = !_videoOn;
      notifyListeners();
    } catch (_) {}
  }

  toggleSpeaker() async {
    try {
      await _engine?.setEnableSpeakerphone(!_speakerOn);
      _speakerOn = !_speakerOn;
      notifyListeners();
    } catch (_) {}
  }

  toggleMute() async {
    try {
      await _engine?.muteLocalAudioStream(!_mute);
      _mute = !_mute;
      notifyListeners();
    } catch (_) {}
  }

  void switchCamera() async {
    try {
      await _engine?.switchCamera();
      notifyListeners();
    } catch (_) {}
  }

  disconnect() async {
    if (_disconnected) {
      return;
    }
    _disconnected = true;
    try {
      await _player?.stop();
      await _player?.release();

      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}