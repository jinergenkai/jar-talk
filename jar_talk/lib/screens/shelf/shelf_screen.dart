import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jar_talk/controllers/shelf_controller.dart';
import 'package:jar_talk/screens/shelf/widgets/jar_card.dart';
import 'package:jar_talk/utils/app_theme.dart';
import 'package:jar_talk/screens/journal_view/journal_view_screen.dart';
import 'package:jar_talk/screens/notification/notification_screen.dart';
import 'package:jar_talk/screens/shelf/widgets/add_jar_options_sheet.dart';
import 'package:jar_talk/screens/shelf/widgets/create_jar_dialog.dart';
import 'package:jar_talk/screens/shelf/widgets/join_jar_dialog.dart';

class ShelfScreen extends StatelessWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the real controller
    final controller = Get.put(ShelfController());
    final theme = Theme.of(context);
    final appTheme = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => controller.fetchJars(),
        color: theme.colorScheme.primary,
        backgroundColor: theme.scaffoldBackgroundColor,
        child: CustomScrollView(
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
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : appTheme.woodLight,
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          _showAddOptions(context, controller);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "NEW",
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // content
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.activeJars.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return Column(
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
                          Text(
                            '${controller.activeJars.length} ACTIVE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: theme.colorScheme.primary,
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
                            child: Builder(
                              builder: (context) {
                                final width = MediaQuery.of(context).size.width;
                                final int crossAxisCount = width < 600 ? 2 : 3;

                                if (controller.activeJars.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Center(
                                      child: Text("No Jars found. Create one!"),
                                    ),
                                  );
                                }

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
                                      label: jar.name,
                                      subLabel:
                                          'Member Count: ${jar.memberCount ?? 1}', // Fallback
                                      count:
                                          0, // Backend doesn't support slip count yet
                                      jarColor: const Color(
                                        0xFFD47311,
                                      ), // Default or parse from styleSettings
                                      isLocked: false,
                                      onTap: () {
                                        Navigator.of(
                                          context,
                                          rootNavigator: true,
                                        ).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                JournalViewScreen(
                                                  jarId: jar.id,
                                                  jarName: jar.name,
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Archived Jars Header (Placeholder for now)
                    if (controller.archivedJars.isNotEmpty) ...[
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
                        // ... decoration similar to above ...
                        child: const SizedBox(height: 100), // Placeholder
                      ),
                    ],
                    const SizedBox(height: 100), // Bottom padding
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context, ShelfController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => AddJarOptionsSheet(
        onCreate: () => _showCreateJarDialog(context, controller),
        onJoin: () => _showJoinJarDialog(context),
      ),
    );
  }

  void _showJoinJarDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const JoinJarDialog());
  }

  void _showCreateJarDialog(BuildContext context, ShelfController controller) {
    showDialog(
      context: context,
      builder: (context) => CreateJarDialog(controller: controller),
    );
  }
}
