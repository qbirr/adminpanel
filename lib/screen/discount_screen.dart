import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useradmin/screen/discount_component.dart';

import '../controllers/menuscontrollers.dart';
import '../responsive.dart';
import '../widgets/side_menu.dart';

class DiscountScreen extends StatelessWidget {
  const DiscountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuController1>().getDiscountKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: DiscountComponent(),
            ),
          ],
        ),
      ),
    );
  }
}
