import 'package:shimmer/shimmer.dart';

import '/controller/blearn_providers.dart';
import '/core/constants.dart';
import '/core/state.dart';
import '/core/ui_core.dart';
import '/data/models/models.dart';
import '../../widgets.dart';
import 'components/common.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColouredBoxBar(
      topBar: const BAppBar(title: 'Categories'),
      body: Consumer(builder: (context, ref, child) {
        return ref.watch(bLearnCategoriesProvider).when(
          data: ((data) {
            if (data?.categories?.isNotEmpty == true) {
              return _buildList(context, data!.categories!);
            } else {
              return buildEmptyPlaceHolder('No Categories found');
            }
          }),
          error: (error, stackTrace) {
            return buildEmptyPlaceHolder(error.toString());
          },
          loading: () {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: AppColors.cardWhite,
                  highlightColor: AppColors.cardBackground,
                  child: Container(
                    height: 20.w,
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }

  _buildList(BuildContext context, List<Category> categories) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: categories.length,
      separatorBuilder: (context, index) {
        return Container(
          height: 0.5,
          color: const Color(0xFFDBDBDB),
        );
      },
      itemBuilder: (context, index) {
        Category category = categories[index];
        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, RouteList.bLearnSubCategories,
                arguments: category);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
            child: Row(
              children: [
                SizedBox(
                  width: 18.w,
                  child: Image(
                     image: getImageProvider(
                        category.icon == "" || category.icon == null
                            ? category.image ?? ""
                            : category.icon ?? ""),
                    // image: getImageProvider(category.image ?? ''),
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  category.name ?? '',
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
