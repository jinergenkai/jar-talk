import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jar_talk/utils/app_theme.dart';

class JarCard extends StatelessWidget {
  final String label;
  final String subLabel;
  final int count;
  final bool isLocked;
  final Color? jarColor;
  final VoidCallback? onTap;

  const JarCard({
    super.key,
    required this.label,
    required this.subLabel,
    this.count = 0,
    this.isLocked = false,
    this.jarColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = theme.extension<AppThemeExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Badge
              if (!isLocked && count > 0)
                Positioned(
                  top: -8,
                  right: -4,
                  // zIndex removed, order dictates stacking
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.sticky_note_2,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Lock Icon
              if (isLocked)
                const Positioned(
                  top: 8,
                  right: 8,
                  // zIndex removed
                  child: Icon(Icons.lock, color: Colors.white54, size: 18),
                ),

              // Glass/Jar
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      if (!isLocked)
                        BoxShadow(
                          color: Colors.white.withOpacity(0.08),
                          blurRadius: 20,
                          spreadRadius: -2,
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Stack(
                      children: [
                        // Inner Shadow Gradient
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // The Jar SVG
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: SvgPicture.string(
                              _getJarSvg(
                                jarColor ?? theme.colorScheme.primary,
                                isLocked,
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.white70 : Colors.white,
              fontFamily: 'Noto Serif', // Ensure font is loaded or fallback
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subLabel,
            style: TextStyle(
              fontSize: 12,
              color: isLocked ? Colors.white30 : theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getJarSvg(Color color, bool locked) {
    // Generate palette for depth
    final colorBase = '#${color.value.toRadixString(16).substring(2)}';

    // Create lighter shades for the layered look (mimicking orange-300/400)
    final cLight = Color.lerp(color, Colors.white, 0.3) ?? color;
    final cLighter = Color.lerp(color, Colors.white, 0.5) ?? color;

    final colorMid = '#${cLight.value.toRadixString(16).substring(2)}';
    final colorLight = '#${cLighter.value.toRadixString(16).substring(2)}';

    if (locked) {
      // Archived Jar SVG Paths (Keep grayscale/muted logic)
      // ViewBox adjusted to zoom in and center
      return '''
<svg viewBox="15 35 70 100" fill="none" xmlns="http://www.w3.org/2000/svg">
<defs>
<linearGradient id="glass-grad-4" x1="0" x2="1" y1="0" y2="1">
<stop offset="0" stop-color="white" stop-opacity="0.05"></stop>
<stop offset="1" stop-color="white" stop-opacity="0.02"></stop>
</linearGradient>
<clipPath id="jar-clip-4">
<path d="M30 40 Q25 45 25 60 V115 Q25 130 50 130 Q75 130 75 115 V60 Q75 45 70 40 H30Z"></path>
</clipPath>
</defs>
<g clip-path="url(#jar-clip-4)">
<rect fill="rgba(0,0,0,0.3)" height="90" width="50" x="25" y="40"></rect>
<rect fill="#78716c" height="10" rx="1" transform="rotate(2 30 118)" width="40" x="30" y="118"></rect>
<rect fill="#57534e" height="10" rx="1" transform="rotate(-3 28 108)" width="42" x="28" y="108"></rect>
<rect fill="#a8a29e" height="10" rx="1" transform="rotate(1 32 98)" width="38" x="32" y="98"></rect>
</g>
<path d="M30 40 Q25 45 25 60 V115 Q25 130 50 130 Q75 130 75 115 V60 Q75 45 70 40 H30Z" fill="url(#glass-grad-4)" stroke="rgba(255,255,255,0.1)" stroke-width="1.5"></path>
<rect fill="#292524" height="10" rx="2" stroke="#1c1917" width="44" x="28" y="28"></rect>
<rect fill="#44403c" height="4" rx="1" width="48" x="26" y="36"></rect>
</svg>
''';
    }

    // Active Jar SVG Paths with restored Multi-tone
    return '''
<svg viewBox="15 35 70 100" fill="none" xmlns="http://www.w3.org/2000/svg">
<defs>
<linearGradient id="glass-grad-1" x1="0" x2="1" y1="0" y2="1">
<stop offset="0" stop-color="white" stop-opacity="0.15"></stop>
<stop offset="0.5" stop-color="white" stop-opacity="0"></stop>
<stop offset="1" stop-color="white" stop-opacity="0.1"></stop>
</linearGradient>
<clipPath id="jar-clip-1">
<path d="M30 40 Q25 45 25 60 V115 Q25 130 50 130 Q75 130 75 115 V60 Q75 45 70 40 H30Z"></path>
</clipPath>
</defs>
<g clip-path="url(#jar-clip-1)">
<rect fill="rgba(255,255,255,0.02)" height="90" width="50" x="25" y="40"></rect>
<rect fill="$colorBase" height="10" opacity="0.9" rx="1" transform="rotate(5 30 115)" width="38" x="30" y="115"></rect>
<rect fill="$colorMid" height="10" opacity="0.8" rx="1" transform="rotate(-3 32 105)" width="40" x="32" y="105"></rect>
<rect fill="$colorLight" height="10" opacity="0.9" rx="1" transform="rotate(2 28 95)" width="42" x="28" y="95"></rect>
<rect fill="$colorBase" height="10" opacity="0.85" rx="1" transform="rotate(-5 30 85)" width="36" x="30" y="85"></rect>
<rect fill="$colorMid" height="10" opacity="0.9" rx="1" transform="rotate(4 34 75)" width="38" x="34" y="75"></rect>
<rect fill="$colorLight" height="10" opacity="0.8" rx="1" transform="rotate(-2 28 65)" width="40" x="28" y="65"></rect>
<rect fill="$colorBase" height="10" opacity="0.9" rx="1" transform="rotate(6 30 55)" width="35" x="30" y="55"></rect>
</g>
<path d="M30 40 Q25 45 25 60 V115 Q25 130 50 130 Q75 130 75 115 V60 Q75 45 70 40 H30Z" fill="url(#glass-grad-1)" stroke="rgba(255,255,255,0.3)" stroke-width="1.5"></path>
<path d="M28 60 Q26 80 28 100" stroke="white" stroke-linecap="round" stroke-opacity="0.25" stroke-width="2"></path>
<path d="M72 60 Q74 80 72 100" stroke="white" stroke-linecap="round" stroke-opacity="0.25" stroke-width="2"></path>
<rect fill="#3e2b1d" height="10" rx="2" stroke="#1a120b" stroke-width="1" width="44" x="28" y="28"></rect>
<rect fill="#5c4033" height="4" rx="1" width="48" x="26" y="36"></rect>
</svg>
''';
  }
}
