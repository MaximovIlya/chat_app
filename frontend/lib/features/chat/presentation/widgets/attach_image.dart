import 'dart:io';

import 'package:chat_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:chat_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

class PickImage extends StatefulWidget {
  const PickImage({super.key});

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  final storage = FlutterSecureStorage();
  String userId = '';

  

  getUserId() async {
    userId = await storage.read(key: "userId") ?? '';
    setState(() {
      userId = userId;
    });
  }

  @override
  void initState() {
    getUserId();
    super.initState();
  }
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      if (!mounted) return;

      BlocProvider.of<ProfileBloc>(context).add(AddImage(imageFile, userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _pickImage(ImageSource.gallery);
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        fixedSize: const Size(60, 60),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.lightBlue,
        elevation: 2,
      ),
      child: const Icon(
        CommunityMaterialIcons.camera_plus_outline,
        color: Colors.white,
        size: 35,
      ),
    );
  }
}
