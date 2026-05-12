import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:runconnect/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:runconnect/features/profile/domain/use_cases/follow_user_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_event_participants_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/unfollow_user_use_case.dart';
import 'package:runconnect/features/profile/presentation/bloc/event_participants_bloc.dart';
import 'package:runconnect/features/profile/presentation/bloc/event_participants_event.dart';
import 'package:runconnect/features/profile/presentation/bloc/event_participants_state.dart';
import 'package:runconnect/features/profile/presentation/widgets/follow_user_tile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> showEventParticipantsSheet(
  BuildContext context, {
  required String eventId,
  String? eventTitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _EventParticipantsSheet(
      eventId: eventId,
      eventTitle: eventTitle,
    ),
  );
}

class _EventParticipantsSheet extends StatelessWidget {
  const _EventParticipantsSheet({required this.eventId, this.eventTitle});

  final String eventId;
  final String? eventTitle;

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser?.id ?? '';
    final repository = ProfileRepositoryImpl(
      ProfileRemoteDataSourceImpl(client),
    );

    return BlocProvider(
      create: (_) => EventParticipantsBloc(
        getParticipants: GetEventParticipantsUseCase(repository),
        followUser: FollowUserUseCase(repository),
        unfollowUser: UnfollowUserUseCase(repository),
        eventId: eventId,
        currentUserId: currentUserId,
      )..add(EventParticipantsRequested()),
      child: _SheetView(
        eventTitle: eventTitle,
        currentUserId: currentUserId,
      ),
    );
  }
}

class _SheetView extends StatelessWidget {
  const _SheetView({required this.eventTitle, required this.currentUserId});

  final String? eventTitle;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Going',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            if (eventTitle != null && eventTitle!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 24, right: 24),
                child: Text(
                  eventTitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0x14000000)),
            Expanded(
              child:
                  BlocConsumer<EventParticipantsBloc, EventParticipantsState>(
                listenWhen: (prev, curr) =>
                    prev.actionErrorMessage != curr.actionErrorMessage &&
                    curr.actionErrorMessage != null,
                listener: (context, state) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.actionErrorMessage!),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
                builder: (context, state) {
                  switch (state.status) {
                    case EventParticipantsStatus.initial:
                    case EventParticipantsStatus.loading:
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    case EventParticipantsStatus.failure:
                      return _ErrorView(
                        message:
                            state.errorMessage ?? 'Something went wrong',
                        onRetry: () => context
                            .read<EventParticipantsBloc>()
                            .add(EventParticipantsRequested()),
                      );
                    case EventParticipantsStatus.success:
                      if (state.users.isEmpty) {
                        return const _EmptyView();
                      }
                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: state.users.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: Color(0x14000000),
                          indent: 76,
                        ),
                        itemBuilder: (_, i) {
                          final user = state.users[i];
                          final isSelf = user.id == currentUserId;
                          return FollowUserTile(
                            user: user,
                            isSelf: isSelf,
                            onTap: () {
                              Navigator.of(context).pop();
                              context.push('/user/${user.id}');
                            },
                            onTogglePressed: () => context
                                .read<EventParticipantsBloc>()
                                .add(EventParticipantsToggleRequested(
                                  user.id,
                                )),
                          );
                        },
                      );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.people_outline,
              size: 56,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'No one going yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
