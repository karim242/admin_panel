import 'package:admin_app/models/dashbord_btn_model.dart';
import 'package:admin_app/widgets/dashbord_btn_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/title_text.dart';

import '../providers/theme_provider.dart';
import '../services/assets_manager.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/DashboardScreen';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const TitlesTextWidget(label: "Dashboard Screen"),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetsManager.shoppingCart),
          ),
          actions: [
            IconButton(
              onPressed: () {
                themeProvider.setDarkTheme(
                    themeValue: !themeProvider.getIsDarkTheme);
              },
              icon: Icon(themeProvider.getIsDarkTheme
                  ? Icons.light_mode
                  : Icons.dark_mode),
            ),
          ],
        ),
        body: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1,
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.all(2.0),
              child: DashbordBtnWidget(
                dashBoardButton:
                    DashboardButtonsModel.getListItems(context)[index],
                // title: DashboardButtonsModel.getListItems(context)[index]
                //     .text,
                // image: DashboardButtonsModel.getListItems(context)[index]
                //     .imagePath,
                // ontap: () {
                //   DashboardButtonsModel.getListItems(context)[index]
                //       .onTap;
                //  })
                //
              ),
            ),
          ),
        ));
  }
}
