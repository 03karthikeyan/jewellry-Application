import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:jewellery/Event/banner_Event.dart';
import 'package:jewellery/Model/banner_Model.dart';
import 'package:jewellery/State/banner_State.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  BannerBloc() : super(BannerInitial()) {
    on<FetchBannerEvent>(_onFetchBanner);
  }

  Future<void> _onFetchBanner(
    FetchBannerEvent event,
    Emitter<BannerState> emit,
  ) async {
    emit(BannerLoading());

    try {
      final response = await http.get(
        Uri.parse('http://pheonixconstructions.com/mobile/bannerList.php'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> storeList = jsonData['storeList'];

        final banners =
            storeList.map((item) => BannerModel.fromJson(item)).toList();

        emit(BannerLoaded(banners));
      } else {
        emit(BannerError('Failed to load banners'));
      }
    } catch (e) {
      emit(BannerError('Error: ${e.toString()}'));
    }
  }
}
