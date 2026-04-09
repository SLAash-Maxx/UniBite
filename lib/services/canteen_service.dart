import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/canteen_model.dart';
import '../models/category_model.dart';
import '../models/food_item_model.dart';

class CanteenService {
  final _db = FirebaseFirestore.instance;

  Future<List<CanteenModel>> getAllCanteens() async {
    try {
      final snap = await _db.collection('canteens').get();
      if (snap.docs.isEmpty) return _defaultCanteens();
      return snap.docs.map((d) => CanteenModel.fromJson({'id': d.id, ...d.data()})).toList();
    } catch (_) { return _defaultCanteens(); }
  }

  /// Automatically safely seed the firestore on startup to fill any missing database fields
  Future<void> initializeDatabaseMissingFields() async {
    for (final fallback in _defaultCanteens()) {
      try {
        final docRef = _db.collection('canteens').doc(fallback.id);
        final snapshot = await docRef.get();
        if (!snapshot.exists) {
          await docRef.set(fallback.toJson());
        } else {
          final data = snapshot.data() as Map<String, dynamic>;
          bool needsUpdate = false;
          final mergedData = Map<String, dynamic>.from(data);
          final fallbackJson = fallback.toJson();
          
          for (final key in fallbackJson.keys) {
            if (!data.containsKey(key) || data[key] == null) {
              mergedData[key] = fallbackJson[key];
              needsUpdate = true;
            }
          }
          if (needsUpdate) {
            await docRef.update(mergedData);
          }
        }
      } catch (_) {}
    }
  }

  Stream<List<CanteenModel>> watchAllCanteens() {
    return _db.collection('canteens').snapshots().map((snap) {
      if (snap.docs.isEmpty) return _defaultCanteens();
      return snap.docs.map((d) => CanteenModel.fromJson({'id': d.id, ...d.data()})).toList();
    });
  }

  Future<CanteenModel> getCanteen({String canteenId = 'ps'}) async {
    try {
      final doc = await _db.collection('canteens').doc(canteenId).get();
      if (!doc.exists) return _defaultCanteens().first;
      return CanteenModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (_) { return _defaultCanteens().first; }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snap = await _db.collection('categories').get();
      final cats = snap.docs.map((d) => CategoryModel.fromJson({'id': d.id, ...d.data()})).toList();
      if (cats.isEmpty) return CategoryModel.defaults;
      return [const CategoryModel(id: '0', name: 'All', itemCount: 0), ...cats];
    } catch (_) { return CategoryModel.defaults; }
  }

  Future<List<FoodItemModel>> getMenuItems({String? categoryId, String? canteenId}) async {
    try {
      Query<Map<String, dynamic>> query = _db.collection('menuItems').where('is_available', isEqualTo: true);
      if (canteenId != null && canteenId != 'all') query = query.where('canteen_id', isEqualTo: canteenId);
      if (categoryId != null && categoryId != '0') query = query.where('category_id', isEqualTo: categoryId);
      final snap = await query.get();
      if (snap.docs.isEmpty) return _sampleItems(canteenId: canteenId);
      return snap.docs.map((d) => FoodItemModel.fromJson({'id': d.id, ...d.data()})).toList();
    } catch (_) { return _sampleItems(canteenId: canteenId); }
  }

  Future<FoodItemModel?> getFoodItem(String id) async {
    try {
      final doc = await _db.collection('menuItems').doc(id).get();
      if (!doc.exists) return null;
      return FoodItemModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (_) { return null; }
  }

  List<CanteenModel> _defaultCanteens() => const [
    CanteenModel(id:'p&s', name:'P&S Canteen', location:'Near Auditorium', rating:4.5, reviewCount:120, isOpen:true, openTime:'7:00 AM', closeTime:'5:00 PM'),
    CanteenModel(id:'finagle', name:'Finagle', location:'FOC,L1 Floor', rating:4.3, reviewCount:89, isOpen:true, openTime:'8:00 AM', closeTime:'6:00 PM'),
    CanteenModel(id:'barista', name:'Barista', location:'Student Center', rating:4.6, reviewCount:200, isOpen:true, openTime:'7:30 AM', closeTime:'7:00 PM'),
    CanteenModel(id:'rasavimana', name:'Rasavimana', location:'Hostel Canteen', rating:4.4, reviewCount:75, isOpen:false, openTime:'8:00 AM', closeTime:'4:00 PM'),
  ];

  List<FoodItemModel> _sampleItems({String? canteenId}) => [
    FoodItemModel(id:'1', name:'Rice & Curry', description:'Traditional Sri Lankan rice with 3 curries and papadams', price:350, categoryId:'1', canteenId:canteenId??'p&s', rating:4.8, reviewCount:45, isAvailable:true, isFeatured:true, isPopular:true, tags:['rice','local'], prepTimeMinutes:10),
    FoodItemModel(id:'2', name:'Fried Rice', description:'Egg fried rice with mixed vegetables and soy sauce', price:280, categoryId:'1', canteenId:canteenId??'p&s', rating:4.6, reviewCount:32, isAvailable:true, isFeatured:true, isPopular:true, tags:['rice','fried'], prepTimeMinutes:8),
    FoodItemModel(id:'3', name:'Kottu Roti', description:'Sri Lankan street food - roti chopped with vegetables and egg', price:320, categoryId:'2', canteenId:canteenId??'finagle', rating:4.7, reviewCount:60, isAvailable:true, isFeatured:true, isPopular:true, tags:['kottu','roti'], prepTimeMinutes:12),
    FoodItemModel(id:'4', name:'Cappuccino', description:'Rich espresso with steamed milk foam', price:450, categoryId:'4', canteenId:canteenId??'barista', rating:4.9, reviewCount:150, isAvailable:true, isFeatured:true, isPopular:true, tags:['coffee','hot'], prepTimeMinutes:5),
    FoodItemModel(id:'5', name:'Short Eats Combo', description:'3 short eats - cutlet, patties and Chinese roll', price:180, categoryId:'3', canteenId:canteenId??'p&s', rating:4.4, reviewCount:28, isAvailable:true, isFeatured:false, isPopular:true, tags:['snacks','combo'], prepTimeMinutes:5),
    FoodItemModel(id:'6', name:'Noodles Soup', description:'Hot noodle soup with chicken and vegetables', price:250, categoryId:'2', canteenId:canteenId??'rasavimana', rating:4.3, reviewCount:19, isAvailable:true, isFeatured:false, isPopular:false, tags:['noodles','soup'], prepTimeMinutes:10),
  ];
}
