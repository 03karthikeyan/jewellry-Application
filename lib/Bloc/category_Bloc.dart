import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:sri_chandra_jewel/Event/category_Event.dart';
import 'package:sri_chandra_jewel/Model/category_Model.dart';
import 'package:sri_chandra_jewel/State/category_State.dart';


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
        Uri.parse('https://afosindia.com/mobile/categoryList.php'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> storeList = jsonData['storeList'];

        final categories =
            storeList.map((item) => CategoryModel.fromJson(item)).toList();

        emit(CategoryLoaded(categories));
      } else {
        emit(
          CategoryError(
            'Failed to load Category (Status: ${response.statusCode})',
          ),
        );
      }
    } catch (e) {
      emit(CategoryError('Error: ${e.toString()}'));
    }
  }
}
