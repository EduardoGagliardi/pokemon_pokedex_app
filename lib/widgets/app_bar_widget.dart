import 'package:flutter/material.dart';
import 'package:pokemon_pokedex_app/screens/favorites_screen.dart';
import 'package:pokemon_pokedex_app/widgets/team_overlay.dart';

class AppBarWidget extends StatelessWidget  implements PreferredSizeWidget {
  final String title;
  final bool? isFavButtonPresent;
  final bool? isTeamsButtonPresent;

  const AppBarWidget({
    super.key, 
    required this.title,
    this.isFavButtonPresent,
    this.isTeamsButtonPresent,
    });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (isFavButtonPresent ?? true)
        IconButton(
          icon: const Icon(Icons.favorite), 
          onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FavoritesScreen(),
            ),
          );
        }),
        if (isTeamsButtonPresent ?? true)
        IconButton(
          icon: const Icon(Icons.group),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => const TeamOverlay(),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}