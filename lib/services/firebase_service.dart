// Firebase Service - Commented out for web compatibility
// Uncomment this file and Firebase dependencies when building for Android/iOS

// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/watch.dart';

// class FirebaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Get all watches from Firestore
//   Stream<List<Watch>> getWatches() {
//     return _firestore.collection('watches').snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return Watch.fromJson(doc.data() as Map<String, dynamic>);
//       }).toList();
//     });
//   }

//   // Get single watch by ID
//   Future<Watch?> getWatchById(String id) async {
//     try {
//       final doc = await _firestore.collection('watches').doc(id).get();
//       if (doc.exists) {
//         return Watch.fromJson(doc.data()!);
//       }
//       return null;
//     } catch (e) {
//       _logger.d('Error: ');
//       return null;
//     }
//   }

//   // Add new watch to Firestore
//   Future<void> addWatch(Watch watch) async {
//     try {
//       await _firestore.collection('watches').doc(watch.id).set(watch.toJson());
//     } catch (e) {
//       _logger.d('Error: ');
//     }
//   }

//   // Update watch in Firestore
//   Future<void> updateWatch(String id, Map<String, dynamic> data) async {
//     try {
//       await _firestore.collection('watches').doc(id).update(data);
//     } catch (e) {
//       _logger.d('Error: ');
//     }
//   }

//   // Delete watch from Firestore
//   Future<void> deleteWatch(String id) async {
//     try {
//       await _firestore.collection('watches').doc(id).delete();
//     } catch (e) {
//       _logger.d('Error: ');
//     }
//   }

//   // Get watches by brand
//   Stream<List<Watch>> getWatchesByBrand(String brand) {
//     return _firestore
//         .collection('watches')
//         .where('brand', isEqualTo: brand)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return Watch.fromJson(doc.data() as Map<String, dynamic>);
//       }).toList();
//     });
//   }

//   // Get new arrivals
//   Stream<List<Watch>> getNewArrivals() {
//     return _firestore
//         .collection('watches')
//         .where('isNew', isEqualTo: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return Watch.fromJson(doc.data() as Map<String, dynamic>);
//       }).toList();
//     });
//   }

//   // Search watches
//   Future<List<Watch>> searchWatches(String query) async {
//     try {
//       // Note: Firestore doesn't support full-text search natively
//       // This is a simple implementation. For production, use Algolia or ElasticSearch
//       final snapshot = await _firestore.collection('watches').get();
//       return snapshot.docs
//           .map((doc) => Watch.fromJson(doc.data()))
//           .where((watch) {
//         return watch.name.toLowerCase().contains(query.toLowerCase()) ||
//             watch.brand.toLowerCase().contains(query.toLowerCase()) ||
//             watch.category.toLowerCase().contains(query.toLowerCase());
//       }).toList();
//     } catch (e) {
//       _logger.d('Error: ');
//       return [];
//     }
//   }
// }
