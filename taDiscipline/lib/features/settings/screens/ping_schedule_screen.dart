import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/shared/widgets/glass_card.dart';
import 'package:apex/data/repositories/settings_repository.dart';
import 'package:apex/data/local/app_session.dart';

class PingSchedule {
  final String key;
  final String label;
  TimeOfDay time;
  List<int> days;
  bool enabled;

  PingSchedule({
    required this.key,
    required this.label,
    required this.time,
    required this.days,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'hour': time.hour,
        'minute': time.minute,
        'days': days,
        'enabled': enabled,
      };

  factory PingSchedule.fromJson(Map<String, dynamic> json) => PingSchedule(
        key: json['key'] as String,
        label: json['label'] as String,
        time: TimeOfDay(
          hour: json['hour'] as int? ?? 7,
          minute: json['minute'] as int? ?? 0,
        ),
        days: (json['days'] as List?)?.map((e) => e as int).toList() ??
            [1, 2, 3, 4, 5],
        enabled: json['enabled'] as bool? ?? true,
      );
}

final _defaultPings = [
  PingSchedule(
    key: 'morning',
    label: 'Rituel du matin',
    time: const TimeOfDay(hour: 7, minute: 0),
    days: [1, 2, 3, 4, 5, 6, 7],
  ),
  PingSchedule(
    key: 'afternoon',
    label: 'Focus de l\'après-midi',
    time: const TimeOfDay(hour: 14, minute: 0),
    days: [1, 2, 3, 4, 5, 6, 7],
  ),
  PingSchedule(
    key: 'evening',
    label: 'Gratitude du soir',
    time: const TimeOfDay(hour: 20, minute: 0),
    days: [1, 2, 3, 4, 5, 6, 7],
  ),
];

final _dayLabels = ['', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

class PingScheduleScreen extends ConsumerStatefulWidget {
  const PingScheduleScreen({super.key});

  @override
  ConsumerState<PingScheduleScreen> createState() =>
      _PingScheduleScreenState();
}

class _PingScheduleScreenState extends ConsumerState<PingScheduleScreen> {
  late List<PingSchedule> _schedules;

  @override
  void initState() {
    super.initState();
    _schedules = _defaultPings.map((p) => p).toList();
    _load();
  }

  Future<void> _load() async {
    final userId = AppSession.userId;
    if (userId == null) return;
    try {
      final settings = await SettingsRepository().getSettings(userId);
      final pingsData = settings.pingSchedules;
      if (pingsData != null && pingsData is List) {
        final saved = (pingsData)
            .map((e) => PingSchedule.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted) {
          setState(() {
            for (final s in saved) {
              final idx = _schedules.indexWhere((p) => p.key == s.key);
              if (idx >= 0) _schedules[idx] = s;
            }
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final userId = AppSession.userId;
    if (userId == null) return;
    try {
      final settings = await SettingsRepository().getSettings(userId);
      await SettingsRepository().updateSettings(
        settings.copyWith(
          pingSchedules: _schedules.map((s) => s.toJson()).toList(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pings mis à jour'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pings intelligents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Les pings contextuels te rappellent tes rituels au moment idéal.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ..._schedules.map((schedule) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PingCard(
                  schedule: schedule,
                  onChanged: () => setState(() {}),
                ),
              )),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jours de la semaine',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: List.generate(7, (i) {
                    final day = i + 1;
                    final allSelected =
                        _schedules.every((s) => s.days.contains(day));
                    return FilterChip(
                      label: Text(
                        _dayLabels[day],
                        style: TextStyle(
                          fontSize: 12,
                          color: allSelected
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                      selected: allSelected,
                      onSelected: (v) {
                        for (final s in _schedules) {
                          if (v && !s.days.contains(day)) {
                            s.days.add(day);
                          } else if (!v) {
                            s.days.remove(day);
                          }
                        }
                        setState(() {});
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.3),
                      backgroundColor: AppColors.surface,
                      checkmarkColor: AppColors.primaryLight,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PingCard extends StatelessWidget {
  final PingSchedule schedule;
  final VoidCallback onChanged;

  const _PingCard({
    required this.schedule,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Switch(
            value: schedule.enabled,
            onChanged: (v) {
              schedule.enabled = v;
              onChanged();
            },
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: schedule.enabled
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
                Text(
                  schedule.time.format(context),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.access_time, color: AppColors.textSecondary),
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: schedule.time,
                builder: (context, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.primary,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                schedule.time = picked;
                onChanged();
              }
            },
          ),
        ],
      ),
    );
  }
}
