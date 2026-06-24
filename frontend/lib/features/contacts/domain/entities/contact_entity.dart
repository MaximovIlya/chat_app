class ContactEntity {
  final String id;
  final String first_name;
  final String second_name;
  final String phone_number;
  final String? image;

  ContactEntity({
    required this.id,
    required this.first_name,
    required this.second_name,
    required this.phone_number,
    required this.image,
  });
}
