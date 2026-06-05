import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/data/models/story.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';
import 'package:ta_discipline/features/stories/providers/story_provider.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';
import 'package:uuid/uuid.dart';

class StoryCreateScreen extends ConsumerStatefulWidget {
  const StoryCreateScreen({super.key});

  @override
  ConsumerState<StoryCreateScreen> createState() => _StoryCreateScreenState();
}

class _StoryCreateScreenState extends ConsumerState<StoryCreateScreen> {
  File? _imageFile;
  final _captionController = TextEditingController();
  Mood _selectedMood = Mood.neutral;
  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _publish() async {
    if (_imageFile == null) return;
    final userId = AppSupabase.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final story = Story(
        id: const Uuid().v4(),
        userId: userId,
        imageUrl: _imageFile!.path,
        caption: _captionController.text.trim(),
        mood: _selectedMood,
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );

      await ref.read(storyListProvider.notifier).createStory(story);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle story'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _publish,
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Publier',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _imageFile!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              GlassCard(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.textMuted,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Appareil photo'),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galerie'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            GlassCard(
              child: TextField(
                controller: _captionController,
                maxLines: 3,
                maxLength: 150,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Ajoute une légende...',
                  counterStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Humeur',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: Mood.values.map((mood) {
                  final isSelected = mood == _selectedMood;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.surface,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        '${mood.emoji} ${mood.label}',
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextButton.icon(
                  onPressed: () => setState(() => _imageFile = null),
                  icon: const Icon(Icons.refresh, color: AppColors.textMuted),
                  label: const Text(
                    'Changer la photo',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
