import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/local_storage_source.dart';
import '../../data/datasources/local/file_storage_source.dart';
import '../../data/datasources/remote/ai_api_source.dart';
import '../../data/repositories/api_config_repository_impl.dart';
import '../../data/repositories/avatar_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/preset_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/api_config_repository.dart';
import '../../domain/repositories/avatar_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/preset_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/api_config_usecases.dart';
import '../../domain/usecases/avatar_usecases.dart';
import '../../domain/usecases/chat_usecases.dart';
import '../../domain/usecases/preset_usecases.dart';
import '../../domain/usecases/theme_usecases.dart';
import '../../presentation/blocs/api_config/api_config_bloc.dart';
import '../../presentation/blocs/avatar/avatar_bloc.dart';
import '../../presentation/blocs/chat/chat_bloc.dart';
import '../../presentation/blocs/preset/preset_bloc.dart';
import '../../presentation/blocs/theme/theme_bloc.dart';

final GetIt getIt = GetIt.instance;

/// 依赖注入初始化
Future<void> setupServiceLocator() async {
  // 外部依赖
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  final appDocDir = await getApplicationDocumentsDirectory();
  getIt.registerSingleton<Directory>(appDocDir);
  
  getIt.registerSingleton<http.Client>(http.Client());

  // 数据源
  getIt.registerSingleton<LocalStorageSource>(
    SharedPreferencesSource(getIt<SharedPreferences>())
  );
  
  getIt.registerSingletonAsync<FileStorageSource>(() async {
    return await FileStorageSource.create();
  });
  
  getIt.registerSingleton<AIApiSource>(
    AIApiSource(getIt<http.Client>())
  );

  // 仓库
  getIt.registerSingleton<AvatarRepository>(
    AvatarRepositoryImpl(getIt<Directory>())
  );
  
  getIt.registerSingleton<ChatRepository>(
    ChatRepositoryImpl(
      getIt<LocalStorageSource>(),
      getIt<AIApiSource>()
    )
  );
  
  getIt.registerSingleton<PresetRepository>(
    PresetRepositoryImpl(getIt<LocalStorageSource>())
  );
  
  getIt.registerSingleton<ApiConfigRepository>(
    ApiConfigRepositoryImpl(getIt<LocalStorageSource>())
  );
  
  getIt.registerSingleton<SettingsRepository>(
    SettingsRepositoryImpl(getIt<LocalStorageSource>())
  );

  // 用例注册
  _registerUseCases();

  // BLoC注册
  _registerBlocs();
}

/// 注册所有用例
void _registerUseCases() {
  // API配置用例
  getIt.registerSingleton<GetApiConfigs>(
    GetApiConfigs(getIt<ApiConfigRepository>())
  );
  
  getIt.registerSingleton<GetDefaultApiConfig>(
    GetDefaultApiConfig(getIt<ApiConfigRepository>())
  );
  
  getIt.registerSingleton<SaveApiConfig>(
    SaveApiConfig(getIt<ApiConfigRepository>())
  );
  
  getIt.registerSingleton<DeleteApiConfig>(
    DeleteApiConfig(getIt<ApiConfigRepository>())
  );
  
  getIt.registerSingleton<SetDefaultApiConfig>(
    SetDefaultApiConfig(getIt<ApiConfigRepository>())
  );
  
  getIt.registerSingleton<RemoveDefaultApiConfig>(
    RemoveDefaultApiConfig(getIt<ApiConfigRepository>())
  );
  
  // 头像用例
  getIt.registerSingleton<GetAvatar>(
    GetAvatar(getIt<AvatarRepository>())
  );
  
  getIt.registerSingleton<SaveAvatar>(
    SaveAvatar(getIt<AvatarRepository>())
  );
  
  getIt.registerSingleton<DeleteAvatar>(
    DeleteAvatar(getIt<AvatarRepository>())
  );
  
  // 聊天用例
  getIt.registerSingleton<GetMessages>(
    GetMessages(getIt<ChatRepository>())
  );
  
  getIt.registerSingleton<SendMessage>(
    SendMessage(getIt<ChatRepository>())
  );
  
  getIt.registerSingleton<ClearConversation>(
    ClearConversation(getIt<ChatRepository>())
  );
  
  getIt.registerSingleton<SaveMessages>(
    SaveMessages(getIt<ChatRepository>())
  );
  
  // 预设用例
  getIt.registerSingleton<GetRoles>(
    GetRoles(getIt<PresetRepository>())
  );
  
  getIt.registerSingleton<GetDefaultRole>(
    GetDefaultRole(getIt<PresetRepository>())
  );
  
  getIt.registerSingleton<SaveRole>(
    SaveRole(getIt<PresetRepository>())
  );
  
  getIt.registerSingleton<DeleteRole>(
    DeleteRole(getIt<PresetRepository>())
  );
  
  getIt.registerSingleton<SetDefaultRole>(
    SetDefaultRole(getIt<PresetRepository>())
  );
  
  getIt.registerSingleton<GetPresetTexts>(
    GetPresetTexts(getIt<PresetRepository>())
  );
  
  getIt.registerSingleton<GetDefaultPresetText>(
    GetDefaultPresetText(getIt<PresetRepository>())
  );
  
  getIt.registerSingleton<SavePresetText>(
    SavePresetText(getIt<PresetRepository>())
  );
  
  getIt.registerSingleton<DeletePresetText>(
    DeletePresetText(getIt<PresetRepository>())
  );
  
  getIt.registerSingleton<SetDefaultPresetText>(
    SetDefaultPresetText(getIt<PresetRepository>())
  );
  
  getIt.registerSingleton<RemoveDefaultPresetText>(
    RemoveDefaultPresetText(getIt<PresetRepository>())
  );
  
  // 主题用例
  getIt.registerSingleton<GetTheme>(
    GetTheme(getIt<SettingsRepository>())
  );
  
  getIt.registerSingleton<UpdateTheme>(
    UpdateTheme(getIt<SettingsRepository>())
  );
  
  getIt.registerSingleton<SetDarkMode>(
    SetDarkMode(getIt<SettingsRepository>())
  );
  
  getIt.registerSingleton<SetThemeColor>(
    SetThemeColor(getIt<SettingsRepository>())
  );

  // 添加新的用例
  getIt.registerLazySingleton(() => GetLastUsedApiConfig(getIt()));
  getIt.registerLazySingleton(() => SaveLastUsedApiConfig(getIt()));
}

/// 注册所有Bloc
void _registerBlocs() {
  getIt.registerFactory<ApiConfigBloc>(() => ApiConfigBloc(
    getApiConfigs: getIt<GetApiConfigs>(),
    getDefaultApiConfig: getIt<GetDefaultApiConfig>(),
    saveApiConfig: getIt<SaveApiConfig>(),
    deleteApiConfig: getIt<DeleteApiConfig>(),
    setDefaultApiConfig: getIt<SetDefaultApiConfig>(),
    removeDefaultApiConfig: getIt<RemoveDefaultApiConfig>(),
  ));
  
  getIt.registerFactory<AvatarBloc>(() => AvatarBloc(
    getAvatar: getIt<GetAvatar>(),
    saveAvatar: getIt<SaveAvatar>(),
    deleteAvatar: getIt<DeleteAvatar>(),
  ));
  
  getIt.registerFactory<ChatBloc>(() => ChatBloc(
    getMessages: getIt<GetMessages>(),
    sendMessage: getIt<SendMessage>(),
    clearConversation: getIt<ClearConversation>(),
    saveMessages: getIt<SaveMessages>(),
    getDefaultApiConfig: getIt<GetDefaultApiConfig>(),
    getDefaultRole: getIt<GetDefaultRole>(),
    getDefaultPresetText: getIt<GetDefaultPresetText>(),
    getLastUsedApiConfig: getIt<GetLastUsedApiConfig>(), // 添加新的依赖
    saveLastUsedApiConfig: getIt<SaveLastUsedApiConfig>(), // 添加新的依赖
  ));
  
  getIt.registerFactory<PresetBloc>(() => PresetBloc(
    getRoles: getIt<GetRoles>(),
    getDefaultRole: getIt<GetDefaultRole>(),
    saveRole: getIt<SaveRole>(),
    deleteRole: getIt<DeleteRole>(),
    setDefaultRole: getIt<SetDefaultRole>(),
    getPresetTexts: getIt<GetPresetTexts>(),
    getDefaultPresetText: getIt<GetDefaultPresetText>(),
    savePresetText: getIt<SavePresetText>(),
    deletePresetText: getIt<DeletePresetText>(),
    setDefaultPresetText: getIt<SetDefaultPresetText>(),
    removeDefaultPresetText: getIt<RemoveDefaultPresetText>(),
  ));
  
  getIt.registerFactory<ThemeBloc>(() => ThemeBloc(
    getTheme: getIt<GetTheme>(),
    updateTheme: getIt<UpdateTheme>(),
    setDarkMode: getIt<SetDarkMode>(),
    setThemeColor: getIt<SetThemeColor>(),
  ));
}
