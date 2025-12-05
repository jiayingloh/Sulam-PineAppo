// lib/model/marketplace_item.dart
class MarketplaceItem {
  final String type; // 'Product' or 'Pineapple Fruit'
  final int itemID; // ProID or VarietyID
  final String title;
  final String photo; // The photo path/URL from the API
  final double price;
  final String description;
  final String status; // Item availability status
  

  final int accID;
  final String fullName;
  final String businessName;
  final String location;
  final String ownType; // 'Farm', 'Industry', 'Shop'
  final String? phoneNo; // optional contact info
  final String? fbLink;

  MarketplaceItem({
    // Item Details
    required this.type,
    required this.itemID,
    required this.title,
    required this.photo,
    required this.price,
    required this.description,
    required this.status,

    required this.accID,
    required this.fullName,
    required this.businessName,
    required this.location,
    required this.ownType,
    this.phoneNo,
    this.fbLink,
  });

  // Factory to create from API JSON
  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    final item = json['item'] ?? {};
    final seller = json['seller'] ?? {};

    return MarketplaceItem(
      // Item Details (from the 'item' object)
      type: item['type'] ?? 'Unknown',
      itemID: (item['id'] is num) ? (item['id'] as num).toInt() : 0,
      title: item['title'] ?? 'No Title',
      photo: item['photo'] ?? '', // Retrieve the photo path
      price: (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0,
      description: item['description'] ?? 'No description provided.',
      status: item['status'] ?? 'N/A', // Retrieve the status
      
      // Seller Details (from the 'seller' object)
      accID: (seller['accID'] is num) ? (seller['accID'] as num).toInt() : 0,
      fullName: seller['fullName'] ?? 'N/A',
      businessName: seller['businessName'] ?? 'Unknown Seller',
      location: seller['location'] ?? 'N/A',
      ownType: seller['ownType'] ?? 'N/A',
      phoneNo: seller['phoneNo'], // This is nullable
      fbLink: seller['fbLink'],
    );
  }
}