import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import '../location/location_provider.dart';

class OffersScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  const OffersScreen({super.key, this.categoryId});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  List<dynamic> _offers = [];
  bool _isLoading = true;
  String? _selectedCategory;
  String? _selectedBank;
  bool _trendingFilter = false;
  bool _favoritesFilter = false;
  bool _yourCardsFilter = false;
  bool _featuredFilter = false;
  List<dynamic> _categories = [];
  List<dynamic> _banks = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryId;
    _fetchOffers();
    _fetchCategories();
    _fetchBanks();
  }

  Future<void> _fetchBanks() async {
    try {
      final api = ApiClient();
      final response = await api.client.get('/config');
      if (response.data['banks'] != null) {
        setState(() {
          _banks = response.data['banks'];
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchCategories() async {
    try {
      final api = ApiClient();
      final response = await api.client.get('/categories');
      setState(() => _categories = response.data);
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant OffersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId) {
      _selectedCategory = widget.categoryId;
      _fetchOffers();
    }
  }

  Future<void> _fetchOffers() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiClient();
      final selectedLocation = ref.read(selectedLocationProvider);
      final response = await api.client.get('/offers', queryParameters: {
        if (_selectedCategory != null) 'category_id': _selectedCategory,
        if (_selectedBank != null) 'bank_id': _selectedBank,
        if (selectedLocation != null) 'location_id': selectedLocation['id'].toString(),
        if (_trendingFilter) 'trending': '1',
        if (_featuredFilter) 'featured': '1',
        if (_yourCardsFilter) 'my_cards': '1',
      });
      setState(() {
        _offers = response.data['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to global location changes
    ref.listen(selectedLocationProvider, (previous, next) {
      if (previous != next) {
        _fetchOffers();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Offers', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 1. Horizontal Category Selector (Text with underline)
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildCategoryTab('All', null);
                }
                final cat = _categories[index - 1];
                return _buildCategoryTab(cat['name'], cat['id'].toString());
              },
            ),
          ),

          // 2. Filter Row (Scrolling Chips with Icons)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildToggleFilterChip('Trending', icon: Icons.trending_up, isActive: _trendingFilter, onTap: () {
                  setState(() { _trendingFilter = !_trendingFilter; _fetchOffers(); });
                }),
                _buildToggleFilterChip('Favorites', icon: Icons.favorite_border, isActive: _favoritesFilter, onTap: () {
                  setState(() { _favoritesFilter = !_favoritesFilter; _fetchOffers(); });
                }),
                _buildToggleFilterChip('Your Cards', icon: Icons.credit_card, isActive: _yourCardsFilter, onTap: () {
                  setState(() { _yourCardsFilter = !_yourCardsFilter; _fetchOffers(); });
                }),
                _buildToggleFilterChip('Featured', icon: Icons.sell_outlined, isActive: _featuredFilter, onTap: () {
                  setState(() { _featuredFilter = !_featuredFilter; _fetchOffers(); });
                }),
                
                // Bank Filter
                 _buildFilterChip(
                    _selectedBank != null 
                        ? 'Bank: ${_banks.firstWhere((b) => b['id'].toString() == _selectedBank, orElse: () => {'name': 'Selected'})['name']}' 
                        : 'Bank', 
                    icon: Icons.account_balance, 
                    hasDropdown: _selectedBank == null,
                    isActive: _selectedBank != null,
                    isRemovable: _selectedBank != null, 
                    onTap: () => _showBankSelector(),
                    onRemove: () {
                      setState(() { _selectedBank = null; _fetchOffers(); });
                    }
                 ),
              ],
            ),
          ),

          // 3. Offers Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _offers.isEmpty
                    ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _offers.length,
                      itemBuilder: (context, index) {
                        final offer = _offers[index];
                        return _buildOfferListCard(offer);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String label, String? id) {
    final isSelected = _selectedCategory == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = id;
          _fetchOffers();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: isSelected ? const Border(bottom: BorderSide(color: Color(0xFFC0392B), width: 3)) : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFC0392B) : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  void _showBankSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const Text('Select Bank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
               const SizedBox(height: 16),
               Container(
                 constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                 child: ListView.builder(
                   shrinkWrap: true,
                   itemCount: _banks.length,
                   itemBuilder: (context, index) {
                     final bank = _banks[index];
                     return ListTile(
                       title: Text(bank['name']),
                       onTap: () {
                         setState(() {
                           _selectedBank = bank['id'].toString();
                           _fetchOffers();
                         });
                         Navigator.pop(context);
                       },
                     );
                   },
                 ),
               )
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, {IconData? icon, bool hasDropdown = false, bool isRemovable = false, bool isActive = false, VoidCallback? onRemove, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.indigo.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? Colors.indigo : Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isActive ? Colors.indigo : Colors.grey[700]),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.indigo : Colors.black)),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
             Icon(Icons.keyboard_arrow_down, size: 16, color: isActive ? Colors.indigo : Colors.grey[700]),
          ],
          if (isRemovable) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 16, color: isActive ? Colors.indigo : Colors.grey[700]),
            ),
          ],
        ],
      ),
    ));
  }

  Widget _buildOfferListCard(dynamic offer) {
    return GestureDetector(
      onTap: () => context.push('/offer/${offer['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16/9,
                    child: Image.network(
                       ApiClient.getImageUrl(offer['image'] ?? offer['company']['cover_image'] ?? offer['company']['logo']),
                       fit: BoxFit.cover,
                       errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                    ),
                  ),
                ),
                // Featured Heart (Top Right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.favorite_border, color: Colors.grey[600], size: 20),
                  ),
                ),
                // Rating Badge (Bottom Left)
                 Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF66B93F), // Greenish
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                         const Text('3.8', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                         const SizedBox(width: 2),
                         const Icon(Icons.star, size: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                // Open Now (Bottom Right)
                 const Positioned(
                  bottom: 12,
                  right: 12,
                  child: Row(
                    children: [
                       Icon(Icons.access_time, color: Colors.white, size: 14),
                       SizedBox(width: 4),
                       Text('Open Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12, shadows: [Shadow(blurRadius: 2, color: Colors.black45, offset: Offset(0,1))])),
                    ],
                  ),
                ),
              ],
            ),
            
            // Bottom Content Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                   // Logo
                   Container(
                     width: 48,
                     height: 48,
                     decoration: BoxDecoration(
                       color: Colors.black,
                       borderRadius: BorderRadius.circular(8),
                       image: offer['company']['logo'] != null ? DecorationImage(
                         image: NetworkImage(ApiClient.getImageUrl(offer['company']['logo'])),
                         fit: BoxFit.cover,
                       ) : null
                     ),
                   ),
                   const SizedBox(width: 12),
                   // Text Info
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           offer['company']['name'],
                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                         ),
                         const SizedBox(height: 4),
                         // Categories
                         if (offer['categories'] != null && (offer['categories'] as List).isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: (offer['categories'] as List).take(3).map<Widget>((cat) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Text(
                                    cat['name'],
                                    style: TextStyle(color: Colors.grey[600], fontSize: 10,  fontWeight: FontWeight.w500),
                                  ),
                                )).toList(),
                              ),
                            )
                         else 
                           Text(
                             offer['category'] != null ? offer['category']['name'] : 'Mixed',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                           ),
                         const SizedBox(height: 4),
                         Text(
                           '${_getBranchText(offer)} • ${_getCardText(offer)}',
                           style: TextStyle(color: Colors.grey[500], fontSize: 11),
                         ),
                       ],
                     ),
                   ),
                   // Discount Badge
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                     decoration: const BoxDecoration(
                       color: Color(0xFF8B0000), // Dark Red
                       borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomRight: Radius.circular(12), topRight: Radius.circular(4), bottomLeft: Radius.circular(4)),
                     ),
                     child: Column(
                       children: [
                         Text('Up to', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 8)),
                         Text(_getDiscountText(offer), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                       ],
                     ),
                   )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No offers found', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildToggleFilterChip(String label, {required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? const Color(0xFF4F46E5) : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _getBranchText(dynamic offer) {
    final count = (offer['branches'] as List?)?.length ?? 1;
    return '$count Branch${count != 1 ? 'es' : ''}';
  }

  String _getCardText(dynamic offer) {
    final count = (offer['cards'] as List?)?.length ?? 0;
    return count > 0 ? '$count Card Offer${count != 1 ? 's' : ''}' : 'All Cards';
  }

  String _getDiscountText(dynamic offer) {
     double maxDiscount = double.tryParse(offer['discount_value'].toString()) ?? 0.0;
     String type = offer['discount_type'] ?? 'percentage';

     if (offer['cards'] != null) {
       for (var card in offer['cards']) {
         if (card['pivot'] != null && card['pivot']['discount_value'] != null) {
            double val = double.tryParse(card['pivot']['discount_value'].toString()) ?? 0.0;
            if (val > maxDiscount) {
              maxDiscount = val;
              type = card['pivot']['discount_type'] ?? type;
            }
         }
       }
     }
     
     if (type == 'percentage') {
       return '${maxDiscount.toStringAsFixed(0)}%';
     } else if (type == 'flat') {
       return 'PKR ${maxDiscount.toStringAsFixed(0)}';
     }
     return '${maxDiscount.toStringAsFixed(0)}%';
  }
}
