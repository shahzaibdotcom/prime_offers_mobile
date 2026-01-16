import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../auth/auth_provider.dart';
import '../home/home_provider.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  bool _isProcessing = false;
  String? _selectedCardType;
  List<dynamic> _availableCards = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableCards();
  }

  Future<void> _loadAvailableCards() async {
    final api = ApiClient();
    final response = await api.client.get('/cards/available');
    setState(() {
      _availableCards = response.data;
    });
  }

  void _submit() async {
    if (_cardNumberController.text.length < 16) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid 16-digit card number')));
       return;
    }

    setState(() => _isProcessing = true);
    
    try {
      final api = ApiClient();
      final response = await api.client.post('/cards/activate', data: {
        'card_id': _selectedCardType,
        'card_number': _cardNumberController.text,
        'expiry_date': _expiryController.text,
      });

      if (mounted) {
         setState(() => _isProcessing = false);
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(response.data['message'])),
         );
         
         // Refresh global state
         ref.invalidate(homeSectionsProvider);
         ref.read(authProvider.notifier).refreshProfile();
         
         context.pop();
      }
    } catch (e) {
       setState(() => _isProcessing = false);
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment failed or card already added.')),
          );
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add & Activate Card')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Activate your card to unlock deals.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            DropdownButtonFormField<String>(
               decoration: const InputDecoration(labelText: 'Card Type / Bank', border: OutlineInputBorder()),
               items: _availableCards.map((c) => DropdownMenuItem(
                 value: c['id'].toString(), 
                 child: Text("${c['bank']['name']} - ${c['name']}")
                )).toList(),
               onChanged: (val) => setState(() => _selectedCardType = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cardNumberController,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
                hintText: '4242 4242 4242 4242'
              ),
              keyboardType: TextInputType.number,
              maxLength: 16,
            ),
            const SizedBox(height: 16),
            const Text(
              '🔒 Secure Transaction: PKR 10 will be charged from your card to verify and activate all discount offers.',
              style: TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isProcessing ? null : _submit,
                style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pay PKR 10 & Activate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
