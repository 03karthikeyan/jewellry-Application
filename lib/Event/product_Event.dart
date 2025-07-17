abstract class ProductEvent {}

// class LoadProducts extends ProductEvent {
//   final String categoryId;
//   LoadProducts(this.categoryId);
// }

class FetchProductEvent extends ProductEvent {
  final String categoryId;
  FetchProductEvent(this.categoryId);
}
