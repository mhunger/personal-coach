import 'component.dart';

class ChatResult {
  final int conversationId;
  final List<Component> components;

  const ChatResult({required this.conversationId, required this.components});
}
