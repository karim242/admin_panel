import 'package:admin_app/models/dashbord_btn_model.dart';
import 'package:admin_app/widgets/subtitle_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DashbordBtnWidget extends StatelessWidget {
  const DashbordBtnWidget({
    super.key,
    // required this.title,
    // required this.image,
    // required this.ontap,
    required this.dashBoardButton,
  });
  // final String title, image;
  // final VoidCallback ontap;

  final DashboardButtonsModel dashBoardButton;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: dashBoardButton.onTap,
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              dashBoardButton.imagePath,
              width: 56,
              height: 56,
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: SubtitleTextWidget(label: dashBoardButton.text),
            ),
          ],
        ),
      ),
    );
  }
}
