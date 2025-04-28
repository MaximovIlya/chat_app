abstract class StylesEvent {}

class ConvertToFormalEvent extends StylesEvent {
  final String message;
  ConvertToFormalEvent(this.message);
}

class ConvertToSlangEvent extends StylesEvent {
  final String message;
  ConvertToSlangEvent(this.message);
}

class ConvertToHumorousEvent extends StylesEvent {
  final String message;
  ConvertToHumorousEvent(this.message);
}

class ConvertToRomanticEvent extends StylesEvent {
  final String message;
  ConvertToRomanticEvent(this.message);
}