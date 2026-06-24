import 'package:chat_app/core/theme.dart';
import 'package:chat_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:chat_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:chat_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:chat_app/features/profile/presentation/pages/pick_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey _birthTileKey = GlobalKey();
  final storage = FlutterSecureStorage();

  String first_name = '';
  String second_name = '';
  String phone_number = '';
  String birth = '';
  String username = '';
  String userId = '';

  getInfo() async {
    username = await storage.read(key: "username") ?? '';
    userId = await storage.read(key: "userId") ?? '';
    birth = await storage.read(key: "birth") ?? '';
    first_name = await storage.read(key: "first_name") ?? '';
    second_name = await storage.read(key: "second_name") ?? '';
    phone_number = await storage.read(key: "phone_number") ?? '';
    final formattedNumber = customFormatPhoneNumber(phone_number);
    setState(() {
      first_name = first_name;
      second_name = second_name;
      phone_number = formattedNumber;
      birth = birth;
      username = username;
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
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        final storage = FlutterSecureStorage();
        if (state is BirthUpdated) {
          await storage.write(key: "birth", value: state.birth);
          setState(() {
            birth = state.birth;
          });
          context.read<ProfileBloc>().add(FetchImage(userId));
        } else if (state is BirthRemoved) {
          await storage.delete(key: "birth");
          setState(() {
            birth = '';
          });
          context.read<ProfileBloc>().add(FetchImage(userId));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                Container(
                  height: 100,
                  padding: EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 14),
                        child: GestureDetector(
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
                                  radius: 45,
                                );
                              }
                              return CircleAvatar(
                                radius: 45,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Text('$first_name $second_name',
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
                Container(
                  color: DefaultColors.menu,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(17, 10, 0, 0),
                        child: Text("Info",
                            style: TextStyle(
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 17)),
                      ),
                      Material(
                        color: DefaultColors.menu,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(phone_number,
                                  style: Theme.of(context).textTheme.titleMedium),
                              subtitle:
                                  Text('Mobile', style: TextStyle(color: Colors.grey)),
                              onTap: () {},
                            ),
                            ListTile(
                              title: Text(username,
                                  style: Theme.of(context).textTheme.titleMedium),
                              subtitle:
                                  Text('Username', style: TextStyle(color: Colors.grey)),
                              onTap: () {},
                            ),
                            ListTile(
                              key: _birthTileKey,
                              title: Text(
                                  birth == ''
                                      ? 'Select date of birth'
                                      : birth,
                                  style: Theme.of(context).textTheme.titleMedium),
                              subtitle: Text('Date of Birth',
                                  style: TextStyle(color: Colors.grey)),
                              onTap: () async {
                                final RenderBox renderBox = _birthTileKey
                                    .currentContext!
                                    .findRenderObject() as RenderBox;
                                final Offset offset =
                                    renderBox.localToGlobal(Offset.zero);

                                final selected = await showMenu<String>(
                                  color: DefaultColors.changeInfo,
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    offset.dx,
                                    offset.dy + renderBox.size.height,
                                    offset.dx + renderBox.size.width,
                                    offset.dy + renderBox.size.height + 100,
                                  ),
                                  items: [
                                    PopupMenuItem<String>(
                                      value: 'change',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, color: Colors.grey),
                                          SizedBox(width: 15),
                                          Text('Change',
                                              style: GoogleFonts.alegreyaSans(
                                                  fontSize:
                                                      FontSizes.standartUp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'remove',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline, color: Colors.red),
                                          SizedBox(width: 15),
                                          Text('Remove',
                                              style: GoogleFonts.alegreyaSans(
                                                  fontSize:
                                                      FontSizes.standartUp,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                );

                                if (selected == 'remove') {
                                  context.read<ProfileBloc>().add(RemoveBirth());
                                } else if (selected == 'change') {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.lightBlue,
                                            onPrimary: Colors.white,
                                            onSurface: Colors.white,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.lightBlue,
                                              textStyle: GoogleFonts.alegreyaSans(),
                                            ),
                                          ),
                                          datePickerTheme: DatePickerThemeData(
                                            backgroundColor: DefaultColors.menu,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            headerBackgroundColor:
                                                DefaultColors.menu,
                                            headerForegroundColor: Colors.white,
                                            dayBackgroundColor:
                                                MaterialStateProperty.resolveWith(
                                                    (states) {
                                              if (states.contains(
                                                  MaterialState.selected)) {
                                                return Colors.lightBlue;
                                              }
                                              return null;
                                            }),
                                            dayForegroundColor:
                                                MaterialStateProperty.resolveWith(
                                                    (states) {
                                              return Colors.white;
                                            }),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedDate != null) {
                                    final formatted =
                                        '${pickedDate.day.toString().padLeft(2, '0')}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.year}';

                                    context
                                        .read<ProfileBloc>()
                                        .add(UpdateBirth(formatted));
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 70,
              left: MediaQuery.of(context).size.width - 80,
              child: PickImage(),
            ),
          ],
        ),
      ),
    );
  }
}
