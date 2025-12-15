import 'package:flutter/material.dart';
import 'package:jar_talk/controllers/shelf_controller.dart';
import 'package:jar_talk/utils/app_theme.dart';

class CreateJarDialog extends StatefulWidget {
  final ShelfController controller;

  const CreateJarDialog({super.key, required this.controller});

  @override
  State<CreateJarDialog> createState() => _CreateJarDialogState();
}

class _CreateJarDialogState extends State<CreateJarDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = theme.extension<AppThemeExtension>()!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? appTheme.woodDark
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                'Create New Journal',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Noto Serif',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Give your new collection a name to get started.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: appTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Name Input
              TextField(
                controller: _textController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Journal Name',
                  hintText: 'e.g. "My Thoughts", "Travel 2024"',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.edit_note_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                onSubmitted: (_) => _createJar(),
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _createJar,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createJar() {
    if (_textController.text.isNotEmpty) {
      widget.controller.createJar(_textController.text);
      Navigator.pop(context);
    }
  }
}
