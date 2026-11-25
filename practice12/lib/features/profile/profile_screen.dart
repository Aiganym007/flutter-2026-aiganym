import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<XFile?> _pick(ImageSource source) =>
      _picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);

  Future<void> _choosePhoto() async {
    final picked = await _pick(ImageSource.gallery);
    await _save(picked);
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    switch (status) {
      case PermissionStatus.granted ||
          PermissionStatus.limited ||
          PermissionStatus.provisional:
        final picked = await _pick(ImageSource.camera);
        await _save(picked);
      case PermissionStatus.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The camera is needed only to take your profile photo. '
              'You can allow it next time, or choose a photo from the gallery.',
            ),
          ),
        );
      case PermissionStatus.restricted:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The camera is restricted on this device.'),
          ),
        );
      case PermissionStatus.permanentlyDenied:
        await _showSettingsDialog();
    }
  }

  Future<void> _showSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera is turned off'),
        content: const Text(
          'You blocked the camera for this app. To take a photo, allow '
          'Camera in the app settings. You can still choose a photo '
          'from the gallery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open ?? false) await openAppSettings();
  }

  Future<void> _save(XFile? picked) async {
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final saved = await File(picked.path).copy('${dir.path}/avatar.jpg');
    await FileImage(saved).evict();
    if (!mounted) return;
    await context.read<ProfileModel>().setAvatar(saved.path);
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<ProfileModel>().avatarPath;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 64,
                backgroundImage: path == null ? null : FileImage(File(path)),
                child: path == null
                    ? const Text('U', style: TextStyle(fontSize: 40))
                    : null,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _choosePhoto,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose photo'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Take photo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
