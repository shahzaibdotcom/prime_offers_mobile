import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';

class MyCardsScreen extends ConsumerStatefulWidget {
  const MyCardsScreen({super.key});

  @override
  ConsumerState<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends ConsumerState<MyCardsScreen> {
  List<dynamic> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyCards();
  }

  Future<void> _fetchMyCards() async {
    try {
      final api = ApiClient();
      final response = await api.client.get('/cards/my-cards');
      setState(() {
        _cards = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/add-card'),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No cards added yet', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.push('/add-card'),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Your First Card'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return _buildCardItem(card);
                  },
                ),
    );
  }

  Widget _buildCardItem(dynamic card) {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _hexToColor(card['bank']['primary_color'] ?? '#4f46e5'),
            _hexToColor(card['bank']['primary_color'] ?? '#4f46e5').withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _hexToColor(card['bank']['primary_color'] ?? '#4f46e5').withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.credit_card,
              size: 150,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card['bank']['name'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    if (card['image'] != null)
                      Image.network(
                        ApiClient.getImageUrl(card['image']),
                        height: 30,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                  ],
                ),
                Text(
                  card['pivot']['card_number_masked'] ?? '**** **** **** ****',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 4,
                    fontFamily: 'Courier',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ACTIVE',
                      style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      card['name'],
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
