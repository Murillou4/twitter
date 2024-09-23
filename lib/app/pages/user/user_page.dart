import 'package:flutter/material.dart';
import 'package:twitter/app/models/user.dart';

class UserPage extends StatefulWidget {
  const UserPage({
    super.key,
    required this.user,
  });
  final UserProfile user;
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
