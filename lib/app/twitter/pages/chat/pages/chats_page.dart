import 'package:flutter/material.dart';

import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/models/chat.dart';

import 'package:twitter/app/twitter/services/database_service.dart';
import 'package:twitter/app/twitter/widgets/chat_card.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'C H A T S',
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: StreamBuilder<List<Chat>>(
        stream: _db.getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.white,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhum chat encontrado',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => ChatCard(
                chat: snapshot.data![index],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
