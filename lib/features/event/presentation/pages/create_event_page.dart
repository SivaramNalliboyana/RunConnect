import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/event/data/data_sources/event_remote_data_source.dart';
import 'package:runconnect/features/event/data/repositories/event_repository_impl.dart';
import 'package:runconnect/features/event/domain/use_cases/create_event_use_case.dart';
import 'package:runconnect/features/event/domain/use_cases/update_event_use_case.dart';
import 'package:runconnect/features/event/presentation/bloc/create_event_bloc.dart';
import 'package:runconnect/features/event/presentation/bloc/create_event_event.dart';
import 'package:runconnect/features/event/presentation/bloc/create_event_state.dart';
import 'package:runconnect/features/event/presentation/widgets/date_time_section.dart';
import 'package:runconnect/features/event/presentation/widgets/labeled_field.dart';
import 'package:runconnect/features/event/presentation/widgets/pace_level_selector.dart';
import 'package:runconnect/features/event/presentation/widgets/run_image_banner.dart';
import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key, this.eventToEdit});

  final ProfileEventItem? eventToEdit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _buildBloc(eventToEdit),
      child: _CreateEventView(eventToEdit: eventToEdit),
    );
  }

  static CreateEventBloc _buildBloc(ProfileEventItem? eventToEdit) {
    final client = Supabase.instance.client;
    final dataSource = EventRemoteDataSourceImpl(client);
    final repository = EventRepositoryImpl(dataSource);
    final bloc = CreateEventBloc(
      createEvent: CreateEventUseCase(repository),
      updateEvent: UpdateEventUseCase(repository),
    );
    if (eventToEdit != null) {
      bloc.add(CreateEventPaceLevelSelected(eventToEdit.paceLevel));
    }
    return bloc;
  }
}

class _CreateEventView extends StatefulWidget {
  const _CreateEventView({this.eventToEdit});

  final ProfileEventItem? eventToEdit;

  @override
  State<_CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<_CreateEventView> {
  late final TextEditingController _title;
  late final TextEditingController _distance;
  late final TextEditingController _maxParticipants;
  late final TextEditingController _meetingPoint;
  final _picker = ImagePicker();

  DateTime? _date;
  TimeOfDay? _time;

  bool get _isEditing => widget.eventToEdit != null;

  @override
  void initState() {
    super.initState();
    final e = widget.eventToEdit;
    _title = TextEditingController(text: e?.title ?? '');
    _distance = TextEditingController(
      text: e == null ? '' : _formatDistance(e.distanceKm),
    );
    _maxParticipants = TextEditingController(
      text: e == null ? '' : e.maxParticipants.toString(),
    );
    _meetingPoint = TextEditingController(text: e?.meetingPoint ?? '');
    if (e != null) {
      _date = DateTime(e.startsAt.year, e.startsAt.month, e.startsAt.day);
      _time = TimeOfDay(hour: e.startsAt.hour, minute: e.startsAt.minute);
    }
  }

  String _formatDistance(double km) {
    if (km == km.truncateToDouble()) return km.toStringAsFixed(0);
    return km.toString();
  }

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
    final initial = _date ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
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

    final editing = widget.eventToEdit;
    if (editing != null) {
      bloc.add(
        UpdateEventSubmitted(
          eventId: editing.id,
          title: _title.text.trim(),
          distanceKm: double.tryParse(_distance.text) ?? 0,
          maxParticipants: int.tryParse(_maxParticipants.text) ?? 0,
          paceLevel: state.paceLevel!,
          startsAt: startsAt,
          meetingPoint: _meetingPoint.text.trim(),
        ),
      );
    } else {
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
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.eventToEdit;
    return BlocConsumer<CreateEventBloc, CreateEventState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage ||
          prev.savedEvent != curr.savedEvent,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state.savedEvent != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Event updated' : 'Event created'),
            ),
          );
          context.pop(true);
        }
      },
      builder: (context, state) {
        final bloc = context.read<CreateEventBloc>();
        return Scaffold(
          backgroundColor: AppColors.surfaceVariant,
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Run' : 'Create Run'),
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
                          imageUrl: editing?.imageUrl,
                          onTap: _isEditing ? null : _pickImage,
                          showEditIcon: !_isEditing,
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
                  child: _SubmitButton(
                    isSubmitting: state.isSubmitting,
                    isEditing: _isEditing,
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

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isSubmitting,
    required this.isEditing,
    required this.onPressed,
  });

  final bool isSubmitting;
  final bool isEditing;
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
                children: [
                  Text(
                    isEditing ? 'Save Changes' : 'Create Event',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_outline, size: 20),
                ],
              ),
      ),
    );
  }
}
