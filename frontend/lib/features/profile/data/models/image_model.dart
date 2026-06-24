import 'package:chat_app/features/profile/domain/entities/image_entity.dart';
import 'package:chat_app/core/url.dart';

class ImageModel extends ImageEntity {
  ImageModel({required String url}) : super(url: url);

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      url: '${Url.baseUrl}${json['imageUrl']}',
    );
  }
}
