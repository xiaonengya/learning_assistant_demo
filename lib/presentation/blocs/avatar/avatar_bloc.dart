import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/avatar_usecases.dart';

// Events
abstract class AvatarEvent extends Equatable {
  const AvatarEvent();

  @override
  List<Object?> get props => [];
}

class LoadAvatarEvent extends AvatarEvent {}

class UpdateAvatarEvent extends AvatarEvent {
  final String imagePath;

  const UpdateAvatarEvent(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

class DeleteAvatarEvent extends AvatarEvent {}

// States
abstract class AvatarState extends Equatable {
  const AvatarState();

  @override
  List<Object?> get props => [];
}

class AvatarInitial extends AvatarState {}

class AvatarLoading extends AvatarState {}

class AvatarLoaded extends AvatarState {
  final File? avatar;

  const AvatarLoaded(this.avatar);

  @override
  List<Object?> get props => [avatar];
}

class AvatarError extends AvatarState {
  final String message;

  const AvatarError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class AvatarBloc extends Bloc<AvatarEvent, AvatarState> {
  final GetAvatar getAvatar;
  final SaveAvatar saveAvatar;
  final DeleteAvatar deleteAvatar;

  AvatarBloc({
    required this.getAvatar,
    required this.saveAvatar,
    required this.deleteAvatar,
  }) : super(AvatarInitial()) {
    on<LoadAvatarEvent>(_onLoadAvatar);
    on<UpdateAvatarEvent>(_onUpdateAvatar);
    on<DeleteAvatarEvent>(_onDeleteAvatar);
  }

  Future<void> _onLoadAvatar(LoadAvatarEvent event, Emitter<AvatarState> emit) async {
    emit(AvatarLoading());
    try {
      final avatar = await getAvatar();
      emit(AvatarLoaded(avatar));
    } catch (e) {
      emit(AvatarError('加载头像失败: $e'));
    }
  }

  Future<void> _onUpdateAvatar(UpdateAvatarEvent event, Emitter<AvatarState> emit) async {
    emit(AvatarLoading());
    try {
      await saveAvatar(event.imagePath);
      final avatar = await getAvatar();
      emit(AvatarLoaded(avatar));
    } catch (e) {
      emit(AvatarError('更新头像失败: $e'));
    }
  }

  Future<void> _onDeleteAvatar(DeleteAvatarEvent event, Emitter<AvatarState> emit) async {
    emit(AvatarLoading());
    try {
      await deleteAvatar();
      emit(const AvatarLoaded(null));
    } catch (e) {
      emit(AvatarError('删除头像失败: $e'));
    }
  }
}
