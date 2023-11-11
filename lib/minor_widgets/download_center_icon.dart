import 'package:flutter/material.dart';
import 'package:stew_art_player/helper/variable_holder.dart';

class DownloadCenterIcon extends StatefulWidget {

  const DownloadCenterIcon({super.key});

  @override
  State<DownloadCenterIcon> createState() => DownloadCenterIconState();
}

class DownloadCenterIconState extends State<DownloadCenterIcon>{

  @override
  void initState() {
    super.initState();
    Holder.newDownload.addListener(saveSetState);
  }

  @override
  void dispose() {
    super.dispose();
    Holder.newDownload.removeListener(saveSetState);
  }

  void saveSetState() {
    try {
      setState(() {});
    } catch (_){}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/download');
            },
            icon: const Icon(Icons.download),
            iconSize: 35,
          ),
        ),
        if(Holder.downloads.isNotEmpty) Align(
          alignment: Alignment.topLeft,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            radius: 11,
            child: Text('${Holder.downloads.length}', style: Theme.of(context).textTheme.titleMedium,),
          ),
        ),
      ],
    );
  }
}