import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/screens/shelf/widgets/jar_card.dart';
import 'package:jar_talk/utils/app_theme.dart';
import 'package:jar_talk/screens/journal_view/journal_view_screen.dart';

class ShelfController extends GetxController {
  final RxList<Map<String, dynamic>> activeJars = <Map<String, dynamic>>[
    {
      'label': 'Family Notes',
      'subLabel': 'Glowing • Updated 2m ago',
      'count': 3,
      'color': const Color(0xFFD47311),
    },
    {
      'label': 'Partner',
      'subLabel': 'Obverflowing',
      'count': 5,
      'color': const Color(0xFFD47311),
    },
    {
      'label': 'Travel Plans',
      'subLabel': '1 new slip',
      'count': 1,
      'color': const Color(0xFFD47311),
    },
  ].obs;

  final RxList<Map<String, dynamic>> archivedJars = <Map<String, dynamic>>[
    {'label': '2023 Memories', 'subLabel': 'Sealed • Dec 31', 'count': 0},
    {'label': 'Old Friends', 'subLabel': 'Sealed • Nov 20', 'count': 0},
  ].obs;
}

class ShelfScreen extends StatelessWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShelfController());
    final theme = Theme.of(context);
    final appTheme = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.95),
            floating: true,
            pinned: true,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: Colors.white.withOpacity(0.05),
                height: 1,
              ),
            ),
            title: Text(
              'The Collection',
              style: TextStyle(
                fontFamily: 'Noto Serif',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : appTheme.woodLight,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add, color: theme.colorScheme.primary),
                    onPressed: () {
                      // Navigate to create jar
                    },
                  ),
                ),
              ),
            ],
          ),

          // content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Recent Jars Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Jars',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.9)
                              : appTheme.woodLight,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '${controller.activeJars.length} ACTIVE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Recent Jars Grid Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: appTheme.woodDark.withOpacity(0.3),
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 16,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Obx(() {
                          final width = MediaQuery.of(context).size.width;
                          final int crossAxisCount = width < 600 ? 2 : 3;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 32,
                                  childAspectRatio:
                                      0.5, // Even taller for jars to fix overflow
                                ),
                            itemCount: controller.activeJars.length,
                            itemBuilder: (context, index) {
                              final jar = controller.activeJars[index];
                              return JarCard(
                                label: jar['label'],
                                subLabel: jar['subLabel'],
                                count: jar['count'],
                                jarColor: jar['color'],
                                isLocked: false,
                                onTap: () {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const JournalViewScreen(
                                            jarId: 0,
                                            jarName: "",
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Archived Jars Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Archived Jars',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.9)
                              : appTheme.woodLight,
                        ),
                      ),
                      Text(
                        'SEALED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Archived Jars Grid Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: appTheme.woodDark.withOpacity(0.3),
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 16,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Obx(() {
                          final width = MediaQuery.of(context).size.width;
                          final int crossAxisCount = width < 600 ? 2 : 3;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 32,
                                  childAspectRatio: 0.5,
                                ),
                            itemCount: controller.archivedJars.length,
                            itemBuilder: (context, index) {
                              final jar = controller.archivedJars[index];
                              return Opacity(
                                opacity: 0.6,
                                child: JarCard(
                                  label: jar['label'],
                                  subLabel: jar['subLabel'],
                                  count: jar['count'],
                                  isLocked: true,
                                  onTap: () {},
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }
}
