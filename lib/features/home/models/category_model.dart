class CategoryModel {
  final String name;
  final String emoji;
  final String colorHex;

  const CategoryModel({
    required this.name,
    required this.emoji,
    required this.colorHex,
  });
}

/// Daftar kategori BinMart — Tahap 2 bisa diganti dari Firestore
const List<CategoryModel> binmartCategories = [
  CategoryModel(name: 'Kuliner',    emoji: '🍱', colorHex: 'FEF3C7'),
  CategoryModel(name: 'Buah',       emoji: '🍈', colorHex: 'ECFDF5'),
  CategoryModel(name: 'Fashion',    emoji: '👗', colorHex: 'FCE7F3'),
  CategoryModel(name: 'Sembako',    emoji: '🏪', colorHex: 'EFF6FF'),
  CategoryModel(name: 'Elektronik', emoji: '📱', colorHex: 'F5F3FF'),
  CategoryModel(name: 'Lainnya',    emoji: '🎁', colorHex: 'FFF7ED'),
];
