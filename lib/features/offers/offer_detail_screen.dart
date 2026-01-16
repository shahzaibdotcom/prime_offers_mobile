import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class OfferDetailScreen extends StatefulWidget {
  final String offerId;
  const OfferDetailScreen({super.key, required this.offerId});

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  dynamic _offer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOfferDetails();
  }

  Future<void> _fetchOfferDetails() async {
    try {
      final api = ApiClient();
      final response = await api.client.get('/offers/${widget.offerId}');
      setState(() {
        _offer = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_offer == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Offer not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _offer['company']['logo'] != null
                  ? Image.network(
                      ApiClient.getImageUrl(_offer['company']['logo']),
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.indigo),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                                _offer['company']['name'] ?? 'Merchant',
                                style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _offer['title'] ?? 'Exclusive Offer',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
                              ),
                           ],
                         ),
                       ),
                       Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Text(
                          '${_offer['discount_value']}% OFF',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('About this offer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  Text(
                    _offer['description'] ?? 'No description available for this offer yet. Stay tuned for more details!',
                    style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  const Text('Applicable Cards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  if (_offer['cards'] != null && (_offer['cards'] as List).isNotEmpty)
                    ...(_offer['cards'] as List).map((card) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.credit_card, color: Colors.indigo),
                        title: Text(card['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(card['bank']['name']),
                      ),
                    )).toList()
                  else
                    const Text('This offer is available for all registered cards.', style: TextStyle(color: Colors.grey)),
                  
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Redeem Offer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
