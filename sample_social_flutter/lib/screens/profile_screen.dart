import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';
import 'login_screen.dart';
import 'requests_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final String? userId; 
  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final profileUid = userId ?? currentUser?.userId ?? '';
    final profileAsync = ref.watch(userByIdProvider(profileUid));
    final postsAsync = ref.watch(postsProvider);
    final isOwnProfile = userId == null || userId == currentUser?.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(profileAsync.valueOrNull?.name ?? 'Profile'),
        actions: isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.group_add_outlined),
                  tooltip: 'Follow Requests',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RequestsScreen())),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    }
                  },
                ),
              ]
            : null,
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('User not found'));
          }
          final userPosts = postsAsync.valueOrNull
                  ?.where((p) => p.postedBy == profileUid)
                  .toList() ??
              [];
          return NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverToBoxAdapter(
                child: _buildHeader(
                    context, ref, profile, isOwnProfile, currentUser?.userId ?? ''),
              ),
            ],
            body: userPosts.isEmpty
                ? const Center(
                    child: Text('No posts yet',
                        style: TextStyle(color: AppTheme.textGray)))
                : ListView.builder(
                    itemCount: userPosts.length,
                    itemBuilder: (_, i) => PostCard(post: userPosts[i]),
                  ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref,
      dynamic profile, bool isOwnProfile, String currentUid) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.7),
                    AppTheme.accent.withOpacity(0.7),
                  ],
                ),
                image: profile.coverPhoto != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(profile.coverPhoto!),
                        fit: BoxFit.cover)
                    : null,
              ),
            ),
            if (isOwnProfile)
              Positioned(
                right: 12,
                bottom: 8,
                child: _EditIconButton(
                  icon: Icons.camera_alt_outlined,
                  onTap: () => _pickAndUpload(context, ref, 'cover'),
                ),
              ),
            Positioned(
              bottom: -40,
              left: 20,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundImage: profile.profile != null
                          ? CachedNetworkImageProvider(profile.profile!)
                          : null,
                      backgroundColor: AppTheme.shimmerBase,
                      child: profile.profile == null
                          ? const Icon(Icons.person,
                              size: 44, color: Colors.white)
                          : null,
                    ),
                  ),
                  if (isOwnProfile)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: _EditIconButton(
                        icon: Icons.camera_alt_outlined,
                        onTap: () =>
                            _pickAndUpload(context, ref, 'profile'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 52),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(profile.profession,
                          style: const TextStyle(
                              color: AppTheme.textGray, fontSize: 14)),
                    ],
                  ),
                  if (!isOwnProfile)
                    _FollowButton(
                        currentUid: currentUid, targetUid: profile.userId ?? ''),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatChip(
                      count: profile.followerCount, label: 'Followers'),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: AppTheme.divider),
              const Text('Posts',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUpload(
      BuildContext context, WidgetRef ref, String type) async {
    final uid = ref.read(authServiceProvider).currentUid;
    if (uid == null) return;
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    if (!context.mounted) return;

    final storage = ref.read(storageServiceProvider);
    final db = ref.read(dbServiceProvider);
    final file = File(picked.path);
    try {
      final url = type == 'profile'
          ? await storage.uploadProfileImage(file, uid)
          : await storage.uploadCoverImage(file, uid);
      await db.updateUser(uid,
          type == 'profile' ? {'profile': url} : {'coverPhoto': url});
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }
}

class _FollowButton extends ConsumerWidget {
  final String currentUid;
  final String targetUid;
  const _FollowButton(
      {required this.currentUid, required this.targetUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowingAsync = ref.watch(
        isFollowingProvider((currentUid: currentUid, targetUid: targetUid)));
    return isFollowingAsync.when(
      data: (following) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: following ? Colors.white : AppTheme.primary,
          foregroundColor: following ? AppTheme.primary : Colors.white,
          side: following
              ? const BorderSide(color: AppTheme.primary)
              : BorderSide.none,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          elevation: 0,
        ),
        onPressed: () async {
          final db = ref.read(dbServiceProvider);
          if (following) {
            await db.unfollowUser(currentUid, targetUid);
          } else {
            await db.followUser(currentUid, targetUid);
          }
          ref.invalidate(isFollowingProvider);
        },
        child: Text(following ? 'Following' : 'Follow',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      loading: () => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  const _StatChip({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$count',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(color: AppTheme.textGray, fontSize: 14)),
      ],
    );
  }
}

class _EditIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _EditIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
