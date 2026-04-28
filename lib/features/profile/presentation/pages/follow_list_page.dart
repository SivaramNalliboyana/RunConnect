import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';
import 'package:runconnect/features/profile/presentation/widgets/follow_user_tile.dart';

enum FollowListMode { following, followers }

class FollowListPage extends StatefulWidget {
  const FollowListPage({super.key, required this.mode});

  final FollowListMode mode;

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  late List<ProfileSummary> _users;

  @override
  void initState() {
    super.initState();
    _users = widget.mode == FollowListMode.following
        ? List.of(_mockFollowing)
        : List.of(_mockFollowers);
  }

  void _toggle(int index) {
    setState(() {
      _users[index] = _users[index].copyWith(
        isFollowing: !_users[index].isFollowing,
      );
    });
  }

  String get _title =>
      widget.mode == FollowListMode.following ? 'Following' : 'Followers';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _title,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _users.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Color(0x14000000), indent: 76),
          itemBuilder: (_, i) => FollowUserTile(
            user: _users[i],
            onTogglePressed: () => _toggle(i),
          ),
        ),
      ),
    );
  }
}

const _mockFollowing = <ProfileSummary>[
  ProfileSummary(
    id: 'u1',
    displayName: 'Sarah Chen',
    handle: '@sarahruns',
    isFollowing: true,
  ),
  ProfileSummary(
    id: 'u2',
    displayName: 'Marcus Webb',
    handle: '@marcusw',
    isFollowing: true,
  ),
  ProfileSummary(
    id: 'u3',
    displayName: 'Priya Patel',
    handle: '@priya.p',
    isFollowing: true,
  ),
  ProfileSummary(
    id: 'u4',
    displayName: 'Diego Alvarez',
    handle: '@diego_runs',
    isFollowing: true,
  ),
  ProfileSummary(
    id: 'u5',
    displayName: 'Emma Thompson',
    handle: '@emmat',
    isFollowing: true,
  ),
  ProfileSummary(
    id: 'u6',
    displayName: 'Yuki Tanaka',
    handle: '@yuki.t',
    isFollowing: true,
  ),
];

const _mockFollowers = <ProfileSummary>[
  ProfileSummary(
    id: 'f1',
    displayName: 'Sarah Chen',
    handle: '@sarahruns',
    isFollowing: true,
  ),
  ProfileSummary(
    id: 'f2',
    displayName: 'James O\'Connor',
    handle: '@jamesoc',
    isFollowing: false,
  ),
  ProfileSummary(
    id: 'f3',
    displayName: 'Aisha Mohammed',
    handle: '@aisha.m',
    isFollowing: false,
  ),
  ProfileSummary(
    id: 'f4',
    displayName: 'Marcus Webb',
    handle: '@marcusw',
    isFollowing: true,
  ),
  ProfileSummary(
    id: 'f5',
    displayName: 'Liam Foster',
    handle: '@liamf',
    isFollowing: false,
  ),
  ProfileSummary(
    id: 'f6',
    displayName: 'Nora Williams',
    handle: '@noraw',
    isFollowing: false,
  ),
  ProfileSummary(
    id: 'f7',
    displayName: 'Diego Alvarez',
    handle: '@diego_runs',
    isFollowing: true,
  ),
  ProfileSummary(
    id: 'f8',
    displayName: 'Hana Park',
    handle: '@hana.p',
    isFollowing: false,
  ),
];
