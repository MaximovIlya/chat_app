import 'package:chat_app/features/chat/domain/usecases/convert_to_formal_use_case.dart';
import 'package:chat_app/features/chat/domain/usecases/convert_to_humorous_use_case.dart';
import 'package:chat_app/features/chat/domain/usecases/convert_to_romantic_use_case.dart';
import 'package:chat_app/features/chat/domain/usecases/convert_to_slang_use_case.dart';
import 'package:chat_app/features/chat/presentation/bloc/styles_event.dart';
import 'package:chat_app/features/chat/presentation/bloc/styles_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StylesBloc extends Bloc<StylesEvent, StylesState> {
  final ConvertToFormalUseCase convertToFormalUseCase;
  final ConvertToSlangUseCase convertToSlangUseCase;
  final ConvertToHumorousUseCase convertToHumorousUseCase;
  final ConvertToRomanticUseCase convertToRomanticUseCase;
  StylesBloc({
    required this.convertToFormalUseCase,
    required this.convertToSlangUseCase,
    required this.convertToHumorousUseCase,
    required this.convertToRomanticUseCase,
  }) : super(StylesLoadingState()) {
    on<ConvertToFormalEvent>(_onConvertToFormal);
    on<ConvertToSlangEvent>(_onConvertToSlang);
    on<ConvertToHumorousEvent>(_onConvertToHumorous);
    on<ConvertToRomanticEvent>(_onConvertToRomantic);

  }

  Future<void> _onConvertToFormal(
      ConvertToFormalEvent event, Emitter<StylesState> emit) async {
    try {
      final formalMessage = await convertToFormalUseCase(event.message);
      emit(FormalMessageLoadedState(formalMessage));
    } catch (error) {
      emit(StylesErrorState('Failed to convert to formal style'));
    }
  }

  Future<void> _onConvertToSlang(
      ConvertToSlangEvent event, Emitter<StylesState> emit) async {
    try {
      final slangMessage = await convertToSlangUseCase(event.message);
      emit(FormalMessageLoadedState(slangMessage));
    } catch (error) {
      emit(StylesErrorState('Failed to convert to slang style'));
    }
  }

  Future<void> _onConvertToHumorous(
      ConvertToHumorousEvent event, Emitter<StylesState> emit) async {
    try {
      final humorousMessage = await convertToHumorousUseCase(event.message);
      emit(FormalMessageLoadedState(humorousMessage));
    } catch (error) {
      emit(StylesErrorState('Failed to convert to humorous style'));
    }
  }

  Future<void> _onConvertToRomantic(
      ConvertToRomanticEvent event, Emitter<StylesState> emit) async {
    try {
      final romanticMessage = await convertToRomanticUseCase(event.message);
      emit(FormalMessageLoadedState(romanticMessage));
    } catch (error) {
      emit(StylesErrorState('Failed to convert to romantic style'));
    }
  }
}
