import 'package:flutter/material.dart';
import '../services/settings_service.dart';


class SettingsScreen extends StatefulWidget {
 static const routeName = '/settings';
 const SettingsScreen({super.key});


 @override
 State<SettingsScreen> createState() => _SettingsScreenState();
}


class _SettingsScreenState extends State<SettingsScreen> {


 Future<void> _confirmAndClearAll() async {
   final confirmed = await showDialog<bool>(
     context: context,
     builder: (ctx) => AlertDialog(
       title: const Text('Clear all data'),
       content: const Text(
         'This will remove all items and categories from the app (mock). Continue?',
       ),
       actions: [
         TextButton(
           onPressed: () => Navigator.of(ctx).pop(false),
           child: const Text('Cancel'),
         ),
         ElevatedButton(
           onPressed: () => Navigator.of(ctx).pop(true),
           child: const Text('Clear'),
         ),
       ],
     ),
   );


   if (confirmed == true) {
     // Frontend-only: show snackbar. Replace with DB clear logic if desired.
     ScaffoldMessenger.of(
       context,
     ).showSnackBar(const SnackBar(content: Text('All data cleared (mock)')));
   }
 }


 Future<void> _confirmAndReset() async {
   final confirmed = await showDialog<bool>(
     context: context,
     builder: (ctx) => AlertDialog(
       title: const Text('Reset app'),
       content: const Text(
         'This will reset settings to defaults (mock). Continue?',
       ),
       actions: [
         TextButton(
           onPressed: () => Navigator.of(ctx).pop(false),
           child: const Text('Cancel'),
         ),
         ElevatedButton(
           onPressed: () => Navigator.of(ctx).pop(true),
           child: const Text('Reset'),
         ),
       ],
     ),
   );


   if (confirmed == true) {
    await SettingsService.instance.resetToDefaults();
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Settings reset to defaults (mock)')),
     );
   }
 }


 void _showAbout() {
   showAboutDialog(
     context: context,
     applicationName: 'Smart Grocery List',
     applicationVersion: '1.0.0',
     applicationLegalese: '© Your Company',
     children: [
       const Padding(
         padding: EdgeInsets.only(top: 8.0),
         child: Text('A lightweight grocery list app — frontend demo.'),
       ),
     ],
   );
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: const Text('Settings')),
     body: ListView(
       padding: const EdgeInsets.all(12),
       children: [
        ValueListenableBuilder<bool>(
          valueListenable: SettingsService.instance.darkMode,
          builder: (ctx, dark, _) {
            return SwitchListTile(
              title: const Text('Dark mode'),
              value: dark,
              onChanged: (v) => SettingsService.instance.setDarkMode(v),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: SettingsService.instance.notifications,
          builder: (ctx, n, _) {
            return SwitchListTile(
              title: const Text('Notifications'),
              value: n,
              onChanged: (v) => SettingsService.instance.setNotifications(v),
            );
          },
        ),
         const Divider(),
         ListTile(
           leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
           title: const Text('Clear All'),
           subtitle: const Text('Remove all app data (mock)'),
           onTap: _confirmAndClearAll,
         ),
         ListTile(
           leading: const Icon(Icons.restore, color: Colors.orange),
           title: const Text('Reset Data'),
           subtitle: const Text('Reset settings to defaults (mock)'),
           onTap: _confirmAndReset,
         ),
         const Divider(),
         ListTile(
           leading: const Icon(Icons.info_outline),
           title: const Text('About App'),
           subtitle: const Text('Version and legal info'),
           onTap: _showAbout,
         ),
       ],
     ),
   );
 }
}
