class ProfileSummary {
  final String id;
  final String displayName;
  final String? handle;
  final String? avatarUrl;
  final bool isFollowing;

  const ProfileSummary({
    required this.id,
    required this.displayName,
    this.handle,
    this.avatarUrl,
    this.isFollowing = false,
  });

  ProfileSummary copyWith({bool? isFollowing}) => ProfileSummary(
    id: id,
    displayName: displayName,
    handle: handle,
    avatarUrl: avatarUrl,
    isFollowing: isFollowing ?? this.isFollowing,
  );
}
