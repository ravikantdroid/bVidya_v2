import '/core/constants.dart';
import '/core/ui_core.dart';
import '/data/models/models.dart';

class CourseListRow extends StatelessWidget {
  final Course course;
  const CourseListRow({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.all(Radius.circular(3.w)),
        border: Border.all(color: const Color(0xFFCECECE), width: 0.5),
      ),
      margin: EdgeInsets.symmetric(vertical: 0.8.h),
      padding:
          EdgeInsets.only(left: 1.5.w, right: 4.w, top: 0.7.h, bottom: 0.7.h),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3.w),
              child: Image(
                image: getImageProvider(course.image ?? ''),
                height: 7.5.h,
                width: 7.5.h,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "${course.duration} hours",
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    course.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: kFontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 3.5.w,
              backgroundColor: AppColors.primaryColor,
              child: Icon(
                Icons.play_arrow,
                size: 4.w,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
