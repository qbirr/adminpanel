import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useradmin/admin.dart';
import 'package:useradmin/user.dart';
import 'package:useradmin/controllers/menuscontrollers.dart';
import 'package:useradmin/inner_screen/add_product.dart';
import 'package:useradmin/login.dart';
import 'package:useradmin/login_widget.dart';
import 'package:useradmin/provider/dark_theme_provider.dart';
import 'package:useradmin/screen/main_screen.dart';


import 'consts/theme_data.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(  options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme()async{
    themeChangeProvider.setDarkTheme = 
    await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MenuController1(), 
          ),
          ChangeNotifierProvider(
            create: (_){
              return themeChangeProvider;
            })
      ],
      child: Consumer<DarkThemeProvider>(
        builder: (context, themeProvider , child){
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Toko Buah",
            theme: Styles.themeData(themeProvider.getDarkTheme, context),
            home: LoginScreen(),
            routes: {
              AdminScreen.routeName : (context) => AdminScreen(),
              HomeScreen.routeName : (context) => HomeScreen(),
              LoginForm.routeName : (context) => LoginForm(),
              UploadProductForm.routeName : (context) => const UploadProductForm()
            },
          );
        } ),
      );
  }
}
