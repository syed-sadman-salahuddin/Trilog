import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});

  @override
  ConsumerState<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen> {
  final _descCtrl = TextEditingController();
  File? _selectedImage;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _post() async {
    if (_selectedImage == null && _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add an image or description')));
      return;
    }

    setState(() => _loading = true);
    final uid = ref.read(authServiceProvider).currentUid ?? '';

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await ref
            .read(storageServiceProvider)
            .uploadPostImage(_selectedImage!, uid);
      }

      final post = PostModel(
        postImage: imageUrl,
        postedBy: uid,
        postDescription: _descCtrl.text.trim(),
        postedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await ref.read(dbServiceProvider).addPost(post);

      if (mounted) {
        _descCtrl.clear();
        setState(() => _selectedImage = null);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Posted successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addStory() async {
    final uid = ref.read(authServiceProvider).currentUid;
    if (uid == null) return;
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    if (!mounted) return;

    setState(() => _loading = true);
    try {
      final url = await ref
          .read(storageServiceProvider)
          .uploadStoryImage(File(picked.path), uid);
      final story = UserStoriesModel(
          storyUrl: url, storyAt: DateTime.now().millisecondsSinceEpoch);
      await ref.read(dbServiceProvider).addStory(uid, story);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Story added!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final hasContent =
        _selectedImage != null || _descCtrl.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed:
                (_loading || !hasContent) ? null : _post,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('POST',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            userAsync.when(
              data: (user) => Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: user?.profile != null
                        ? CachedNetworkImageProvider(user!.profile!)
                        : null,
                    backgroundColor: AppTheme.shimmerBase,
                    child: user?.profile == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(user?.profession ?? '',
                          style: const TextStyle(
                              color: AppTheme.textGray, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              maxLines: 5,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
                fillColor: Colors.transparent,
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            const Divider(height: 32),
            Row(
              children: [
                _ActionChip(
                  icon: Icons.image_outlined,
                  label: 'Photo',
                  onTap: _pickImage,
                ),
                const SizedBox(width: 12),
                _ActionChip(
                  icon: Icons.auto_stories_outlined,
                  label: 'Story',
                  onTap: _addStory,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppTheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
