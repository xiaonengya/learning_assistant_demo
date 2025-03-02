import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/models/api_config.dart';
import '../../../domain/usecases/api_config_usecases.dart';

// Events
abstract class ApiConfigEvent extends Equatable {
  const ApiConfigEvent();

  @override
  List<Object?> get props => [];
}

class LoadApiConfigsEvent extends ApiConfigEvent {}

class SaveApiConfigEvent extends ApiConfigEvent {
  final APIConfig config;

  const SaveApiConfigEvent(this.config);

  @override
  List<Object> get props => [config];
}

class DeleteApiConfigEvent extends ApiConfigEvent {
  final String id;

  const DeleteApiConfigEvent(this.id);

  @override
  List<Object> get props => [id];
}

class SetDefaultApiConfigEvent extends ApiConfigEvent {
  final String id;

  const SetDefaultApiConfigEvent(this.id);

  @override
  List<Object> get props => [id];
}

class RemoveDefaultApiConfigEvent extends ApiConfigEvent {}

class LoadDefaultApiConfigEvent extends ApiConfigEvent {}

// States
abstract class ApiConfigState extends Equatable {
  const ApiConfigState();

  @override
  List<Object?> get props => [];
}

class ApiConfigInitial extends ApiConfigState {}

class ApiConfigLoading extends ApiConfigState {}

class ApiConfigsLoaded extends ApiConfigState {
  final List<APIConfig> configs;
  final APIConfig? defaultConfig;

  const ApiConfigsLoaded({
    required this.configs,
    this.defaultConfig,
  });

  @override
  List<Object?> get props => [configs, defaultConfig];
}

class ApiConfigError extends ApiConfigState {
  final String message;

  const ApiConfigError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ApiConfigBloc extends Bloc<ApiConfigEvent, ApiConfigState> {
  final GetApiConfigs getApiConfigs;
  final GetDefaultApiConfig getDefaultApiConfig;
  final SaveApiConfig saveApiConfig;
  final DeleteApiConfig deleteApiConfig;
  final SetDefaultApiConfig setDefaultApiConfig;
  final RemoveDefaultApiConfig removeDefaultApiConfig;

  ApiConfigBloc({
    required this.getApiConfigs,
    required this.getDefaultApiConfig,
    required this.saveApiConfig,
    required this.deleteApiConfig,
    required this.setDefaultApiConfig,
    required this.removeDefaultApiConfig,
  }) : super(ApiConfigInitial()) {
    on<LoadApiConfigsEvent>(_onLoadApiConfigs);
    on<SaveApiConfigEvent>(_onSaveApiConfig);
    on<DeleteApiConfigEvent>(_onDeleteApiConfig);
    on<SetDefaultApiConfigEvent>(_onSetDefaultApiConfig);
    on<RemoveDefaultApiConfigEvent>(_onRemoveDefaultApiConfig);
    on<LoadDefaultApiConfigEvent>(_onLoadDefaultApiConfig);
  }

  Future<void> _onLoadApiConfigs(
    LoadApiConfigsEvent event,
    Emitter<ApiConfigState> emit,
  ) async {
    emit(ApiConfigLoading());
    try {
      final configs = await getApiConfigs();
      final defaultConfig = await getDefaultApiConfig();
      emit(ApiConfigsLoaded(configs: configs, defaultConfig: defaultConfig));
    } catch (e) {
      emit(ApiConfigError('加载API配置失败: $e'));
    }
  }

  Future<void> _onSaveApiConfig(
    SaveApiConfigEvent event,
    Emitter<ApiConfigState> emit,
  ) async {
    // 在开始更新前检查是否有加载状态需要显示
    if (state is! ApiConfigsLoaded) {
      emit(ApiConfigLoading());
    }
    
    try {
      // 如果当前已经是ApiConfigsLoaded状态，提前获取并保留当前配置
      APIConfig? previousDefaultConfig;
      List<APIConfig> previousConfigs = [];
      
      if (state is ApiConfigsLoaded) {
        final currentState = state as ApiConfigsLoaded;
        previousDefaultConfig = currentState.defaultConfig;
        previousConfigs = currentState.configs;
        
        // 如果更新的是当前默认配置，立即更新UI，避免闪烁
        if (previousDefaultConfig != null && previousDefaultConfig.id == event.config.id) {
          // 创建一个临时状态，使用更新后的配置但保留旧的配置列表
          emit(ApiConfigsLoaded(
            configs: previousConfigs,
            defaultConfig: event.config,
          ));
        }
      }
      
      // 保存配置到存储
      await saveApiConfig(event.config);
      
      // 加载最新的完整配置列表
      final updatedConfigs = await getApiConfigs();
      
      // 确定新的默认配置
      // 如果更新的配置设置为默认，或者它就是当前默认配置，直接使用它
      APIConfig? newDefaultConfig;
      if (event.config.isDefault) {
        newDefaultConfig = event.config;
      } else if (previousDefaultConfig != null && previousDefaultConfig.id == event.config.id) {
        // 如果更新的是当前默认配置，但没有设置isDefault为true
        // 检查存储库中的默认配置
        newDefaultConfig = await getDefaultApiConfig();
      } else {
        // 否则，获取存储库中的默认配置
        newDefaultConfig = await getDefaultApiConfig();
      }
      
      // 发出最终状态
      emit(ApiConfigsLoaded(
        configs: updatedConfigs,
        defaultConfig: newDefaultConfig,
      ));
    } catch (e) {
      emit(ApiConfigError('保存API配置失败: $e'));
    }
  }

  Future<void> _onDeleteApiConfig(
    DeleteApiConfigEvent event,
    Emitter<ApiConfigState> emit,
  ) async {
    emit(ApiConfigLoading());
    try {
      await deleteApiConfig(event.id);
      final configs = await getApiConfigs();
      final defaultConfig = await getDefaultApiConfig();
      emit(ApiConfigsLoaded(configs: configs, defaultConfig: defaultConfig));
    } catch (e) {
      emit(ApiConfigError('删除API配置失败: $e'));
    }
  }

  Future<void> _onSetDefaultApiConfig(
    SetDefaultApiConfigEvent event,
    Emitter<ApiConfigState> emit,
  ) async {
    emit(ApiConfigLoading());
    try {
      await setDefaultApiConfig(event.id);
      final configs = await getApiConfigs();
      final defaultConfig = await getDefaultApiConfig();
      emit(ApiConfigsLoaded(configs: configs, defaultConfig: defaultConfig));
    } catch (e) {
      emit(ApiConfigError('设置默认API配置失败: $e'));
    }
  }

  Future<void> _onRemoveDefaultApiConfig(
    RemoveDefaultApiConfigEvent event,
    Emitter<ApiConfigState> emit,
  ) async {
    emit(ApiConfigLoading());
    try {
      await removeDefaultApiConfig();
      final configs = await getApiConfigs();
      emit(ApiConfigsLoaded(configs: configs, defaultConfig: null));
    } catch (e) {
      emit(ApiConfigError('移除默认API配置失败: $e'));
    }
  }

  Future<void> _onLoadDefaultApiConfig(
    LoadDefaultApiConfigEvent event,
    Emitter<ApiConfigState> emit,
  ) async {
    emit(ApiConfigLoading());
    try {
      final defaultConfig = await getDefaultApiConfig();
      final configs = await getApiConfigs();
      emit(ApiConfigsLoaded(configs: configs, defaultConfig: defaultConfig));
    } catch (e) {
      emit(ApiConfigError('加载默认API配置失败: $e'));
    }
  }
}
