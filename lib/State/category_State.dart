import 'package:jewellery/Model/category_Model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;

  CategoryLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);
}
