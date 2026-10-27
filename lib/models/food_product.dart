import 'menu_product.dart';

/// Turunan 1: makanan. Butuh waktu masak lebih lama dan punya level pedas.
class FoodProduct extends MenuProduct {
  FoodProduct({
    super.id,
    required super.name,
    required super.price,
    required super.category,
    required super.description,
    required super.art,
  });

  @override
  String get type => 'food';

  @override
  int get prepMinutes => 10;

  @override
  String get optionLabel => 'Level pedas';

  @override
  List<String> get options => const ['Tidak pedas', 'Sedang', 'Pedas'];

  factory FoodProduct.fromMap(Map<String, Object?> map) {
    return FoodProduct(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String,
      description: map['description'] as String,
      art: map['art'] as String,
    );
  }
}
