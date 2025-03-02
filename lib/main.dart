import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'presentation/blocs/theme/theme_bloc.dart' as theme;
import 'presentation/blocs/api_config/api_config_bloc.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/blocs/preset/preset_bloc.dart';
import 'presentation/blocs/avatar/avatar_bloc.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/chat/chat_page.dart';
import 'presentation/pages/api_config/api_config_page.dart';
import 'presentation/pages/preset/role_management_page.dart';
import 'presentation/pages/settings/settings_page.dart';
import 'presentation/pages/about/about_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化依赖注入
  await setupServiceLocator();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<theme.ThemeBloc>(
          create: (context) => getIt<theme.ThemeBloc>()..add(theme.LoadThemeEvent()),
        ),
        BlocProvider<ApiConfigBloc>(
          create: (context) => getIt<ApiConfigBloc>()..add(LoadApiConfigsEvent()),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => getIt<ChatBloc>()..add(LoadMessagesEvent()),
        ),
        BlocProvider<PresetBloc>(
          create: (context) => getIt<PresetBloc>()..add(LoadPresetsEvent()),
        ),
        BlocProvider<AvatarBloc>(
          create: (context) => getIt<AvatarBloc>()..add(LoadAvatarEvent()),
        ),
      ],
      child: BlocBuilder<theme.ThemeBloc, theme.ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'AI学习助手',
            theme: state.themeData,
            initialRoute: '/',
            routes: {
              '/': (context) => HomePage(),
              '/chat': (context) => const ChatPage(), // 确保这个路由正确设置
              '/settings': (context) => const SettingsPage(),
              '/api_configs': (context) => const ApiConfigPage(),
              '/roles': (context) => const RoleManagementPage(),
              '/about': (context) => const AboutPage(),
            },
          );
        },
      ),
    );
  }
}
