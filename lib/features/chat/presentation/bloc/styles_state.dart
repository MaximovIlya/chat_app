abstract class StylesState {}


class FormalMessageLoadedState extends StylesState {
  final String message;
  
  FormalMessageLoadedState(this.message);
}

class StylesLoadingState extends StylesState {

}

class StylesErrorState extends StylesState {
  final String message;
  StylesErrorState(this.message);
}


class SlangMessageLoadedState extends StylesState {
  final String message;
  
  SlangMessageLoadedState(this.message);
}

class HumorousMessageLoadedState extends StylesState {
  final String message;
  
  HumorousMessageLoadedState(this.message);
}

class RomanticMessageLoadedState extends StylesState {
  final String message;
  
  RomanticMessageLoadedState(this.message);
}
