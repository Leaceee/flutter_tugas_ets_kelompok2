import 'menu_product.dart';

/// Turunan 2: minuman. Cepat disiapkan dan punya pilihan suhu.
class DrinkProduct extends MenuProduct {
  DrinkProduct({
    super.id,
    required super.name,
    required super.price,
    required super.category,
    required super.description,
    required super.art,
  });

  @override
  String get type => 'drink';

  @override
  int get prepMinutes => 3;

  @override
  String get optionLabel => 'Suhu';

  @override
  List<String> get options => const ['Dingin', 'Hangat'];

  factory DrinkProduct.fromMap(Map<String, Object?> map) {
    return DrinkProduct(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String,
      description: map['description'] as String,
      art: map['art'] as String,
    );
  }
}
