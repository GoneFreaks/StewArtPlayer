import 'dart:async';

import 'package:flutter/material.dart';

import '../helper/variable_holder.dart';

class VolumeDisplayer extends StatefulWidget {
  const VolumeDisplayer({super.key});

  @override
  State<VolumeDisplayer> createState() => VolumeDisplayerState();
}

class VolumeDisplayerState extends State<VolumeDisplayer> {
  double volume = 0;
  bool displayVolume = Holder.showVolume.value;
  int lastUpdate = 0;
  bool initialBuild = true;

  @override
  void initState() {
    super.initState();
    Holder.volume.addListener(volumeListener);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void volumeListener() async {
    if(!initialBuild && Holder.showVolume.value && (volume * 15).round() != (Holder.volume.value * 15).round()) {
      int currentLastUpdate = DateTime.now().millisecondsSinceEpoch;
      lastUpdate = currentLastUpdate;
      setState(() {
        displayVolume = true;
        volume = Holder.volume.value;
      });
      await Future.delayed(const Duration(seconds: 3));
      if (currentLastUpdate == lastUpdate && context.mounted) {
        setState(() {
          displayVolume = false;
        });
      }
    }
    if(initialBuild) initialBuild = false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: (displayVolume && !initialBuild)? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: getVolumeBars(),
          ),
          const SizedBox(height: 5,),
          CircleAvatar(
            backgroundColor: Colors.black54,
            radius: 18,
            child: Text('${(volume * 15).round()}', style: const TextStyle(color: Colors.white, fontSize: 18),),
          )
        ],
      ),
    );
  }

  List<Widget> getVolumeBars() {

    bool fullVolume = (Holder.volume.value * 15).round() == 15;

    List<Widget> widgets = [];

    widgets.add(Container(
      decoration: const BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.all(Radius.circular(40)),
      ),
      height: 15 * 15,
      width: 16,
    ),);

    widgets.add(Container(
      height: (volume * 15).round() * 15,
      width: 16,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: const Radius.circular(40.0), bottomRight: const Radius.circular(40.0), topRight: Radius.circular(fullVolume? 40.0 : 0.0), topLeft: Radius.circular(fullVolume? 40.0 : 0.0)),
      ),
    ),);

    return widgets;
  }

}
