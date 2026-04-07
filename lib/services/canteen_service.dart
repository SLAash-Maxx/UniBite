import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/canteen_model.dart';
import '../models/category_model.dart';
import '../models/food_item_model.dart';

class CanteenService {
  final _db = FirebaseFirestore.instance;

  Future<CanteenModel> getCanteen() async {
    try {
      final doc = await _db
          .collection('canteen')
          .doc('main')
          .get()
          .timeout(const Duration(seconds: 10));

      if (!doc.exists) {
        // Return default if not seeded yet
        return const CanteenModel(
          id:          'main',
          name:        'Main Canteen',
          location:    'University Campus',
          rating:      4.5,
          reviewCount: 0,
          isOpen:      true,
          openTime:    '7:00 AM',
          closeTime:   '6:00 PM',
        );
      }

      return CanteenModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (_) {
      return const CanteenModel(
        id:          'main',
        name:        'Main Canteen',
        location:    'University Campus',
        rating:      4.5,
        reviewCount: 0,
        isOpen:      true,
        openTime:    '7:00 AM',
        closeTime:   '6:00 PM',
      );
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snap = await _db
          .collection('categories')
          .orderBy('name')
          .get()
          .timeout(const Duration(seconds: 10));

      final cats = snap.docs
          .map((d) => CategoryModel.fromJson({'id': d.id, ...d.data()}))
          .toList();

      if (cats.isEmpty) {
        // Return sample categories if none in Firestore
        return CategoryModel.defaults;
      }

      return [
        const CategoryModel(id: '0', name: 'All', itemCount: 0),
        ...cats,
      ];
    } catch (_) {
      return CategoryModel.defaults;
    }
  }

  Future<List<FoodItemModel>> getMenuItems({
    String? categoryId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db
          .collection('menuItems')
          .where('is_available', isEqualTo: true);

      if (categoryId != null && categoryId != '0') {
        query = query.where('category_id', isEqualTo: categoryId);
      }

      final snap = await query.get()
          .timeout(const Duration(seconds: 10));

      if (snap.docs.isEmpty) {
        // Return sample data if no items in Firestore
        return _getSampleMenuItems().where((item) {
          if (categoryId == null || categoryId == '0') return true;
          return item.categoryId == categoryId;
        }).toList();
      }

      return snap.docs
          .map((d) => FoodItemModel.fromJson({'id': d.id, ...d.data()}))
          .toList();
    } catch (_) {
      // Return sample data on error
      return _getSampleMenuItems().where((item) {
        if (categoryId == null || categoryId == '0') return true;
        return item.categoryId == categoryId;
      }).toList();
    }
  }

  List<FoodItemModel> _getSampleMenuItems() {
    return [
      FoodItemModel(
        id: '1',
        name: 'Chicken Fried Rice',
        description: 'Delicious fried rice with chicken and vegetables',
        price: 8.50,
        categoryId: '1',
        canteenId: 'main',
        rating: 4.5,
        reviewCount: 25,
        isAvailable: true,
        isFeatured: true,
        isPopular: true,
        tags: ['chicken', 'rice', 'spicy'],
        prepTimeMinutes: 15,
      ),
      FoodItemModel(
        id: '2',
        name: 'Beef Noodles',
        description: 'Traditional beef noodles soup',
        price: 7.00,
        categoryId: '2',
        canteenId: 'main',
        rating: 4.2,
        reviewCount: 18,
        isAvailable: true,
        isFeatured: false,
        isPopular: true,
        tags: ['beef', 'noodles', 'soup'],
        prepTimeMinutes: 12,
      ),
      FoodItemModel(
        id: '3',
        name: 'French Fries',
        description: 'Crispy golden french fries',
        price: 4.50,
        categoryId: '3',
        canteenId: 'main',
        rating: 4.0,
        reviewCount: 32,
        isAvailable: true,
        isFeatured: true,
        isPopular: false,
        tags: ['potato', 'crispy', 'snack'],
        prepTimeMinutes: 8,
      ),
      FoodItemModel(
        id: '4',
        name: 'Coca Cola',
        description: 'Refreshing cola drink',
        price: 2.50,
        categoryId: '4',
        canteenId: 'main',
        rating: 3.8,
        reviewCount: 45,
        isAvailable: true,
        isFeatured: false,
        isPopular: true,
        tags: ['cola', 'drink', 'cold'],
        prepTimeMinutes: 1,
      ),
      FoodItemModel(
        id: '5',
        name: 'Chocolate Cake',
        description: 'Rich chocolate cake with frosting',
        price: 5.00,
        categoryId: '5',
        canteenId: 'main',
        rating: 4.7,
        reviewCount: 15,
        isAvailable: true,
        isFeatured: true,
        isPopular: false,
        tags: ['chocolate', 'cake', 'sweet'],
        prepTimeMinutes: 5,
      ),
    ];
  }
}
