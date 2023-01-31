// import 'package:flutter/material.dart';
import '/controller/bmeet_providers.dart';
import '/core/state.dart';
// import '/data/models/response/auth/login_response.dart';
import '/ui/screen/blearn/components/common.dart';
import '/ui/widget/shimmer_tile.dart';
import 'package:google_fonts/google_fonts.dart';

import '/data/models/response/bmeet/class_request_response.dart';
import '../base_settings_noscroll.dart';
import '/core/constants/colors.dart';
import '/core/ui_core.dart';
// import '../base_settings.dart';

class TeacherClassRequest extends StatelessWidget {
  const TeacherClassRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseNoScrollSettings(
        showName: false,
        bodyContent: Padding(
          padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Class Request",
                style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontSize: 5.5.w,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 1.h),
              Expanded(
                child: Consumer(builder: (context, ref, child) {
                  return ref.watch(bmeetClassesProvider).when(
                    data: (data) {
                      print("data value : $data");
                      if (data == null) {
                        return buildEmptyPlaceHolder("No Class Requests.");
                      }
                      if (data.personalClasses == []) {
                        return buildEmptyPlaceHolder("No Class Requests.");
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: data.personalClasses?.length ?? 0,
                        scrollDirection: Axis.vertical,
                        separatorBuilder: (context, index) =>
                            const Divider(color: AppColors.divider),
                        itemBuilder: (context, index) {
                          return _buildRequestRow(
                              data.personalClasses?[index] ?? PersonalClass());
                        },
                      );
                    },
                    error: (error, stackTrace) {
                      return buildEmptyPlaceHolder("Error");
                    },
                    loading: () {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: 20,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            child: CustomizableShimmerTile(
                                height: 20.w, width: 100.w),
                          );
                        },
                      );
                    },
                  );
                }),
              )
            ],
          ),
        ));
  }

  Widget _buildRequestRow(PersonalClass data) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      child: Row(
        children: [
          getCicleAvatar('A', data.studentImage ?? '', radius: 3.h),
          SizedBox(width: 5.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.studentName ?? "",
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: kFontFamily,
                      color: AppColors.black,
                      fontWeight: FontWeight.w400),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.3.h),
                  child: Text(
                    data.type ?? "",
                    style: TextStyle(
                        fontSize: 8.sp,
                        color: AppColors.descTextColor,
                        fontFamily: kFontFamily,
                        fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                chatwithstudent(data.studentName ?? "", data.userId ?? 0,
                    data.instructorId ?? 0);
              },
              icon: getSvgIcon('icon_req_chat.svg'))
        ],
      ),
    );
  }

  chatwithstudent(String studentname, int studentId, int instructorId) {}
}
