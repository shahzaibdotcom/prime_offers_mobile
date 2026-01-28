import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_provider.dart';

class LocationSelectorDialog extends ConsumerStatefulWidget {
  const LocationSelectorDialog({super.key});

  @override
  ConsumerState<LocationSelectorDialog> createState() => _LocationSelectorDialogState();
}

class _LocationSelectorDialogState extends ConsumerState<LocationSelectorDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(locationsProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Location',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            locationsAsync.when(
              data: (locations) {
                // Show search only if more than 10 locations
                if (locations.length > 10) {
                  return Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                      const SizedBox(height: 16),
                      _buildLocationList(locations),
                    ],
                  );
                }
                return _buildLocationList(locations);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationList(List<dynamic> locations) {
    final filteredLocations = locations.where((loc) {
      if (_searchQuery.isEmpty) return true;
      return loc['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: filteredLocations.length,
        itemBuilder: (context, index) {
          final location = filteredLocations[index];
          final selectedLocation = ref.watch(selectedLocationProvider);
          final isSelected = selectedLocation?['id'] == location['id'];

          return ListTile(
            leading: Icon(
              Icons.location_on,
              color: isSelected ? const Color(0xFF4F46E5) : Colors.grey,
            ),
            title: Text(
              location['name'],
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF4F46E5) : Colors.black,
              ),
            ),
            trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF4F46E5)) : null,
            onTap: () {
              ref.read(selectedLocationProvider.notifier).selectLocation(location);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
