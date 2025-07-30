import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:jewellery/Event/product_details_event.dart';
import 'package:jewellery/Model/product_details_model.dart';
import 'package:jewellery/State/product_details_state.dart';

class ProductDetailsBloc
    extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  ProductDetailsBloc() : super(ProductDetailsInitial());

  @override
  Stream<ProductDetailsState> mapEventToState(
    ProductDetailsEvent event,
  ) async* {
    if (event is FetchProductDetails) {
      yield ProductDetailsLoading();
      try {
        final response = await http.get(
          Uri.parse(
            'https://pheonixconstructions.com/mobile/productDetails.php?product_id=${event.productId}',
          ),
        );
        final data = jsonDecode(response.body);
        print("Response body: ${response.body}");
        print("Response body: ${response.statusCode}");

        if (data['result'] == 'Success' && data['Product_Details'].isNotEmpty) {
          final detail = ProductDetail.fromJson(data['Product_Details'][0]);
          yield ProductDetailsLoaded(detail);
        } else {
          yield ProductDetailsError("No product details found");
        }
      } catch (e) {
        yield ProductDetailsError("Error fetching product details: $e");
      }
    }
  }
}
