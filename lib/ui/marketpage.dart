import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/marketplace_item.dart';
import 'marketdetail.dart';
import '../services/config.dart'; // Ensure AppConfig.baseUrl is defined here

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final String baseUrl = AppConfig.baseUrl;

  List<MarketplaceItem> _allProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  String selectedRegion = 'All';
  String selectedSort = 'None';
  String selectedType = 'All';
  String searchQuery = '';
  bool showFilter = false;

  final List<String> malaysiaRegions = [
    'All', 'Johor', 'Kedah', 'Kelantan', 'Kuala Lumpur', 'Labuan', 
    'Melaka', 'Negeri Sembilan', 'Pahang', 'Penang', 'Perak', 
    'Perlis', 'Putrajaya', 'Sabah', 'Sarawak', 'Selangor', 'Terengganu'
  ];

  final List<String> sortOptions = ['None', 'Price: Low to High', 'Price: High to Low'];
  final List<String> productTypes = ['All', 'Product', 'Pineapple Fruit'];

  @override
  void initState() {
    super.initState();
    _fetchMarketData();
  }

  Future<void> _fetchMarketData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('$baseUrl/marketplace.php');
      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] is List) {
          final rawData = data['data'] as List<dynamic>;
          setState(() {
            _allProducts = rawData
                .map((jsonItem) => MarketplaceItem.fromJson(jsonItem))
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to load data.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${resp.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching market data: $e');
      setState(() {
        _errorMessage = 'Network error or connection failed.';
        _isLoading = false;
      });
    }
  }

  List<MarketplaceItem> get _filteredProducts {
    List<MarketplaceItem> filtered = _allProducts;

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(query) ||
               item.description.toLowerCase().contains(query) ||
               item.businessName.toLowerCase().contains(query);
      }).toList();
    }

    if (selectedRegion != 'All') {
      filtered = filtered.where((item) => item.location == selectedRegion).toList();
    }

    if (selectedType != 'All') {
      filtered = filtered.where((item) => item.type == selectedType).toList();
    }

    if (selectedSort == 'Price: Low to High') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedSort == 'Price: High to Low') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return filtered;
  }

  String _getPriceUnit(MarketplaceItem item) {
    if (item.type == 'Variety') return '/kg';
    return '';
  }

  String _getImageUrl(String photoPath) {
    if (photoPath.isEmpty) return '';
    return '$baseUrl/$photoPath';
  }

  Widget _buildItemImage(String photoPath) {
    final imageUrl = _getImageUrl(photoPath);
    const double size = 80;
    const String fallbackAsset = 'assets/images/PineWelcome.jpeg'; 

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: size,
            height: size,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            fallbackAsset,
            width: size,
            height: size,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.asset(
        fallbackAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  @override
Widget build(BuildContext context) {
  final displayProducts = _filteredProducts;

  return Scaffold(
    body: Column(
      children: [
        _buildSearchAndFilter(),
        const SizedBox(height: 10),
        Expanded(child: _buildContent(displayProducts)),
      ],
    ),
  );
}


  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Search product...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.filter_alt),
                onPressed: () => setState(() => showFilter = !showFilter),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchMarketData,
              ),
            ],
          ),
          if (showFilter)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  _buildDropdown("Product Type", selectedType, productTypes, (val) => setState(() => selectedType = val!)),
                  const SizedBox(height: 8),
                  _buildDropdown("Location", selectedRegion, malaysiaRegions, (val) => setState(() => selectedRegion = val!)),
                  const SizedBox(height: 8),
                  _buildDropdown("Sort by", selectedSort, sortOptions, (val) => setState(() => selectedSort = val!)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      onChanged: onChanged,
    );
  }

  Widget _buildContent(List<MarketplaceItem> displayProducts) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text('Error: $_errorMessage'));
    if (displayProducts.isEmpty) return const Center(child: Text('No products found.'));

    return ListView.builder(
      itemCount: displayProducts.length,
      itemBuilder: (context, index) {
        final item = displayProducts[index];

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MarketDetailPage(item: item)),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withAlpha(51), blurRadius: 4, offset: const Offset(0,3))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildItemImage(item.photo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Text(item.type, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          ),
                          Flexible(
                            child: Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      Text('Sold by: ${item.businessName}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(item.description, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.blueGrey),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(item.location, style: const TextStyle(fontSize: 12, color: Colors.blueGrey), overflow: TextOverflow.ellipsis, maxLines: 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text("RM ${item.price.toStringAsFixed(2)} ${_getPriceUnit(item)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.green)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
