import 'package:flutter/material.dart';
import '../models/food_item_model.dart';
import '../models/canteen_model.dart';
import '../models/category_model.dart';
import '../services/canteen_service.dart';
import '../screens/shop/widgets/sort_bottom_sheet.dart';

class FoodProvider extends ChangeNotifier {
  final CanteenService _service = CanteenService();

  List<FoodItemModel>  _allItems        = [];
  List<CategoryModel>  _categories      = CategoryModel.defaults;
  CanteenModel?        _featuredCanteen;
  String?              _selectedCategory;
  String               _searchQuery     = '';
  SortOption           _sortOption      = SortOption.popular;
  bool                 _isLoading       = false;
  bool                 _hasError        = false;

  // Getters
  List<CategoryModel> get categories       => _categories;
  CanteenModel?       get featuredCanteen  => _featuredCanteen;
  String?             get selectedCategoryId => _selectedCategory;
  String              get searchQuery      => _searchQuery;
  SortOption          get sortOption       => _sortOption;
  bool                get isLoading        => _isLoading;
  bool                get hasError         => _hasError;

  List<FoodItemModel> get featuredItems =>
      _allItems.where((f) => f.isFeatured).take(6).toList();

  List<FoodItemModel> get popularItems =>
      _allItems.where((f) => f.isPopular).take(8).toList();

  List<FoodItemModel> get filteredItems {
    var items = [..._allItems];

    // Category filter
    if (_selectedCategory != null && _selectedCategory != '0') {
      items = items
          .where((f) => f.categoryId == _selectedCategory)
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items
          .where((f) =>
              f.name.toLowerCase().contains(q) ||
              f.description.toLowerCase().contains(q) ||
              f.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }

    // Sort
    switch (_sortOption) {
      case SortOption.popular:
        items.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case SortOption.priceLow:
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHigh:
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.newest:
        break;
    }

    return items;
  }

  Future<void> loadHome() async {
    _isLoading = true;
    _hasError  = false;
    notifyListeners();
    try {
      _featuredCanteen = await _service.getCanteen();
      _categories      = await _service.getCategories();
      _allItems        = await _service.getMenuItems();
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadShop() async {
    _isLoading = true;
    _hasError  = false;
    notifyListeners();
    try {
      _categories = await _service.getCategories();
      _allItems   = await _service.getMenuItems();
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String id) {
    _selectedCategory = id;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(SortOption opt) {
    _sortOption = opt;
    notifyListeners();
  }
}
