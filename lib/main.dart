import 'package:chat_app_with_firebase/config/theme/app_theme.dart';
import 'package:chat_app_with_firebase/data/repositories/chat_repository.dart';
import 'package:chat_app_with_firebase/data/services/service_locator.dart';
import 'package:chat_app_with_firebase/logic/cubits/auth/auth_cubit.dart';
import 'package:chat_app_with_firebase/logic/cubits/auth/auth_state.dart';
import 'package:chat_app_with_firebase/logic/observer/app_life_cycle_observer.dart';
import 'package:chat_app_with_firebase/presentation/home/home_screen.dart';
import 'package:chat_app_with_firebase/presentation/screens/auth/login_screen.dart';
import 'package:chat_app_with_firebase/router/app_router.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
// ...

  await setupServiceLocator();

  bool isDevicePreviewDebugMode = false;

  if (kDebugMode) {
    // isDevicePreviewDebugMode = true;
    // isDevicePreviewDebugMode = false;
  }
  runApp(
    DevicePreview(
      enabled: isDevicePreviewDebugMode,
      // enabled: false,

      tools: const [
        ...DevicePreview.defaultTools,
        // CustomPlugin(),
      ],
      builder: (context) => MyApp(),
    ),

    //   MyApp(
    //   theme: currentTheme,
    // )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLifeCycleObserver _lifeCycleObserver;

  @override
  void initState() {
    getIt<AuthCubit>().stream.listen((state) {
      if (state.status == AuthStatus.authenticated && state.user != null) {
        _lifeCycleObserver = AppLifeCycleObserver(
            userId: state.user!.uid, chatRepository: getIt<ChatRepository>());
      }
      WidgetsBinding.instance.addObserver(_lifeCycleObserver);
    });
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 👇 Unfocus the keyboard when a user taps anywhere on the screen.
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Messenger App',
        navigatorKey: getIt<AppRouter>().navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthCubit, AuthState>(
          bloc: getIt<AuthCubit>(),
          builder: (context, state) {
            if (state.status == AuthStatus.initial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == AuthStatus.authenticated) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
