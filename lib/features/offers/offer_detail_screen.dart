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

  String _formatDiscount(dynamic pivot) {
    if (pivot == null) return '';
    double value = double.tryParse(pivot['discount_value'].toString()) ?? 0.0;
    String type = pivot['discount_type'] ?? 'percentage';

    if (type == 'percentage') {
      return '${value.toStringAsFixed(0)}% OFF';
    } else if (type == 'flat') {
      return 'PKR ${value.toStringAsFixed(0)} OFF';
    }
    return '${value.toStringAsFixed(0)}% OFF';
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
                  const SizedBox(height: 24),
                  // Categories
                  if (_offer['categories'] != null && (_offer['categories'] as List).isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (_offer['categories'] as List).map<Widget>((cat) => Chip(
                        label: Text(cat['name'], style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.indigo.withOpacity(0.05),
                        labelStyle: const TextStyle(color: Colors.indigo),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),

                  const SizedBox(height: 16),
                  const Text('About this offer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  Text(
                    _offer['description'] ?? 'No description available for this offer yet. Stay tuned for more details!',
                    style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.5),
                  ),

                  // Branches Section
                  if (_offer['branches'] != null && (_offer['branches'] as List).isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Available at Branches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('${(_offer['branches'] as List).length} Locations', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(_offer['branches'] as List).map((branch) => Container(
                       margin: const EdgeInsets.only(bottom: 8),
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(8)),
                       child: Row(
                         children: [
                           const Icon(Icons.store_mall_directory, color: Colors.grey, size: 20),
                           const SizedBox(width: 12),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(branch['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                 if (branch['location'] != null)
                                  Text(branch['location']['name'], style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                               ],
                             ),
                           ),
                           // If branch has override?
                           if (branch['pivot']?['discount_value'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  _formatDiscount(branch['pivot']),
                                  style: TextStyle(color: Colors.green[800], fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              )
                         ],
                       ),
                    )),
                  ],

                  const SizedBox(height: 32),
                  const Text('Applicable Cards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  if (_offer['cards'] != null && (_offer['cards'] as List).isNotEmpty)
                    ...(_offer['cards'] as List).map((card) {
                      String? overrideDiscount;
                      if (card['pivot'] != null && card['pivot']['discount_value'] != null) {
                        overrideDiscount = _formatDiscount(card['pivot']);
                      }

                      return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      color: Colors.grey[50],
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.credit_card, color: Colors.indigo),
                        ),
                        title: Text(card['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(card['bank']['name']),
                        trailing: overrideDiscount != null 
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red[100]!)),
                                child: Text(overrideDiscount, style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold)),
                              )
                            : null,
                      ),
                    );
                    }).toList()
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
