import 'package:flutter/material.dart';
import 'package:the_wall/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOutTap;
  const MyDrawer(
      {super.key, required this.onProfileTap, required this.onSignOutTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //header
              const DrawerHeader(
                  child: Icon(
                Icons.person,
                size: 100,
                color: Colors.white,
              )),
              //home
              MyListTile(
                icon: Icons.home_filled,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),
              //profile
              MyListTile(
                icon: Icons.person,
                text: 'P R O F I L E',
                onTap: () => onProfileTap!(),
              ),
            ],
          ),
          
          //logout
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.logout_rounded,
              text: 'L O G O U T',
              onTap: () => onSignOutTap!(),
            ),
          )
        ],
      ),
    );
  }
}
