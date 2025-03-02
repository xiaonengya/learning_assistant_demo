import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/models/ai_role.dart';
import '../../../domain/models/ai_preset_text.dart';
import '../../../domain/usecases/preset_usecases.dart';

// Events
abstract class PresetEvent extends Equatable {
  const PresetEvent();

  @override
  List<Object?> get props => [];
}

class LoadPresetsEvent extends PresetEvent {}

class SaveRoleEvent extends PresetEvent {
  final AIRole role;

  const SaveRoleEvent(this.role);

  @override
  List<Object> get props => [role];
}

class DeleteRoleEvent extends PresetEvent {
  final String id;

  const DeleteRoleEvent(this.id);

  @override
  List<Object> get props => [id];
}

class SetDefaultRoleEvent extends PresetEvent {
  final String id;

  const SetDefaultRoleEvent(this.id);

  @override
  List<Object> get props => [id];
}

// 以下事件仍然保留但不在UI中使用
class SavePresetTextEvent extends PresetEvent {
  final AIPresetText preset;

  const SavePresetTextEvent(this.preset);

  @override
  List<Object> get props => [preset];
}

class DeletePresetTextEvent extends PresetEvent {
  final String id;

  const DeletePresetTextEvent(this.id);

  @override
  List<Object> get props => [id];
}

class SetDefaultPresetTextEvent extends PresetEvent {
  final String id;

  const SetDefaultPresetTextEvent(this.id);

  @override
  List<Object> get props => [id];
}

class RemoveDefaultPresetTextEvent extends PresetEvent {}

// States
abstract class PresetState extends Equatable {
  const PresetState();

  @override
  List<Object?> get props => [];
}

class PresetInitial extends PresetState {}

class PresetLoading extends PresetState {}

class PresetsLoaded extends PresetState {
  final List<AIRole> roles;
  final AIRole? defaultRole;
  final List<AIPresetText> presetTexts; // 添加这个属性
  final AIPresetText? defaultPresetText; // 添加这个属性

  const PresetsLoaded({
    required this.roles,
    this.defaultRole,
    this.presetTexts = const [], // 给一个默认值
    this.defaultPresetText,
  });

  @override
  List<Object?> get props => [roles, defaultRole, presetTexts, defaultPresetText];

  PresetsLoaded copyWith({
    List<AIRole>? roles,
    AIRole? defaultRole,
    List<AIPresetText>? presetTexts,
    AIPresetText? defaultPresetText,
    bool clearDefaultRole = false,
    bool clearDefaultPresetText = false,
  }) {
    return PresetsLoaded(
      roles: roles ?? this.roles,
      defaultRole: clearDefaultRole ? null : (defaultRole ?? this.defaultRole),
      presetTexts: presetTexts ?? this.presetTexts,
      defaultPresetText: clearDefaultPresetText ? null : (defaultPresetText ?? this.defaultPresetText),
    );
  }
}

class PresetError extends PresetState {
  final String message;

  const PresetError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class PresetBloc extends Bloc<PresetEvent, PresetState> {
  final GetRoles getRoles;
  final GetDefaultRole getDefaultRole;
  final SaveRole saveRole;
  final DeleteRole deleteRole;
  final SetDefaultRole setDefaultRole;
  
  // 这些用例虽然仍然保留，但不在UI中使用了
  final GetPresetTexts getPresetTexts;
  final GetDefaultPresetText getDefaultPresetText;
  final SavePresetText savePresetText;
  final DeletePresetText deletePresetText;
  final SetDefaultPresetText setDefaultPresetText;
  final RemoveDefaultPresetText removeDefaultPresetText;

  PresetBloc({
    required this.getRoles,
    required this.getDefaultRole,
    required this.saveRole,
    required this.deleteRole,
    required this.setDefaultRole,
    required this.getPresetTexts,
    required this.getDefaultPresetText,
    required this.savePresetText,
    required this.deletePresetText,
    required this.setDefaultPresetText,
    required this.removeDefaultPresetText,
  }) : super(PresetInitial()) {
    on<LoadPresetsEvent>(_onLoadPresets);
    on<SaveRoleEvent>(_onSaveRole);
    on<DeleteRoleEvent>(_onDeleteRole);
    on<SetDefaultRoleEvent>(_onSetDefaultRole);
    // 预设文本相关事件处理器保留，但不在UI中使用
    on<SavePresetTextEvent>(_onSavePresetText);
    on<DeletePresetTextEvent>(_onDeletePresetText);
    on<SetDefaultPresetTextEvent>(_onSetDefaultPresetText);
    on<RemoveDefaultPresetTextEvent>(_onRemoveDefaultPresetText);
  }

  Future<void> _onLoadPresets(LoadPresetsEvent event, Emitter<PresetState> emit) async {
    emit(PresetLoading());
    try {
      final roles = await getRoles();
      final defaultRole = await getDefaultRole();
      
      // 虽然UI不再展示，但仍然加载预设文本供其他地方使用
      final presetTexts = await getPresetTexts();
      final defaultPresetText = await getDefaultPresetText();
      
      emit(PresetsLoaded(
        roles: roles,
        defaultRole: defaultRole,
        presetTexts: presetTexts,
        defaultPresetText: defaultPresetText,
      ));
    } catch (e) {
      emit(PresetError('加载预设失败: $e'));
    }
  }

  Future<void> _onSaveRole(SaveRoleEvent event, Emitter<PresetState> emit) async {
    try {
      await saveRole(event.role);
      
      final roles = await getRoles();
      final defaultRole = await getDefaultRole();
      
      if (state is PresetsLoaded) {
        final currentState = state as PresetsLoaded;
        emit(currentState.copyWith(
          roles: roles,
          defaultRole: defaultRole,
        ));
      } else {
        emit(PresetsLoaded(
          roles: roles,
          defaultRole: defaultRole,
        ));
      }
    } catch (e) {
      emit(PresetError('保存角色失败: $e'));
    }
  }

  Future<void> _onDeleteRole(DeleteRoleEvent event, Emitter<PresetState> emit) async {
    try {
      await deleteRole(event.id);
      
      final roles = await getRoles();
      final defaultRole = await getDefaultRole();
      
      if (state is PresetsLoaded) {
        final currentState = state as PresetsLoaded;
        emit(currentState.copyWith(
          roles: roles,
          defaultRole: defaultRole,
        ));
      } else {
        emit(PresetsLoaded(
          roles: roles,
          defaultRole: defaultRole,
        ));
      }
    } catch (e) {
      emit(PresetError('删除角色失败: $e'));
    }
  }

  Future<void> _onSetDefaultRole(SetDefaultRoleEvent event, Emitter<PresetState> emit) async {
    try {
      await setDefaultRole(event.id);
      
      final roles = await getRoles();
      final defaultRole = await getDefaultRole();
      
      if (state is PresetsLoaded) {
        final currentState = state as PresetsLoaded;
        emit(currentState.copyWith(
          roles: roles,
          defaultRole: defaultRole,
        ));
      } else {
        emit(PresetsLoaded(
          roles: roles,
          defaultRole: defaultRole,
        ));
      }
    } catch (e) {
      emit(PresetError('设置默认角色失败: $e'));
    }
  }

  // 以下方法保留，但不在UI中使用
  Future<void> _onSavePresetText(SavePresetTextEvent event, Emitter<PresetState> emit) async {
    try {
      await savePresetText(event.preset);
      
      // 加载最新数据
      final roles = await getRoles();
      final defaultRole = await getDefaultRole();
      final presetTexts = await getPresetTexts();
      final defaultPresetText = await getDefaultPresetText();
      
      if (state is PresetsLoaded) {
        final currentState = state as PresetsLoaded;
        emit(currentState.copyWith(
          roles: roles,
          defaultRole: defaultRole,
          presetTexts: presetTexts,
          defaultPresetText: defaultPresetText,
        ));
      } else {
        emit(PresetsLoaded(
          roles: roles,
          defaultRole: defaultRole,
          presetTexts: presetTexts,
          defaultPresetText: defaultPresetText,
        ));
      }
    } catch (e) {
      emit(PresetError('保存预设文本失败: $e'));
    }
  }

  Future<void> _onDeletePresetText(DeletePresetTextEvent event, Emitter<PresetState> emit) async {
    try {
      await deletePresetText(event.id);
      
      // 加载最新数据
      final roles = await getRoles();
      final defaultRole = await getDefaultRole();
      final presetTexts = await getPresetTexts();
      final defaultPresetText = await getDefaultPresetText();
      
      if (state is PresetsLoaded) {
        final currentState = state as PresetsLoaded;
        emit(currentState.copyWith(
          roles: roles,
          defaultRole: defaultRole,
          presetTexts: presetTexts,
          defaultPresetText: defaultPresetText,
        ));
      } else {
        emit(PresetsLoaded(
          roles: roles,
          defaultRole: defaultRole,
          presetTexts: presetTexts,
          defaultPresetText: defaultPresetText,
        ));
      }
    } catch (e) {
      emit(PresetError('删除预设文本失败: $e'));
    }
  }

  Future<void> _onSetDefaultPresetText(SetDefaultPresetTextEvent event, Emitter<PresetState> emit) async {
    try {
      await setDefaultPresetText(event.id);
      
      // 加载最新数据
      final roles = await getRoles();
      final defaultRole = await getDefaultRole();
      final presetTexts = await getPresetTexts();
      final defaultPresetText = await getDefaultPresetText();
      
      if (state is PresetsLoaded) {
        final currentState = state as PresetsLoaded;
        emit(currentState.copyWith(
          roles: roles,
          defaultRole: defaultRole,
          presetTexts: presetTexts,
          defaultPresetText: defaultPresetText,
        ));
      } else {
        emit(PresetsLoaded(
          roles: roles,
          defaultRole: defaultRole,
          presetTexts: presetTexts,
          defaultPresetText: defaultPresetText,
        ));
      }
    } catch (e) {
      emit(PresetError('设置默认预设文本失败: $e'));
    }
  }

  Future<void> _onRemoveDefaultPresetText(RemoveDefaultPresetTextEvent event, Emitter<PresetState> emit) async {
    try {
      await removeDefaultPresetText();
      
      // 加载最新数据
      final roles = await getRoles();
      final defaultRole = await getDefaultRole();
      final presetTexts = await getPresetTexts();
      final defaultPresetText = await getDefaultPresetText();
      
      if (state is PresetsLoaded) {
        final currentState = state as PresetsLoaded;
        emit(currentState.copyWith(
          roles: roles,
          defaultRole: defaultRole,
          presetTexts: presetTexts,
          defaultPresetText: defaultPresetText,
          clearDefaultPresetText: true,
        ));
      } else {
        emit(PresetsLoaded(
          roles: roles,
          defaultRole: defaultRole,
          presetTexts: presetTexts,
          defaultPresetText: null,
        ));
      }
    } catch (e) {
      emit(PresetError('移除默认预设文本失败: $e'));
    }
  }
}
