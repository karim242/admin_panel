import 'package:admin_app/screens/edit_upload_product.dart';
import 'package:flutter/material.dart';

import '../screens/inner_screens/orders/orders_screen.dart';
import '../screens/search_screen.dart';
import '../services/assets_manager.dart';

class DashboardButtonsModel {
  final String text, imagePath;
  final VoidCallback onTap;

  DashboardButtonsModel(
      {required this.text, required this.imagePath, required this.onTap});

  static List<DashboardButtonsModel> getListItems(BuildContext context) => [
        DashboardButtonsModel(
          text: "Add a new product",
          imagePath: AssetsManager.cloud,
          onTap: () {
            Navigator.pushNamed(context, EditUploadProduct.routeName);
          },
        ),
        DashboardButtonsModel(
          text: "inspect all products",
          imagePath: AssetsManager.shoppingCart,
          onTap: () {
            Navigator.pushNamed(context, SearchScreen.routeName);
          },
        ),
        DashboardButtonsModel(
          text: "View Orders",
          imagePath: AssetsManager.order,
          onTap: () {
            Navigator.pushNamed(context, OrdersScreenFree.routeName);
          },
        ),
      ];
}
