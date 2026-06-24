import 'package:chat_app/features/profile/domain/usecases/add_image_use_case.dart';
import 'package:chat_app/features/profile/domain/usecases/fetch_image_use_case.dart';
import 'package:chat_app/features/profile/domain/usecases/remove_birth_use_case.dart';
import 'package:chat_app/features/profile/domain/usecases/update_birth_use_case.dart';
import 'package:chat_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:chat_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AddImageUseCase addImageUseCase;
  final FetchImageUseCase fetchImageUseCase;
  final UpdateBirthUseCase updateBirthUseCase;
  final RemoveBirthUseCase removeBirthUseCase;

  ProfileBloc(
      {required this.addImageUseCase,
      required this.fetchImageUseCase,
      required this.updateBirthUseCase,
      required this.removeBirthUseCase})
      : super(ProfileInitial()) {
    on<AddImage>(_onAddImage);
    on<FetchImage>(_onFetchImage);
    on<UpdateBirth>(_onUpdateBirth);
    on<RemoveBirth>(_onRemoveBirth);
  }

  Future<void> _onAddImage(AddImage event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await addImageUseCase(imageFile: event.imageFile);
      emit(ImageAdded());
      add(FetchImage(event.userId));
    } catch (error) {
      emit(ProfileError('Failed to upload image'));
    }
  }

  Future<void> _onFetchImage(
      FetchImage event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final image = await fetchImageUseCase(userId: event.userId);
      emit(ImageLoaded(image));
    } catch (error) {
      print(error);
      emit(ProfileError('Failed to fetch image'));
    }
  }

  Future<void> _onUpdateBirth(
      UpdateBirth event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await updateBirthUseCase(birth: event.birth);
      emit(BirthUpdated(event.birth));
    } catch (error) {
      emit(ProfileError('Failed to update birth'));
    }
  }

  Future<void> _onRemoveBirth(
      RemoveBirth event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await removeBirthUseCase();
      emit(BirthRemoved());
    } catch (error) {
      emit(ProfileError('Failed to remove birth'));
    }
  }
}
