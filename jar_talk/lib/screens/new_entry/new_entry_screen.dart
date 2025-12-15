import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/slip_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewEntryScreen extends StatefulWidget {
  final int jarId;
  final String controllerTag;

  const NewEntryScreen({
    super.key,
    required this.jarId,
    required this.controllerTag,
  });

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  XFile? _selectedImage;
  String? _selectedMood;
  final ImagePicker _picker = ImagePicker();

  final List<String> _emojis = [
    'angry_steam.gif',
    'cry_laugh.gif',
    'gentle_smile.gif',
    'gradient_calm.gif',
    'rock_sign_smile.gif',
    'soft_cry.gif',
    'tongue_out.gif',
    'x_eyes_dizzy_deadpan.gif',
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Blurs (Approximation of the design's background blobs)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: -40,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(
                    isDark ? 0.1 : 0.05,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.2,
              right: -40,
              child: Container(
                width: 192,
                height: 192,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(
                    isDark ? 0.2 : 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    child: _buildMainCard(context, theme, isDark),
                  ),
                ),
              ],
            ),

            // Floating "Drop Slip" Button
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(child: _buildDropSlipButton(theme)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
            ),
          ),
          Text(
            'NEW MEMORY',
            style: TextStyle(
              color: const Color(0xFFd47311), // Primary
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              fontFamily: 'Noto Serif',
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Paper Card
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2c241b) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                  offset: const Offset(0, 8),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                Image.file(
                                  File(_selectedImage!.path),
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Date Badge
                      Transform.rotate(
                        angle: -0.02,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(
                                isDark ? 0.5 : 0.3,
                              ),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'TODAY', // Dynamic date
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Prompt
                      TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontFamily: 'Noto Serif',
                          color: isDark
                              ? const Color(0xFFd4a276)
                              : const Color(0xFF9a734c),
                          fontSize: 24, // Larger for title
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Title (optional)',
                          hintStyle: TextStyle(
                            fontFamily: 'Noto Serif',
                            color:
                                (isDark
                                        ? const Color(0xFFd4a276)
                                        : const Color(0xFF9a734c))
                                    .withOpacity(0.6),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '"What is a small victory you had today?"',
                        style: TextStyle(
                          fontFamily: 'Noto Serif',
                          color: isDark
                              ? const Color(0xFFa8a29e) // Subtler color
                              : const Color(0xFF78716c),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.italic,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Text Input area (with simulated lines)
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 200),
                        child: CustomPaint(
                          painter: LinedPaperPainter(
                            color: isDark
                                ? const Color(0xFF443a30)
                                : const Color(0xFFe5e7eb),
                            lineHeight: 32.0,
                          ),
                          child: TextField(
                            controller: _textController,
                            maxLines: null,
                            style: TextStyle(
                              fontFamily: 'Noto Sans',
                              fontSize: 18,
                              height: 32.0 / 18.0, // Match line height
                              color: isDark
                                  ? const Color(0xFFe7e5e4)
                                  : const Color(0xFF1b140d),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Start writing here...',
                              hintStyle: TextStyle(
                                color: (isDark ? Colors.white : Colors.black)
                                    .withOpacity(0.2),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Toolbar (Attachments)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Toolbar Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1e1711)
                              : const Color(0xFFf3ede7),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (isDark)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              )
                            else
                              const BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2,
                              ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildAttachButton(
                                  Icons.image,
                                  isDark,
                                  () => _pickImage(ImageSource.gallery),
                                ),
                                const SizedBox(width: 8),
                                _buildAttachButton(
                                  Icons.photo_camera,
                                  isDark,
                                  () => _pickImage(ImageSource.camera),
                                ),
                                const SizedBox(width: 8),
                                _buildAttachButton(Icons.mic, isDark, () {}),
                                const SizedBox(width: 8),
                                _buildAttachButton(
                                  Icons.location_on,
                                  isDark,
                                  () {},
                                ),
                              ],
                            ),
                            // Hidden thumbnail placeholder
                          ],
                        ),
                      ),
                      // Paperclip Icon
                      Positioned(
                        top: -12,
                        left: 24,
                        child: Transform.rotate(
                          angle: 0.785, // 45 degrees
                          child: Icon(
                            Icons.attach_file,
                            size: 40,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // "How do you feel?" Sticky Note
          Positioned(top: -12, right: -8, child: _buildHowDoYouFeel(isDark)),
        ],
      ),
    );
  }

  void _showMoodSelector(bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        int initialPage = 0;
        if (_selectedMood != null) {
          initialPage = _emojis.indexOf(_selectedMood!);
          if (initialPage == -1) initialPage = 0;
        }

        final PageController pageController = PageController(
          viewportFraction: 0.5,
          initialPage: initialPage,
        );

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1c1917)
                      : const Color(0xFFfafaf9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF44403c)
                        : const Color(0xFFd6d3d1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      "Select your vibe",
                      style: TextStyle(
                        fontFamily: 'Noto Serif',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFd4a276)
                            : const Color(0xFF9a734c),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: _emojis.length,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedMood = _emojis[index];
                          });
                        },
                        itemBuilder: (context, index) {
                          final emoji = _emojis[index];
                          return AnimatedBuilder(
                            animation: pageController,
                            builder: (context, child) {
                              double value = 1.0;
                              if (pageController.position.haveDimensions) {
                                value = pageController.page! - index;
                                value = (1 - (value.abs() * 0.5)).clamp(
                                  0.5,
                                  1.0,
                                );
                              } else {
                                value = (index == initialPage) ? 1.0 : 0.5;
                              }

                              return Center(
                                child: Transform.scale(
                                  scale: value,
                                  child: Opacity(opacity: value, child: child),
                                ),
                              );
                            },
                            child: Image.asset(
                              'assets/emoji/$emoji',
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Done",
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFa8a29e)
                              : const Color(0xFF78716c),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHowDoYouFeel(bool isDark) {
    return GestureDetector(
      onTap: () => _showMoodSelector(isDark),
      child: Transform.rotate(
        angle: 0.05,
        child: Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFFca8a04) : const Color(0xFFfef9c3),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              topRight: Radius.circular(8),
              topLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedMood != null)
                Image.asset(
                  'assets/emoji/$_selectedMood',
                  height: 48,
                  width: 48,
                  fit: BoxFit.contain,
                )
              else
                Icon(
                  Icons.sentiment_satisfied,
                  size: 32,
                  color: (isDark ? Colors.yellow[100] : Colors.yellow[900])!
                      .withOpacity(0.7),
                ),
              const SizedBox(height: 4),
              Text(
                'How do you feel?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                  color: isDark ? Colors.yellow[100] : Colors.yellow[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachButton(IconData icon, bool isDark, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: isDark ? const Color(0xFFa87f56) : const Color(0xFF9a734c),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildDropSlipButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.4),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            if (_textController.text.isEmpty) return;

            final controller = Get.find<SlipController>(
              tag: widget.controllerTag,
            );
            final success = await controller.createSlip(
              _textController.text,
              title: _titleController.text.isNotEmpty
                  ? _titleController.text
                  : null,
              emotion: _selectedMood,
              imageFile: _selectedImage,
            );

            if (success) {
              if (context.mounted) Navigator.pop(context);
            } else {
              Get.snackbar("Error", "Failed to create slip");
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 32, 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Drop Slip',
                  style: TextStyle(
                    fontFamily: 'Noto Serif',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LinedPaperPainter extends CustomPainter {
  final Color color;
  final double lineHeight;

  LinedPaperPainter({required this.color, required this.lineHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    for (double y = lineHeight; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant LinedPaperPainter oldDelegate) {
    return color != oldDelegate.color || lineHeight != oldDelegate.lineHeight;
  }
}
