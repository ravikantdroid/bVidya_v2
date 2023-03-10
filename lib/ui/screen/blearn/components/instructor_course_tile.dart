import '/core/constants.dart';
import '/core/ui_core.dart';
import '/data/models/models.dart';

class InstructorCourseTile extends StatelessWidget {
  final Course course;
  const InstructorCourseTile({Key? key, required this.course})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      width: 70.w,
      height: 30.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(2.3.w)),
        color: AppColors.cardWhite,
        border: Border.all(color: const Color(0xFFCECECE), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2.3.w),
                topRight: Radius.circular(2.3.w)),
            child: Image(
              image: getImageProvider(course.image ?? ''),
              height: 14.h,
              // width: 70.w,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    course.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: kFontFamily,
                        color: Colors.black),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    course.description ?? '',
                    maxLines: 1,
                    style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 9.sp,
                        color: Colors.black),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Text(
                        course.rating ?? '',
                        style: TextStyle(
                            color: AppColors.yellowAccent,
                            fontSize: 12.sp,
                            fontFamily: kFontFamily,
                            fontWeight: FontWeight.bold),
                      ),
                      buildRatingBar(double.parse(course.rating ?? '0.0')),
                      Text(
                        '(${course.ratingCount})',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: kFontFamily,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
