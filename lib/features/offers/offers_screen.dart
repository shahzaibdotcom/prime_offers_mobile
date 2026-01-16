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
  bool _openNowFilter = false;
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
      final response = await api.client.get('/config'); // Assuming config or a new /banks endpoint
      // Adjusting since we don't have /banks, maybe just fetch from configurations?
      // Actually, I'll just skip bank fetch if no endpoint exists, or assume /cards/available has banks
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
                _buildToggleFilterChip('Open Now', icon: Icons.access_time, isActive: _openNowFilter, onTap: () {
                  setState(() { _openNowFilter = !_openNowFilter; _fetchOffers(); });
                }),
                if (_selectedBank != null)
                  _buildFilterChip('Bank: ${_selectedBank == '1' ? 'HBL' : 'MCB'}', icon: Icons.account_balance, isRemovable: true, onRemove: () {
                    setState(() { _selectedBank = null; _fetchOffers(); });
                  }),
              ],
            ),
          ),

          // 3. Offers Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _offers.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _offers.length,
                        itemBuilder: (context, index) {
                          final offer = _offers[index];
                          return _buildOfferGridCard(offer);
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

  Widget _buildFilterChip(String label, {IconData? icon, bool hasDropdown = false, bool isRemovable = false, VoidCallback? onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 6),
          ],
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16),
          ],
          if (isRemovable) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOfferGridCard(dynamic offer) {
    return GestureDetector(
      onTap: () => context.push('/offer/${offer['id']}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Badges
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      ApiClient.getImageUrl(offer['company']['logo']), // Using logo as fallback or actual offer image
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[100]),
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Text('4.2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)), // Mocked rating
                          const SizedBox(width: 2),
                          Icon(Icons.star, color: Colors.yellow[700], size: 10),
                        ],
                      ),
                    ),
                  ),
                  // Open Now Badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white, size: 12),
                        const SizedBox(width: 2),
                        const Text('Open Now', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // Favorite Icon
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.favorite_border, color: Colors.grey, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: NetworkImage(ApiClient.getImageUrl(offer['company']['logo'])),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          offer['company']['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC0392B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            const Text('Up to', style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold)),
                            Text('${offer['discount_value']}%', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2 Branches • 5 Card Offers', // Mocked details
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                ],
              ),
            ),
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
}
