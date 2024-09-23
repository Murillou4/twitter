import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/controllers/database_controller.dart';
import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/widgets/user_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final listeningController = Provider.of<DatabaseController>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(
          color: AppColors.white,
        ),
        title: TextField(
          controller: searchController,
          style: const TextStyle(
            color: AppColors.white,
          ),
          onChanged: (value) async {
            if (value.isNotEmpty) {
              await listeningController.searchUsers(value);
            }
          },
          decoration: const InputDecoration(
            hintText: 'Pesquisar usuários',
            hintStyle: TextStyle(
              color: AppColors.lightGrey,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
      body: listeningController.searchResults.isEmpty
          ? const Center(
              child: Text(
                'Nenhum usuário encontrado',
                style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 18,
                ),
              ),
            )
          : ListView.separated(
              itemBuilder: (context, index) {
                return UserCard(
                  user: listeningController.searchResults[index],
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.lightGrey,
                thickness: 0.5,
              ),
              itemCount: listeningController.searchResults.length,
            ),
    );
  }
}
