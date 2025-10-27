import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:sri_chandra_jewel/Event/product_Event.dart';
import 'package:sri_chandra_jewel/Model/product_Model.dart';
import 'package:sri_chandra_jewel/State/product_State.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<FetchProductEvent>(_onFetchProduct);
  }

  Future<void> _onFetchProduct(
    FetchProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      final response = await http.get(
        Uri.parse(
          'https://pheonixconstructions.com/mobile/productList.php?category_id=${event.categoryId}',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // ✅ Safe null-check (if storeList is missing/null → fallback to [])
        final List<dynamic> storeList = (jsonData['storeList'] ?? []) as List;

        final products =
            storeList.map((item) => ProductModel.fromJson(item)).toList();

        emit(ProductLoaded(products));
      } else {
        emit(ProductError('Failed to load products'));
      }
    } catch (e) {
      emit(ProductError('Error: ${e.toString()}'));
    }
  }
}
