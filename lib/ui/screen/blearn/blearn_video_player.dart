import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '../../../controller/blearn_providers.dart';
import '../../../core/state.dart';
import '../../../core/ui_core.dart';
import '../../../data/models/response/blearn/lessons_response.dart';
import '../../screens.dart';
import 'components/common.dart';
import 'components/lesson_list_tile.dart';

class BlearnVideoPlayer extends StatefulWidget {
  final Lesson lesson;
  final int courseId;
  const BlearnVideoPlayer(
      {super.key, required this.lesson, required this.courseId});

  @override
  State<BlearnVideoPlayer> createState() => _BlearnVideoPlayerState();
}

class _BlearnVideoPlayerState extends State<BlearnVideoPlayer> {
  //controllers
  TargetPlatform? _platform;
  late VideoPlayerController _videoPlayerController1;
  ChewieController? _chewieController;
  int? bufferDelay;

  //videoController values

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializePlayer(); //function to initialize controllers
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  //Value intializations
  Future<void> initializePlayer() async {
    _videoPlayerController1 =
        VideoPlayerController.network(widget.lesson.videoUrl.toString());
    await Future.wait([
      _videoPlayerController1.initialize(),
    ]);
    _createChewieController();
    setState(() {});
  }

  //chewieController
  void _createChewieController() {
    // final subtitles = [
    //     Subtitle(
    //       index: 0,
    //       start: Duration.zero,
    //       end: const Duration(seconds: 10),
    //       text: 'Hello from subtitles',
    //     ),
    //     Subtitle(
    //       index: 0,
    //       start: const Duration(seconds: 10),
    //       end: const Duration(seconds: 20),
    //       text: 'Whats up? :)',
    //     ),
    //   ];

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      progressIndicatorDelay:
          bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: () {},
            iconData: Icons.live_tv_sharp,
            title: 'Toggle Video Src',
          ),
        ];
      },
      hideControlsTimer: const Duration(seconds: 1),
      placeholder: Container(
        color: Colors.white,
      ),
      autoInitialize: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? SizedBox(
                    height: 30.h,
                    child: Chewie(
                      controller: _chewieController!,
                    ),
                  )
                : SizedBox(
                    height: 30.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Loading'),
                      ],
                    ),
                  ),
            Consumer(
              builder: (context, ref, child) {
                return ref.watch(bLearnLessonsProvider(widget.courseId)).when(
                    data: (data) {
                      if (data?.lessons?.isNotEmpty == true) {
                        return _buildLessons(ref, data!.lessons!);
                      } else {
                        return buildEmptyPlaceHolder('No Lessons');
                        // return _buildLessons();
                      }
                    },
                    error: (error, stackTrace) => buildEmptyPlaceHolder('text'),
                    loading: () => buildLoading);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessons(WidgetRef ref, List<Lesson> lessons) {
    final selectedIndex = ref.watch(selectedIndexLessonProvider);

    return Expanded(
      child: ListView.builder(
        itemCount: lessons.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (() async {
              _chewieController?.pause();
              showLoading(ref);
              _videoPlayerController1 = VideoPlayerController.network(
                  lessons[index].videoUrl.toString());
              await Future.wait([
                _videoPlayerController1.initialize(),
              ]);
              _createChewieController();
              hideLoading(ref);
              setState(() {
                ref.read(selectedIndexLessonProvider.notifier).state = index;
              });
            }),
            child: LessonListTile(
              index: index,
              openIndex: selectedIndex,
              lesson: lessons[index],
            ),
          );
        },
      ),
    );
  }

  // Widget _buildLessons(WidgetRef ref, List<Lesson> lessons) {
  //   final selectedIndex = ref.watch(selectedIndexLessonProvider);
  //   return ListView.builder(
  //     itemCount: lessons.length,
  //     shrinkWrap: true,
  //     scrollDirection: Axis.vertical,
  //     itemBuilder: (context, index) {
  //       return GestureDetector(
  //         onTap: (() async {
  // _chewieController?.pause();
  // showLoading(ref);
  // _videoPlayerController1 = VideoPlayerController.network(
  //     lessons[index].videoUrl.toString());
  // await Future.wait([
  //   _videoPlayerController1.initialize(),
  // ]);
  // _createChewieController();
  // hideLoading(ref);
  // setState(() {
  //   ref.read(selectedIndexLessonProvider.notifier).state = index;
  // });
  //         }),
  //         child: LessonListTile(
  //           index: index,
  //           openIndex: selectedIndex,
  //           lesson: lessons[index],
  //         ),
  //       );
  //     },
  //   );
  // }
}