# 🔥 Firestore Inline Queries for LUXE TIME App

## These queries can be used directly in Firebase Console or in your code

---

## 📦 PRODUCTS COLLECTION

### Add Product (Manual Entry)
```javascript
// Go to Firebase Console > Firestore > products collection > Add Document
{
  "name": "Rolex Submariner",
  "brand": "Rolex",
  "price": 8500.00,
  "images": ["assets/images/watches/rolex_sub.jpg"],
  "description": "Iconic luxury dive watch with exceptional craftsmanship",
  "specs": {
    "Movement": "Automatic",
    "Case Size": "40mm",
    "Water Resistance": "300m",
    "Material": "Stainless Steel"
  },
  "category": "Luxury",
  "isNew": true,
  "createdAt": "Firestore Timestamp"
}
```

### Get All Products
```javascript
db.collection('products').orderBy('createdAt', 'desc').get()
```

### Filter by Brand
```javascript
db.collection('products').where('brand', '==', 'Rolex').get()
```

### Filter by Category
```javascript
db.collection('products').where('category', '==', 'Luxury').get()
```

### Get New Arrivals
```javascript
db.collection('products').where('isNew', '==', true).get()
```

### Update Product
```javascript
db.collection('products').doc('PRODUCT_ID').update({
  "price": 9500.00,
  "isNew": false
})
```

### Delete Product
```javascript
db.collection('products').doc('PRODUCT_ID').delete()
```

---

## 👥 USERS COLLECTION

### Add User Manually
```javascript
// Go to Firebase Console > Firestore > users collection > Add Document
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "hashed_password_here",
  "phone": "+1234567890",
  "address": "123 Main St, City",
  "role": "user",  // or "admin"
  "createdAt": "Firestore Timestamp",
  "isActive": true
}
```

### Get All Users
```javascript
db.collection('users').orderBy('createdAt', 'desc').get()
```

### Find User by Email
```javascript
db.collection('users').where('email', '==', 'john@example.com').get()
```

### Update User Role to Admin
```javascript
db.collection('users').doc('USER_ID').update({
  "role": "admin"
})
```

### Disable User Account
```javascript
db.collection('users').doc('USER_ID').update({
  "isActive": false
})
```

### Delete User
```javascript
db.collection('users').doc('USER_ID').delete()
```

---

## 🛒 ORDERS COLLECTION

### Add Order
```javascript
// Go to Firebase Console > Firestore > orders collection > Add Document
{
  "userId": "USER_ID",
  "orderNumber": "LT1234567890",
  "items": [
    {
      "watchId": "WATCH_ID",
      "name": "Rolex Submariner",
      "quantity": 1,
      "price": 8500.00
    }
  ],
  "totalAmount": 8500.00,
  "shippingAddress": {
    "name": "John Doe",
    "phone": "+1234567890",
    "address": "123 Main St, City",
    "zipCode": "12345"
  },
  "paymentMethod": "Credit Card",
  "status": "pending",  // pending, confirmed, shipped, delivered, cancelled
  "createdAt": "Firestore Timestamp"
}
```

### Get User Orders
```javascript
db.collection('orders')
  .where('userId', '==', 'USER_ID')
  .orderBy('createdAt', 'desc')
  .get()
```

### Get All Orders (Admin)
```javascript
db.collection('orders').orderBy('createdAt', 'desc').get()
```

### Update Order Status
```javascript
db.collection('orders').doc('ORDER_ID').update({
  "status": "shipped"
})
```

### Get Pending Orders
```javascript
db.collection('orders').where('status', '==', 'pending').get()
```

---

## 📊 COUNT QUERIES (For Dashboard)

### Total Products Count
```javascript
db.collection('products').get().then(snapshot => {
  console.log('Total Products:', snapshot.size);
})
```

### Total Users Count
```javascript
db.collection('users').get().then(snapshot => {
  console.log('Total Users:', snapshot.size);
})
```

### Total Orders Count
```javascript
db.collection('orders').get().then(snapshot => {
  console.log('Total Orders:', snapshot.size);
})
```

### Revenue Calculation
```javascript
db.collection('orders')
  .where('status', '!=', 'cancelled')
  .get()
  .then(snapshot => {
    let totalRevenue = 0;
    snapshot.docs.forEach(doc => {
      totalRevenue += doc.data().totalAmount;
    });
    console.log('Total Revenue:', totalRevenue);
  })
```

---

## 🔐 SECURITY RULES

### Paste these in Firebase Console > Firestore > Rules tab

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check admin role
    function isAdmin() {
      return exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // PRODUCTS - Anyone can read, only admins can write
    match /products/{productId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null && isAdmin();
    }
    
    // USERS - Users can read their own, admins can read all
    match /users/{userId} {
      allow read: if request.auth != null && 
                   (request.auth.uid == userId || isAdmin());
      allow create: if true;
      allow update: if request.auth != null && 
                     (request.auth.uid == userId || isAdmin());
      allow delete: if request.auth != null && isAdmin();
    }
    
    // ORDERS - Users can only see their orders
    match /orders/{orderId} {
      allow read: if request.auth != null && 
                   (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if request.auth != null;
      allow update: if request.auth != null && isAdmin();
      allow delete: if request.auth != null && isAdmin();
    }
  }
}
```

---

## 💻 DART CODE FOR FIRESTORE

### Add Product from App
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addProduct(Map<String, dynamic> productData) async {
  await FirebaseFirestore.instance.collection('products').add({
    ...productData,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
```

### Get Products Stream (Real-time)
```dart
Stream<QuerySnapshot> getProductsStream() {
  return FirebaseFirestore.instance
      .collection('products')
      .orderBy('createdAt', descending: true)
      .snapshots();
}
```

### Login User
```dart
Future<Map<String, dynamic>?> loginUser(String email, String password) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: email)
      .where('password', isEqualTo: password)
      .get();
  
  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.first.data();
  }
  return null;
}
```

### Register User
```dart
Future<void> registerUser(Map<String, dynamic> userData) async {
  await FirebaseFirestore.instance.collection('users').add({
    ...userData,
    'createdAt': FieldValue.serverTimestamp(),
    'isActive': true,
  });
}
```

### Add Order
```dart
Future<String> addOrder(Map<String, dynamic> orderData) async {
  final docRef = await FirebaseFirestore.instance
      .collection('orders')
      .add({
    ...orderData,
    'createdAt': FieldValue.serverTimestamp(),
  });
  return docRef.id;
}
```

---

## 🚀 QUICK SETUP STEPS

### 1. Create Collections in Firebase Console:
- Go to https://console.firebase.google.com
- Select your project
- Go to Firestore Database
- Create collections: `products`, `users`, `orders`

### 2. Add Sample Data:
- Use the manual entry examples above
- Add at least 5-10 products
- Add 1 admin user

### 3. Set Security Rules:
- Copy the rules above
- Paste in Firestore Rules tab
- Click Publish

### 4. Test in App:
- Login with admin credentials
- Add products from admin panel
- Check if products appear on home screen

---

## 📝 NOTES

1. **Passwords**: Always hash passwords before storing (use bcrypt)
2. **Timestamps**: Use `FieldValue.serverTimestamp()` for automatic timestamps
3. **Images**: Store images in Firebase Storage, save URLs in Firestore
4. **Real-time**: Use `.snapshots()` for real-time updates
5. **Security**: Never expose admin operations to regular users

---

**Use these queries to manage your database directly!** 🔥
