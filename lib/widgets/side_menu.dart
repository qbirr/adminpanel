import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:useradmin/inner_screen/all_orders_screen.dart';
import 'package:useradmin/inner_screen/all_products.dart';
import 'package:useradmin/screen/discount_screen.dart';
import 'package:useradmin/widgets/text_widgets.dart';

import '../provider/dark_theme_provider.dart';
import '../screen/main_screen.dart';
import '../services/utils.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    final themeState = Provider.of<DarkThemeProvider>(context);

    final color = Utils(context).color;
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset(
              "assets/images/groceries.png",
            ),
          ),
          DrawerListTile(
            title: "Main",
            press: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainScreen(),
                ),
              );
            },
            icon: Icons.home_filled,
          ),
          DrawerListTile(
            title: "View all product",
            press: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const AllProductsScreen(),
              ));
            },
            icon: Icons.store,
          ),
          DrawerListTile(
            title: "View all order",
            press: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const AllOrdersScreen(),
              ));
            },
            icon: IconlyBold.bag_2,
          ),
          DrawerListTile(
            title: "Discount",
            press: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const DiscountScreen(),
              ));
            },
            icon: IconlyBold.discount,
          ),
          SwitchListTile(
              title: const Text('Theme'),
              secondary: Icon(themeState.getDarkTheme
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined),
              value: theme,
              onChanged: (value) {
                setState(() {
                  themeState.setDarkTheme = value;
                });
              })
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.press,
    required this.icon,
  }) : super(key: key);

  final String title;
  final VoidCallback press;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    final color = theme == true ? Colors.white : Colors.black;

    return ListTile(
        onTap: press,
        horizontalTitleGap: 0.0,
        leading: Icon(
          icon,
          size: 18,
        ),
        title: TextWidget(
          text: title,
          color: color,
        ));
  }
}
