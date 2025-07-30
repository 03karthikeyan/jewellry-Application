abstract class ProductDetailsEvent {}

class FetchProductDetails extends ProductDetailsEvent {
  final String productId;
  FetchProductDetails(this.productId);
}
