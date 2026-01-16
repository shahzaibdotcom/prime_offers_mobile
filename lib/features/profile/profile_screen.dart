import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../../core/api_client.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user['name'] ?? '';
      _mobileController.text = user['mobile'] ?? '';
      _dobController.text = user['dob'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final api = ApiClient();
      final response = await api.client.post('/profile', data: {
        'name': _nameController.text,
        'mobile': _mobileController.text,
        'dob': _dobController.text,
      });
      
      ref.read(authProvider.notifier).updateUser(response.data['user']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isSaving = true);
      try {
        final api = ApiClient();
        String fileName = image.path.split('/').last;
        
        dio.FormData formData = dio.FormData.fromMap({
          "profile_picture": await dio.MultipartFile.fromFile(
            image.path, 
            filename: fileName,
            contentType: MediaType("image", "jpeg"),
          ),
        });

        final response = await api.client.post('/profile', data: formData);
        
        if (mounted) {
           ref.read(authProvider.notifier).updateUser(response.data['user']);
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.indigo[50],
                  backgroundImage: user['profile_picture'] != null 
                    ? NetworkImage(ApiClient.getImageUrl(user['profile_picture'])) 
                    : null,
                  child: user['profile_picture'] == null 
                    ? const Icon(Icons.person, size: 50, color: Colors.indigo) 
                    : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      backgroundColor: Colors.indigo,
                      radius: 18,
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: user['email']),
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), enabled: false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number', 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dobController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth', 
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _selectDate,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Terms & Conditions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
