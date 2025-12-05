import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/marketplace_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/session.dart';
import '../services/config.dart';

class MarketDetailPage extends StatefulWidget {
  final MarketplaceItem item;
  final String baseUrl = AppConfig.baseUrl;

  const MarketDetailPage({super.key, required this.item});

  @override
  State<MarketDetailPage> createState() => _MarketDetailPageState();
}

class _MarketDetailPageState extends State<MarketDetailPage> {
  bool _isSellerFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndInitialStatus();
  }

  // --- API/Auth Methods ---
  Future<void> _fetchUserDataAndInitialStatus() async {
    final currentAccID = CurrentUser.accID;
    final sellerAccID = widget.item.accID;

    if (currentAccID == null || currentAccID <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Must be logged in to use favorites.')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse(
      '${widget.baseUrl}/favourite.php?action=check&AccID=$currentAccID&FavAccID=$sellerAccID',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        String rawBody = response.body.trim();
        int jsonStart = rawBody.indexOf('{');
        int jsonEnd = rawBody.lastIndexOf('}');

        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          rawBody = rawBody.substring(jsonStart, jsonEnd + 1);
        } else {
          rawBody = '{"success": false, "message": "Failed to decode initial status."}';
        }

        final data = json.decode(rawBody);

        if (data['success'] == true) {
          setState(() {
            _isSellerFavorite = data['is_favorite'] ?? false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavoriteStatus() async {
    final currentAccID = CurrentUser.accID;
    final sellerAccID = widget.item.accID;

    if (currentAccID == null || currentAccID <= 0 || _isLoading) return;

    final newStatus = !_isSellerFavorite;
    final action = newStatus ? 'add' : 'remove';

    setState(() => _isSellerFavorite = newStatus);

    final uri = Uri.parse(
      '${widget.baseUrl}/favourite.php?action=$action&AccID=$currentAccID&FavAccID=$sellerAccID',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        String rawBody = response.body.trim();
        int jsonStart = rawBody.indexOf('{');
        int jsonEnd = rawBody.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          rawBody = rawBody.substring(jsonStart, jsonEnd + 1);
        } else {
          throw const FormatException("Invalid JSON structure after cleanup.");
        }

        final data = json.decode(rawBody);
        if (data['success'] != true) {
          setState(() => _isSellerFavorite = !newStatus);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${data['message']}')),
            );
          }
        }
      } else {
        setState(() => _isSellerFavorite = !newStatus);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server connection failed. Could not update favorite.')),
          );
        }
      }
    } catch (e) {
      setState(() => _isSellerFavorite = !newStatus);
      debugPrint('Error toggling favorite status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to perform action (Network Error).')),
        );
      }
    }
  }

  // --- Helper Methods ---
  String _getPriceUnit(MarketplaceItem item) {
    return item.type == 'Pineapple Fruit' ? '/kg' : '';
  }

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer.')),
        );
      }
    }
  }

  Future<void> _launchFacebook(String fbLink) async {
    final uri = Uri.parse(fbLink);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Facebook link.')),
        );
      }
    }
  }

  Widget _buildFacebookIcon(String fbLink) {
    return GestureDetector(
      onTap: () => _launchFacebook(fbLink),
      child: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 24),
    );
  }

  Widget _buildDetailRow(String label, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children, Widget? action}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                if (action != null) action,
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Image.asset('assets/images/PineWelcome.jpeg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final imageUrl = '${widget.baseUrl}/${item.photo}';
    final displayStatus = (item.status == 'N/A') ? 'In stock' : item.status;
    final isAvailable = displayStatus == 'Available' || displayStatus == 'In stock';
    final priceText = "RM ${item.price.toStringAsFixed(2)} ${_getPriceUnit(item)}";

    final priceStyle = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
    );

    List<Widget> sellerInfoChildren = [
      _buildDetailRow(
        "Business Name",
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: Text(item.businessName, style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Text(
                item.ownType,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade600),
              ),
            ),
          ],
        ),
      ),
      _buildDetailRow("Contact Person", Text(item.fullName)),
      _buildDetailRow("Location", Text(item.location, style: const TextStyle(color: Colors.blueGrey))),
    ];

    if (item.phoneNo != null && item.phoneNo!.isNotEmpty) {
      sellerInfoChildren.add(
        _buildDetailRow(
          "Contact No.",
          GestureDetector(
            onTap: () => _launchPhoneDialer(item.phoneNo!),
            child: Text(item.phoneNo!, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
          ),
        ),
      );
    }

    if (item.fbLink != null && item.fbLink!.isNotEmpty) {
      sellerInfoChildren.add(
        _buildDetailRow(
          "Facebook",
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _launchFacebook(item.fbLink!),
                  child: const Text('Visit Page', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                ),
              ),
              _buildFacebookIcon(item.fbLink!),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(''),
              background: _buildImageHeader(imageUrl),
            ),
            backgroundColor: const Color.fromARGB(255, 116, 231, 151),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(priceText, style: priceStyle),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              displayStatus,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        title: 'Product Details',
                        children: [
                          _buildDetailRow("Type", Text(item.type)),
                          _buildDetailRow("Description", Text(item.description)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        title: 'Seller Information',
                        action: _isLoading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : IconButton(
                                icon: Icon(_isSellerFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: _isSellerFavorite ? Colors.red : Colors.grey.shade600),
                                onPressed: _toggleFavoriteStatus,
                              ),
                        children: sellerInfoChildren,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
