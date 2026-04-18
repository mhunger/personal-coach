import 'component.dart';

enum TurnRole { user, coach }

/// A single turn in the conversation — a user or coach entry with the
/// component stream that was published.
class CoachTurn {
  final TurnRole role;
  final List<Component> components;
  final DateTime? createdAt;

  const CoachTurn({
    required this.role,
    required this.components,
    this.createdAt,
  });
}
