import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sri_chandra_jewel/Bloc/banner_Bloc.dart';
import 'package:sri_chandra_jewel/Bloc/category_Bloc.dart';
import 'package:sri_chandra_jewel/Bloc/product_Bloc.dart';
import 'package:sri_chandra_jewel/Bloc/product_details_bloc.dart';
import 'package:sri_chandra_jewel/Bloc/profile_bloc.dart';

import 'package:sri_chandra_jewel/Event/banner_Event.dart';
import 'package:sri_chandra_jewel/Event/category_Event.dart';
import 'package:sri_chandra_jewel/Event/product_Event.dart';
import 'package:sri_chandra_jewel/Event/product_details_event.dart';
import 'package:sri_chandra_jewel/Event/profile_event.dart';
import 'package:sri_chandra_jewel/Screens/splash_screen.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BannerBloc()..add(FetchBannerEvent())),
        BlocProvider(create: (_) => CategoryBloc()..add(FetchCategoryEvent())),
        BlocProvider(create: (_) => ProductBloc()..add(FetchProductEvent(''))),
        BlocProvider(create: (_) => ProfileBloc()..add(FetchProfile(''))),
        BlocProvider(
          create: (_) => ProductDetailsBloc()..add(FetchProductDetails('')),
        ),
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
