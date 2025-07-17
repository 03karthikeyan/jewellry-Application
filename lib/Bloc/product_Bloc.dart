import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:jewellery/Event/product_Event.dart';
import 'package:jewellery/Model/product_Model.dart';
import 'package:jewellery/State/product_State.dart';

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
        final List<dynamic> storeList = jsonData['storeList'];

        final products =
            storeList.map((item) => ProductModel.fromJson(item)).toList();

        emit(ProductLoaded(products));
      } else {
        emit(ProductError('Failed to load Product'));
      }
    } catch (e) {
      emit(ProductError('Error: ${e.toString()}'));
    }
  }
}
