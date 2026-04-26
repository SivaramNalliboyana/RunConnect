import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/event/data/data_sources/event_remote_data_source.dart';
import 'package:runconnect/features/event/data/repositories/event_repository_impl.dart';
import 'package:runconnect/features/event/domain/use_cases/create_event_use_case.dart';
import 'package:runconnect/features/event/presentation/bloc/create_event_bloc.dart';
import 'package:runconnect/features/event/presentation/bloc/create_event_event.dart';
import 'package:runconnect/features/event/presentation/bloc/create_event_state.dart';
import 'package:runconnect/features/event/presentation/widgets/date_time_section.dart';
import 'package:runconnect/features/event/presentation/widgets/labeled_field.dart';
import 'package:runconnect/features/event/presentation/widgets/pace_level_selector.dart';
import 'package:runconnect/features/event/presentation/widgets/run_image_banner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _buildBloc(),
      child: const _CreateEventView(),
    );
  }

  static CreateEventBloc _buildBloc() {
    final client = Supabase.instance.client;
    final dataSource = EventRemoteDataSourceImpl(client);
    final repository = EventRepositoryImpl(dataSource);
    return CreateEventBloc(createEvent: CreateEventUseCase(repository));
  }
}

class _CreateEventView extends StatefulWidget {
  const _CreateEventView();

  @override
  State<_CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<_CreateEventView> {
  final _title = TextEditingController();
  final _distance = TextEditingController();
  final _maxParticipants = TextEditingController();
  final _meetingPoint = TextEditingController();
  final _picker = ImagePicker();

  DateTime? _date;
  TimeOfDay? _time;

  @override
  void dispose() {
    _title.dispose();
    _distance.dispose();
    _maxParticipants.dispose();
    _meetingPoint.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    context.read<CreateEventBloc>().add(CreateEventImagePicked(picked));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    final bloc = context.read<CreateEventBloc>();
    final state = bloc.state;

    if (_title.text.trim().isEmpty) {
      _snack('Enter an event title');
      return;
    }
    if (state.paceLevel == null) {
      _snack('Select a pace level');
      return;
    }
    if (_date == null || _time == null) {
      _snack('Pick date and time');
      return;
    }

    final startsAt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );

    bloc.add(
      CreateEventSubmitted(
        title: _title.text.trim(),
        distanceKm: double.tryParse(_distance.text) ?? 0,
        maxParticipants: int.tryParse(_maxParticipants.text) ?? 0,
        startsAt: startsAt,
        meetingPoint: _meetingPoint.text.trim(),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateEventBloc, CreateEventState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage ||
          prev.createdEvent != curr.createdEvent,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state.createdEvent != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created')),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        final bloc = context.read<CreateEventBloc>();
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
                      children: [
                        RunImageBanner(
                          imagePath: state.imagePath,
                          onTap: _pickImage,
                        ),
                        const SizedBox(height: 20),
                        LabeledField(
                          label: 'Event Title',
                          controller: _title,
                        ),
                        const SizedBox(height: 16),
                        LabeledField(
                          label: 'Distance (km)',
                          controller: _distance,
                          suffix: 'km',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        LabeledField(
                          label: 'Max Participants',
                          controller: _maxParticipants,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 24),
                        PaceLevelSelector(
                          selected: state.paceLevel,
                          onSelect: (p) => bloc.add(
                            CreateEventPaceLevelSelected(p),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DateTimeSection(
                          date: _date,
                          time: _time,
                          locationController: _meetingPoint,
                          onPickDate: _pickDate,
                          onPickTime: _pickTime,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: _CreateEventButton(
                    isSubmitting: state.isSubmitting,
                    onPressed: state.isSubmitting ? null : _submit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CreateEventButton extends StatelessWidget {
  const _CreateEventButton({
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isSubmitting;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(AppColors.onPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Create Event',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.check_circle_outline, size: 20),
                ],
              ),
      ),
    );
  }
}
