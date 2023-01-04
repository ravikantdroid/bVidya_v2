import '../../../widget/sliding_tab.dart';
import '/core/constants.dart';
import '/core/state.dart';
import '/core/ui_core.dart';
import '../base_settings_noscroll.dart';
import '../../../widget/courses_circularIndicator.dart';
import '../../../widget/tab_switcher.dart';

final selectedTabLearningProvider = StateProvider<int>((ref) => 0);

class MyLearningScreen extends ConsumerWidget {
  const MyLearningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabLearningProvider);
    return Scaffold(
      body: BaseNoScrollSettings(
          bodyContent: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 3.h),
          Center(
              child: SlidingTab(
                  label1: S.current.sp_tab_course,
                  label2: S.current.sp_tab_followed,
                  selectedIndex: selectedIndex,
                  callback: (index) {
                    ref.read(selectedTabLearningProvider.notifier).state =
                        index;
                  })
              // child: SlideTab(
              //     initialIndex: selectedIndex,
              //     containerWidth: 88.w,
              //     onSelect: (index) {
              //       ref.read(selectedTabLearningProvider.notifier).state = index;
              //     },
              //     containerHeight: 6.h,
              //     direction: Axis.horizontal,
              //     sliderColor: AppColors.primaryColor,
              //     containerBorderRadius: 2.w,
              //     sliderBorderRadius: 2.6.w,
              //     containerColor: AppColors.cardWhite,
              //     activeTextStyle: TextStyle(
              //       color: Colors.white,
              //       fontSize: 9.sp,
              //       fontWeight: FontWeight.w600,
              //       fontFamily: kFontFamily,
              //     ),
              //     inactiveTextStyle: TextStyle(
              //       fontSize: 9.sp,
              //       fontWeight: FontWeight.w600,
              //       fontFamily: kFontFamily,
              //       color: Colors.black,
              //     ),
              //     texts: [
              //       S.current.sp_tab_course,
              //       S.current.sp_tab_followed,
              //     ]),
              ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
            child: selectedIndex == 0 ? _buildCourses() : _buildFollowed(),
          ))
        ],
      )),
    );
  }

  Widget _buildCourses() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return rowCourse();
          }),
    );
  }

  Widget rowCourse() {
    return Container(
      // height: 20.h,
      width: 100.w,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
          color: AppColors.cardWhite,
          border: Border.all(color: AppColors.cardBorder, width: 0.3),
          borderRadius: BorderRadius.circular(3.w)),
      child: Column(
        children: [
          SizedBox(
            height: 15.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 50.w,
                    child: Text(
                      "Course name: Course name and details",
                      style: TextStyle(
                          fontFamily: kFontFamily,
                          color: AppColors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.sp),
                    ),
                  ),
                  const CoursesCircularIndicator(
                    progressValue: 65,
                  )
                ],
              ),
            ),
          ),
          const Divider(
            color: AppColors.divider,
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 3.w, right: 3.w, top: 0.5.h, bottom: 1.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: AppColors.primaryColor,
                      size: 5.w,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 1.w, right: 1.w),
                      child: Text(
                        "0 Hours left",
                        style: TextStyle(
                            fontFamily: kFontFamily,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 7.sp),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      color: AppColors.primaryColor,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 1.w, right: 1.w),
                      child: Text(
                        "Continue Learning",
                        style: TextStyle(
                            fontFamily: kFontFamily,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 8.sp),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFollowed() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: 1.h),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return _buldFollwedRow();
        },
      ),
    );
  }

  Widget _buldFollwedRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      child: Row(
        children: [
          getCicleAvatar('A', '', radius: 3.h),
          // CircleAvatar(
          //   radius: 7.w,
          //   backgroundImage:
          //       AssetImage("assets/images/dummy_profile.png"),
          // ),
          SizedBox(width: 5.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User Name",
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: kFontFamily,
                      color: AppColors.black,
                      fontWeight: FontWeight.w400),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.3.h),
                  child: Text(
                    "2K Followers",
                    style: TextStyle(
                        fontSize: 8.sp,
                        color: AppColors.descTextColor,
                        fontFamily: kFontFamily,
                        fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
