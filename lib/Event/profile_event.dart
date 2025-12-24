abstract class ProfileEvent {}

class FetchProfile extends ProfileEvent {
  final String userId;

  FetchProfile(this.userId);
}
