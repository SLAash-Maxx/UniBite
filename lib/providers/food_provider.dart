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
  List<CanteenModel>   _canteens        = [];
  CanteenModel?        _featuredCanteen;
  CanteenModel?        _selectedCanteen; // FIX #8 - selected canteen
  String?              _selectedCategory;
  String               _searchQuery     = '';
  SortOption           _sortOption      = SortOption.popular;
  bool                 _isLoading       = false;
  bool                 _hasError        = false;

  List<CategoryModel> get categories       => _categories;
  List<CanteenModel>  get canteens         => _canteens;
  CanteenModel?       get featuredCanteen  => _featuredCanteen;
  CanteenModel?       get selectedCanteen  => _selectedCanteen;
  String?             get selectedCategoryId => _selectedCategory;
  String              get searchQuery      => _searchQuery;
  SortOption          get sortOption       => _sortOption;
  bool                get isLoading        => _isLoading;
  bool                get hasError         => _hasError;

  List<FoodItemModel> get featuredItems =>
      _allItems.where((f) => f.isFeatured).take(6).toList();

  List<FoodItemModel> get popularItems =>
      _allItems.where((f) => f.isPopular).take(8).toList();

  // FIX #7 - Filtering now works correctly
  List<FoodItemModel> get filteredItems {
    var items = [..._allItems];

    // Filter by selected canteen
    if (_selectedCanteen != null) {
      items = items.where((f) => f.canteenId == _selectedCanteen!.id).toList();
    }

    // Filter by category
    if (_selectedCategory != null && _selectedCategory != '0') {
      items = items.where((f) => f.categoryId == _selectedCategory).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((f) =>
        f.name.toLowerCase().contains(q) ||
        f.description.toLowerCase().contains(q) ||
        f.tags.any((t) => t.toLowerCase().contains(q))
      ).toList();
    }

    // Sort
    switch (_sortOption) {
      case SortOption.popular:
        items.sort((a, b) => b.reviewCount.compareTo(a.reviewCount)); break;
      case SortOption.priceLow:
        items.sort((a, b) => a.price.compareTo(b.price)); break;
      case SortOption.priceHigh:
        items.sort((a, b) => b.price.compareTo(a.price)); break;
      case SortOption.newest:
        break;
    }
    return items;
  }

  // Items grouped by canteen for shop screen
  Map<CanteenModel, List<FoodItemModel>> get itemsByCanteen {
    final map = <CanteenModel, List<FoodItemModel>>{};
    for (final canteen in _canteens) {
      final items = _allItems.where((f) => f.canteenId == canteen.id).toList();
      if (items.isNotEmpty) map[canteen] = items;
    }
    return map;
  }

  Future<void> loadHome() async {
    _isLoading = true; _hasError = false; notifyListeners();
    try {
      _canteens        = await _service.getAllCanteens();
      _featuredCanteen = _canteens.isNotEmpty ? _canteens.first : null;
      _categories      = await _service.getCategories();
      _allItems        = await _service.getMenuItems();
    } catch (_) { _hasError = true; }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> loadShop() async {
    _isLoading = true; _hasError = false; notifyListeners();
    try {
      _canteens   = await _service.getAllCanteens();
      _categories = await _service.getCategories();
      _allItems   = await _service.getMenuItems();
    } catch (_) { _hasError = true; }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> loadCanteenItems(String canteenId) async {
    _isLoading = true; notifyListeners();
    try {
      final items = await _service.getMenuItems(canteenId: canteenId);
      _allItems = items;
    } catch (_) {}
    finally { _isLoading = false; notifyListeners(); }
  }

  // FIX #8 - Canteen selection
  void selectCanteen(CanteenModel? canteen) {
    _selectedCanteen = canteen;
    _selectedCategory = null;
    notifyListeners();
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
