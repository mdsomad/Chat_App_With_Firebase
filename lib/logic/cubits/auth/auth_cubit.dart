import 'dart:async';
import 'dart:developer';

import 'package:chat_app_with_firebase/data/repositories/auth_repository.dart';
import 'package:chat_app_with_firebase/data/services/service_locator.dart';
import 'package:chat_app_with_firebase/logic/cubits/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState()) {
    _init();
  }
//TODO: �� 👇 Implement _init State Management function (user authenticated)
  void _init() {
    emit(state.copyWith(status: AuthStatus.initial));

    _authStateSubscription =
        _authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          //? 👇 getUserData function called
          final userData = await _authRepository.getUserData(user.uid);
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: userData,
          ));
        } catch (e) {
          emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
        }
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        ));
      }
    });
  }

//TODO: �� 👇 Implement signIn State Management function
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      //? �� 👇 signIn function called
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

//TODO: �� 👇 Implement signUp State Management function
  Future<void> signUp({
    required String email,
    required String username,
    required String fullName,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      //? �� 👇 SignUp function called
      final user = await _authRepository.signUp(
          fullName: fullName,
          username: username,
          email: email,
          phoneNumber: phoneNumber,
          password: password);

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

  //TODO: �� 👇 Implement & create SignOut State Management function 
  Future<void> signOut() async {
    try {
      log(getIt<AuthRepository>().currentUser?.uid ?? "asasa");
      await _authRepository.singOut();
      log(getIt<AuthRepository>().currentUser?.uid ?? "asasa");
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }
}
