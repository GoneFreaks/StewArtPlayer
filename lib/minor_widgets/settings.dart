import 'package:flutter/material.dart';
import '../dto/theme_dto.dart';
import '../helper/db_loader.dart' as db;
import '../helper/variable_holder.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 272,
      width: 300,
      child: Column(
        children: [
          Text("Einstellungen", style: ThemeDTO.getTitleLarge(),),
          const Divider(color: Colors.white,),
          SwitchListTile(
            title: Text("Internetnutzung", style: ThemeDTO.getBodyMedium(),),
            value: Holder.useInternet.value,
            onChanged: (value) {
              setState(() {
                Holder.useInternet.value = value;
                db.writeUseInternet(value);
              });
            },
          ),
          SwitchListTile(
            title: Text("Animierter Text", style: ThemeDTO.getBodyMedium(),),
            value: Holder.animateText.value,
            onChanged: (value) {
              setState(() {
                Holder.animateText.value = value;
                db.writeAnimateText(value);
              });
            },
          ),
          SwitchListTile(
            title: Text("Auto Titelkürzung", style: ThemeDTO.getBodyMedium(),),
            value: Holder.shortenText.value,
            onChanged: (value) {
              setState(() {
                Holder.shortenText.value = value;
                db.writeShortenText(value);
              });
            },
          ),
          SwitchListTile(
            title: Text("Zeige Lautstärke", style: ThemeDTO.getBodyMedium(),),
            value: Holder.showVolume.value,
            onChanged: (value) {
              setState(() {
                Holder.showVolume.value = value;
                db.writeShowVolume(value);
              });
            },
          ),
        ],
      ),
    );
  }
}