import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jewellery/Bloc/banner_Bloc.dart';
import 'package:jewellery/Bloc/category_Bloc.dart';
import 'package:jewellery/Bloc/product_Bloc.dart';
import 'package:jewellery/Event/banner_Event.dart';
import 'package:jewellery/Event/category_Event.dart';
import 'package:jewellery/Event/product_Event.dart';
import 'package:jewellery/Screens/splash_screen.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BannerBloc()..add(FetchBannerEvent())),
        BlocProvider(create: (_) => CategoryBloc()..add(FetchCategoryEvent())),
        BlocProvider(create: (_) => ProductBloc()..add(FetchProductEvent(''))),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
