import 'package:chat_app/core/theme.dart';
import 'package:chat_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:chat_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:chat_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  String first_name = '';
  String second_name = '';
  String phone_number = '';
  String userId = '';

  getInfo() async {
    final storage = FlutterSecureStorage();
    first_name = await storage.read(key: "first_name") ?? '';
    second_name = await storage.read(key: "second_name") ?? '';
    phone_number = await storage.read(key: "phone_number") ?? '';
    userId = await storage.read(key: 'userId') ?? '';
    final formattedNumber = customFormatPhoneNumber(phone_number);
    setState(() {
      first_name = first_name;
      second_name = second_name;
      phone_number = formattedNumber;
      userId = userId;
    });
    if (!mounted) return;
    BlocProvider.of<ProfileBloc>(context).add(FetchImage(userId));
  }

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  String customFormatPhoneNumber(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 11) {
      return '+${cleaned[0]} (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)}-${cleaned.substring(7, 9)}-${cleaned.substring(9, 11)}';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: DefaultColors.menu,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 162,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 5),
              color: DefaultColors.menuHeader,
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            if (state is ProfileLoading) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is ImageLoaded) {
                              return CircleAvatar(
                                backgroundImage: NetworkImage(state.image.url),
                                radius: 30,
                              );
                            }
                            return CircleAvatar(
                              radius: 30,
                            );
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.sunny,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Text(
                    '$first_name $second_name',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    phone_number,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle_outlined),
            title: Text(
              'My profile',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              Navigator.pushNamed(context, '/profilePage');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.people_outline_rounded,
            ),
            title: Text(
              'New Group',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              // Действие при нажатии
            },
          ),
          ListTile(
            leading: Icon(
              Icons.person_outlined,
            ),
            title: Text(
              'Contacts',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              // Действие при нажатии
            },
          ),
        ],
      ),
    );
  }
}
