import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/event/presentation/widgets/date_time_section.dart';
import 'package:runconnect/features/event/presentation/widgets/labeled_field.dart';
import 'package:runconnect/features/event/presentation/widgets/pace_level_selector.dart';
import 'package:runconnect/features/event/presentation/widgets/run_image_banner.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Create Run'),
        backgroundColor: AppColors.surfaceVariant,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    RunImageBanner(),
                    SizedBox(height: 20),
                    LabeledField(label: 'Event Title'),
                    SizedBox(height: 16),
                    LabeledField(
                      label: 'Distance (km)',
                      suffix: 'km',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    LabeledField(
                      label: 'Max Participants',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 24),
                    PaceLevelSelector(),
                    SizedBox(height: 20),
                    DateTimeSection(),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _CreateEventButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateEventButton extends StatelessWidget {
  const _CreateEventButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Create Event',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 8),
            Icon(Icons.check_circle_outline, size: 20),
          ],
        ),
      ),
    );
  }
}
