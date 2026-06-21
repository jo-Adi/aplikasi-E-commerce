part of 'home_cubit.dart';

enum HomeLoadStatus { initial, loading, loaded, error }

class HomeState {
  final int currentNavIndex;
  final String searchQuery;
  final String? selectedCategory;
  final String userName;
  final String userRole;
  final HomeLoadStatus loadStatus;
  final List<ProductModel> products;
  final String? errorMessage;

  const HomeState({
    this.currentNavIndex = 0,
    this.searchQuery = '',
    this.selectedCategory,
    this.userName = '',
    this.userRole = 'buyer',
    this.loadStatus = HomeLoadStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    int? currentNavIndex,
    String? searchQuery,
    String? selectedCategory,
    String? userName,
    String? userRole,
    HomeLoadStatus? loadStatus,
    List<ProductModel>? products,
    String? errorMessage,
    bool clearCategory = false,
  }) {
    return HomeState(
      currentNavIndex: currentNavIndex ?? this.currentNavIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
          clearCategory ? null : selectedCategory ?? this.selectedCategory,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      loadStatus: loadStatus ?? this.loadStatus,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Produk yang sudah difilter kategori + search — dipakai langsung di UI
  List<ProductModel> get filteredProducts {
    return products.where((p) {
      final matchCat =
          selectedCategory == null || p.category == selectedCategory;
      final matchSearch = searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.storeName.toLowerCase().contains(searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }
}
