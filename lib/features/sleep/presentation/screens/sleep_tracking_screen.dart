import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/sleep_colors.dart';
import '../providers/sleep_providers.dart';
import '../../data/models/sleep_models.dart';
import 'package:uuid/uuid.dart';

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

  final List<String> moodOptions = ['Poor', 'Fair', 'Good', 'Excellent'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SleepColors.backgroundGrey,
      appBar: AppBar(
        title: const Text(
          'Track Sleep',
          style: TextStyle(
            color: SleepColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: SleepColors.surfaceGrey,
        elevation: 0,
        iconTheme: const IconThemeData(color: SleepColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    SleepColors.primaryGreen,
                    SleepColors.primaryGreenLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How did you sleep?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your sleep details to track your rest',
                    style: TextStyle(
                      color: Colors.white,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SleepColors.textTertiary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Date',
            style: TextStyle(
              color: SleepColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 1)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: SleepColors.primaryGreen,
                        onPrimary: Colors.white,
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
                color: SleepColors.backgroundGrey,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SleepColors.textTertiary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: SleepColors.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            color: SleepColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: TextStyle(
                            color: SleepColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: SleepColors.textSecondary,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SleepColors.textTertiary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Time',
            style: TextStyle(
              color: SleepColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  'Bedtime',
                  bedtime,
                  Icons.nightlight_round,
                  (time) => setState(() => bedtime = time),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(
                  'Wake Time',
                  wakeTime,
                  Icons.wb_sunny,
                  (time) => setState(() => wakeTime = time),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, IconData icon, Function(TimeOfDay) onTimeSelected) {
    return InkWell(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: SleepColors.primaryGreen,
                  onPrimary: Colors.white,
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
          color: SleepColors.backgroundGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SleepColors.textTertiary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: SleepColors.primaryGreen, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: SleepColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time?.format(context) ?? 'Select Time',
              style: TextStyle(
                color: time != null ? SleepColors.textPrimary : SleepColors.textTertiary,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SleepColors.textTertiary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Quality',
            style: TextStyle(
              color: SleepColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rate your sleep (1-10)',
                style: TextStyle(
                  color: SleepColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: SleepColors.getSleepQualityColor(sleepQuality).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${sleepQuality.round()}/10',
                  style: TextStyle(
                    color: SleepColors.getSleepQualityColor(sleepQuality),
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
            activeColor: SleepColors.primaryGreen,
            inactiveColor: SleepColors.textTertiary.withOpacity(0.3),
            onChanged: (value) => setState(() => sleepQuality = value),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SleepColors.textTertiary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you feel?',
            style: TextStyle(
              color: SleepColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: moodOptions.map((moodOption) {
              final isSelected = mood == moodOption;
              return ChoiceChip(
                label: Text(moodOption),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => mood = moodOption);
                  }
                },
                selectedColor: SleepColors.primaryGreen.withOpacity(0.2),
                backgroundColor: SleepColors.backgroundGrey,
                labelStyle: TextStyle(
                  color: isSelected ? SleepColors.primaryGreen : SleepColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? SleepColors.primaryGreen : SleepColors.textTertiary.withOpacity(0.3),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SleepColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SleepColors.textTertiary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes (Optional)',
            style: TextStyle(
              color: SleepColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'How was your sleep? Any observations?',
              hintStyle: TextStyle(color: SleepColors.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: SleepColors.textTertiary.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: SleepColors.textTertiary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SleepColors.primaryGreen, width: 2),
              ),
              filled: true,
              fillColor: SleepColors.backgroundGrey,
            ),
            style: TextStyle(color: SleepColors.textPrimary),
            onChanged: (value) => setState(() => notes = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final isValid = bedtime != null && wakeTime != null;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isValid && !isSaving ? _saveSleepSession : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: SleepColors.primaryGreen,
          foregroundColor: Colors.white,
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
        const SnackBar(
          content: Text('Please select both bedtime and wake time'),
          backgroundColor: SleepColors.errorRed,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      // Check for existing sleep sessions on the selected date
      final existingSessions = await ref.read(sleepSessionsProvider.notifier).getSleepSessionsForDate(selectedDate);
      
      if (existingSessions.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A sleep session already exists for this date. Please edit the existing entry instead.'),
              backgroundColor: SleepColors.errorRed,
            ),
          );
        }
        setState(() => isSaving = false);
        return;
      }

      // Calculate sleep duration
      final now = DateTime.now();
      final bedtimeDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        bedtime!.hour,
        bedtime!.minute,
      );
      final wakeTimeDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        wakeTime!.hour,
        wakeTime!.minute,
      );

      // Adjust wake time if it's before bedtime (next day)
      final adjustedWakeTime = wakeTimeDateTime.isBefore(bedtimeDateTime)
          ? wakeTimeDateTime.add(const Duration(days: 1))
          : wakeTimeDateTime;

      final duration = adjustedWakeTime.difference(bedtimeDateTime);

      // Validate sleep duration (max 24 hours)
      if (duration.inHours > 24) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sleep duration cannot exceed 24 hours'),
              backgroundColor: SleepColors.errorRed,
            ),
          );
        }
        setState(() => isSaving = false);
        return;
      }

      // Create sleep session
      final sleepSession = SleepSession(
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sleep session saved successfully!'),
            backgroundColor: SleepColors.successGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save sleep session: $e'),
            backgroundColor: SleepColors.errorRed,
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
