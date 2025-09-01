import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sleep_providers.dart';
import '../../data/models/sleep_models.dart';
import 'package:uuid/uuid.dart';
import '../../../../widgets/achievement_popup_widget.dart';

class SleepTrackingScreen extends ConsumerStatefulWidget {
  const SleepTrackingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends ConsumerState<SleepTrackingScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? bedtime;
  TimeOfDay? wakeTime;
  double sleepQuality = 7.0;
  String mood = 'Good';
  String? notes;
  bool isSaving = false;

  final List<String> moodOptions = <String>['Poor', 'Fair', 'Good', 'Excellent'];

  // Helper methods for sleep quality colors
  Color _getSleepQualityColor(double quality, ColorScheme colorScheme) {
    if (quality >= 8) return colorScheme.primary;
    if (quality >= 6) return colorScheme.secondary;
    if (quality >= 4) return colorScheme.tertiary;
    return colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Track Sleep',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'How did you sleep?',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your sleep details to track your rest',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date Selection
            _buildDateSelectionSection(),
            const SizedBox(height: 24),

            // Time Selection
            _buildTimeSelectionSection(),
            const SizedBox(height: 24),

            // Sleep Quality
            _buildSleepQualitySection(),
            const SizedBox(height: 24),

            // Mood
            _buildMoodSection(),
            const SizedBox(height: 24),

            // Notes
            _buildNotesSection(),
            const SizedBox(height: 32),

            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectionSection() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Sleep Date',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 1)),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: colorScheme.copyWith(
                        primary: colorScheme.primary,
                        onPrimary: colorScheme.onPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDate = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                  );
                });
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.calendar_today,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Date',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelectionSection() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Sleep Time',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildTimePicker(
                  'Bedtime',
                  bedtime,
                  Icons.nightlight_round,
                  (TimeOfDay time) => setState(() => bedtime = time),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(
                  'Wake Time',
                  wakeTime,
                  Icons.wb_sunny,
                  (TimeOfDay time) => setState(() => wakeTime = time),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, IconData icon, Function(TimeOfDay) onTimeSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () async {
        final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: colorScheme.copyWith(
                  primary: colorScheme.primary,
                  onPrimary: colorScheme.onPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (selectedTime != null) {
          onTimeSelected(selectedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time?.format(context) ?? 'Select Time',
              style: TextStyle(
                color: time != null ? colorScheme.onSurface : colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepQualitySection() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Sleep Quality',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Rate your sleep (1-10)',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getSleepQualityColor(sleepQuality, colorScheme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${sleepQuality.round()}/10',
                  style: TextStyle(
                    color: _getSleepQualityColor(sleepQuality, colorScheme),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: sleepQuality,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: colorScheme.primary,
            inactiveColor: colorScheme.outline.withOpacity(0.3),
            onChanged: (double value) => setState(() => sleepQuality = value),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'How do you feel?',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: moodOptions.map((String moodOption) {
              final bool isSelected = mood == moodOption;
              return ChoiceChip(
                label: Text(moodOption),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() => mood = moodOption);
                  }
                },
                selectedColor: colorScheme.primary.withOpacity(0.2),
                backgroundColor: colorScheme.surface,
                labelStyle: TextStyle(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Notes (Optional)',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'How was your sleep? Any observations?',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
            style: TextStyle(color: colorScheme.onSurface),
            onChanged: (String value) => setState(() => notes = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final bool isValid = bedtime != null && wakeTime != null;
    final colorScheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isValid && !isSaving ? _saveSleepSession : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save Sleep Session',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _saveSleepSession() async {
    if (bedtime == null || wakeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select both bedtime and wake time'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      // Check for existing sleep sessions on the selected date
      final List<SleepSession> existingSessions = await ref.read(sleepSessionsProvider.notifier).getSleepSessionsForDate(selectedDate);
      
      if (existingSessions.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('A sleep session already exists for this date. Please edit the existing entry instead.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        setState(() => isSaving = false);
        return;
      }

      // Calculate sleep duration
      final DateTime now = DateTime.now();
      final DateTime bedtimeDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        bedtime!.hour,
        bedtime!.minute,
      );
      final DateTime wakeTimeDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        wakeTime!.hour,
        wakeTime!.minute,
      );

      // Adjust wake time if it's before bedtime (next day)
      final DateTime adjustedWakeTime = wakeTimeDateTime.isBefore(bedtimeDateTime)
          ? wakeTimeDateTime.add(const Duration(days: 1))
          : wakeTimeDateTime;

      final Duration duration = adjustedWakeTime.difference(bedtimeDateTime);

      // Validate sleep duration (max 24 hours)
      if (duration.inHours > 24) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sleep duration cannot exceed 24 hours'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        setState(() => isSaving = false);
        return;
      }

      // Create sleep session
      final SleepSession sleepSession = SleepSession(
        id: const Uuid().v4(),
        startTime: bedtimeDateTime,
        endTime: adjustedWakeTime,
        totalDuration: duration,
        sleepQuality: sleepQuality,
        mood: mood,
        environment: SleepEnvironment(
          roomTemperature: 22.0,
          noiseLevel: 'Low',
          lightExposure: 'Dark',
          screenTime: 1.0,
          naturalLight: false,
          ecoFriendly: false,
          energyEfficient: false,
        ),
        stages: SleepStages(
          lightSleep: Duration(hours: (duration.inHours * 0.5).round()),
          deepSleep: Duration(hours: (duration.inHours * 0.2).round()),
          remSleep: Duration(hours: (duration.inHours * 0.25).round()),
          awakeTime: Duration(hours: (duration.inHours * 0.05).round()),
        ),
        sustainability: SleepSustainability(
          energySaved: 0.8,
          carbonFootprintReduction: 0.6,
          usedEcoFriendlyBedding: true,
          usedNaturalVentilation: true,
          usedEnergyEfficientDevices: true,
        ),
        createdAt: now,
        notes: notes,
      );

      // Save to provider
      await ref.read(sleepSessionsProvider.notifier).addSleepSession(sleepSession);

      if (mounted) {
        // Show achievement popup for sleep tracking completion
        AchievementPopupWidget.showSleepLogged(context, '${duration.inHours}h ${duration.inMinutes % 60}m');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save sleep session: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }
}
