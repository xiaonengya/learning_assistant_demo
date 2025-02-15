import 'dart:async';
import 'dart:io';

class AvatarStateService {
  static final AvatarStateService _instance = AvatarStateService._internal();
  factory AvatarStateService() => _instance;
  AvatarStateService._internal();

  final _avatarController = StreamController<File?>.broadcast();
  Stream<File?> get avatarStream => _avatarController.stream;

  void updateAvatar(File newAvatar) {
    _avatarController.add(newAvatar);
  }

  void dispose() {
    _avatarController.close();
  }
}
