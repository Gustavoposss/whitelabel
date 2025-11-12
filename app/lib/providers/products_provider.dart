import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductsProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  
  // Filters
  String? _nameFilter;
  String? _categoryFilter;
  String? _departmentFilter;
  double? _minPrice;
  double? _maxPrice;
  String? _providerFilter;
  
  // All products (before filtering)
  List<Product> _allProducts = [];

  ProductsProvider({required ApiService apiService}) : _apiService = apiService;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String? get nameFilter => _nameFilter;
  String? get categoryFilter => _categoryFilter;
  String? get departmentFilter => _departmentFilter;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get providerFilter => _providerFilter;

  // Get unique categories from all products (not filtered)
  List<String> get categories {
    final categoriesSet = <String>{};
    for (final product in _allProducts) {
      if (product.category != null && product.category!.isNotEmpty) {
        categoriesSet.add(product.category!);
      }
    }
    return categoriesSet.toList()..sort();
  }

  // Get unique departments from all products (not filtered)
  List<String> get departments {
    final departmentsSet = <String>{};
    for (final product in _allProducts) {
      if (product.departamento != null && product.departamento!.isNotEmpty) {
        departmentsSet.add(product.departamento!);
      }
    }
    return departmentsSet.toList()..sort();
  }

  // Get price range from all products (not filtered)
  double get minProductPrice {
    if (_allProducts.isEmpty) return 0;
    return _allProducts.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  }

  double get maxProductPrice {
    if (_allProducts.isEmpty) return 10000;
    return _allProducts.map((p) => p.price).reduce((a, b) => a > b ? a : b);
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allProducts = await _apiService.getProducts(
        name: _nameFilter,
        provider: _providerFilter,
      );
      
      _products = _applyFrontendFilters(_allProducts);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _products = [];
      _allProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> _applyFrontendFilters(List<Product> products) {
    var filtered = List<Product>.from(products);
    
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.category != null && p.category == _categoryFilter
      ).toList();
    }
    
    if (_departmentFilter != null && _departmentFilter!.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.departamento != null && p.departamento == _departmentFilter
      ).toList();
    }
    
    if (_minPrice != null) {
      filtered = filtered.where((p) => p.price >= _minPrice!).toList();
    }
    if (_maxPrice != null) {
      filtered = filtered.where((p) => p.price <= _maxPrice!).toList();
    }
    
    return filtered;
  }

  Future<Product?> getProductById(String id, {String? provider}) async {
    try {
      return await _apiService.getProductById(id, provider: provider);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void setFilters({
    String? name,
    String? category,
    String? department,
    double? minPrice,
    double? maxPrice,
    String? provider,
  }) {
    final apiFiltersChanged = 
        _nameFilter != name || _providerFilter != provider;
    
    _nameFilter = name;
    _categoryFilter = category;
    _departmentFilter = department;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _providerFilter = provider;
    
    if (apiFiltersChanged) {
      loadProducts();
    } else {
      _products = _applyFrontendFilters(_allProducts);
      notifyListeners();
    }
  }

  void clearFilters() {
    _nameFilter = null;
    _categoryFilter = null;
    _departmentFilter = null;
    _minPrice = null;
    _maxPrice = null;
    _providerFilter = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

