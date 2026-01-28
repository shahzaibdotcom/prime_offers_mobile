import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_client.dart';
import 'home_provider.dart';
import '../location/location_provider.dart';
import '../location/location_selector_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(homeSectionsProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const LocationSelectorDialog(),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 20, color: Color(0xFFC0392B)),
              const SizedBox(width: 4),
              Text(
                selectedLocation?['name'] ?? 'Select Location',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        foregroundColor: const Color(0xFF1F2937),
      ),
      body: sectionsAsync.when(
        data: (sections) => RefreshIndicator(
          onRefresh: () => ref.refresh(homeSectionsProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: sections.length,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final section = sections[index];
              return _buildSection(context, section);
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSection(BuildContext context, dynamic section) {
    final type = section['type'];
    final title = section['title'];
    final data = section['data'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        if (type == 'carousel' || type == 'horizontal_list')
          _buildHorizontalList(context, data)
        else if (type == 'my_cards')
          _buildMyCards(context, data)
        else if (type == 'grid')
          _buildGrid(context, data)
        else if (type == 'banner')
          _buildBanner(context, section)
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<dynamic> data) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return GestureDetector(
            onTap: () {
               if (item['action_type'] == 'offer') {
                 context.push('/offer/${item['action_value']}');
               }
            },
            child: Container(
              width: 300,
              margin: const EdgeInsets.only(right: 16, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      ApiClient.getImageUrl(item['image_url']),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to view details',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyCards(BuildContext context, List<dynamic> data) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final card = data[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6200EE), Color(0xFF3700B3)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(card['bank_name'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(card['card_number'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(card['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<dynamic> data) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return GestureDetector(
          onTap: () => context.push('/offers?category_id=${item['id']}'),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: item['icon'] != null
                      ? Image.network(
                          ApiClient.getImageUrl(item['icon']),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.category, color: Colors.indigo),
                        )
                      : const Icon(Icons.category, color: Colors.indigo),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['name'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBanner(BuildContext context, dynamic section) {
     final item = (section['data'] as List).first;
     return GestureDetector(
       onTap: () {
         if (item['action_type'] == 'add_card') {
           context.push('/add-card');
         }
       },
       child: Container(
         width: double.infinity,
         height: 120,
         margin: const EdgeInsets.symmetric(horizontal: 16),
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(16),
           color: Colors.indigo,
         ),
         child: Stack(
           fit: StackFit.expand,
           children: [
              if (item['image_url'] != null)
                Image.network(
                  ApiClient.getImageUrl(item['image_url']),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.credit_card, color: Colors.white, size: 40),
                ),
             Container(color: Colors.black26),
             Center(child: Text(item['title'] ?? 'Add Card', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center,)),
           ],
         ),
       ),
     );
  }
}
