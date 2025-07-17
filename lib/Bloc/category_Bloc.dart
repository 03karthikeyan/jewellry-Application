import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:jewellery/Event/category_Event.dart';
import 'package:jewellery/Model/category_Model.dart';
import 'package:jewellery/State/category_State.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<FetchCategoryEvent>(_onFetchCategory);
  }

  Future<void> _onFetchCategory(
    FetchCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    try {
      final response = await http.get(
        Uri.parse('http://pheonixconstructions.com/mobile/categoryList.php'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> storeList = jsonData['storeList'];

        final banners =
            storeList.map((item) => CategoryModel.fromJson(item)).toList();

        emit(CategoryLoaded(banners));
      } else {
        emit(CategoryError('Failed to load Category'));
      }
    } catch (e) {
      emit(CategoryError('Error: ${e.toString()}'));
    }
  }
}
