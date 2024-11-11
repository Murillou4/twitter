import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/app/twitter/pages/profile/profile.dart';
import 'package:twitter/app/twitter/providers/database_provider.dart';

import 'package:twitter/app/core/app_colors.dart';
import 'package:twitter/app/twitter/widgets/user_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DatabaseProvider>(context);
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
              await listeningProvider.searchUsers(value);
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
      body: listeningProvider.searchResults.isEmpty
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
                  user: listeningProvider.searchResults[index],
                  onTap: () async {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            Profile(
                          user: listeningProvider.searchResults[index],
                        ),
                        transitionDuration:
                            Duration.zero, // Duração da animação
                        reverseTransitionDuration:
                            Duration.zero, // Duração da animação ao voltar
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.lightGrey,
                thickness: 0.5,
              ),
              itemCount: listeningProvider.searchResults.length,
            ),
    );
  }
}