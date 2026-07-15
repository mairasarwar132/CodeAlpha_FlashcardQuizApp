import 'package:codealpha_flashcard_quiz_app/app/router/app_router.dart';
import 'package:codealpha_flashcard_quiz_app/app/theme/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = (constraints.maxWidth / 3).clamp(
                        92.0,
                        140.0,
                      );
                      return SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.brightness_auto_outlined),
                            label: Text(
                              'System',
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              softWrap: false,
                            ),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined),
                            label: Text(
                              'Light',
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              softWrap: false,
                            ),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined),
                            label: Text(
                              'Dark',
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              softWrap: false,
                            ),
                          ),
                        ],
                        selected: {themeMode},
                        onSelectionChanged: (value) {
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(value.first);
                        },
                        style: ButtonStyle(
                          fixedSize: WidgetStatePropertyAll(Size(width, 48)),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 6),
                          ),
                          minimumSize: const WidgetStatePropertyAll(
                            Size(0, 48),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: colorScheme.primary),
                  title: const Text('About'),
                  subtitle: const Text('CodeAlpha portfolio project details'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.about),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.verified_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0+1'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
