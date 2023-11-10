import 'package:flutter/material.dart';
import 'package:stew_art_player/helper/variable_holder.dart';

class CustomNetworkImage extends StatefulWidget {
  final bool isHighRes;

  const CustomNetworkImage({super.key, required this.isHighRes});

  @override
  State<CustomNetworkImage> createState() => CustomNetworkImageState();
}

class CustomNetworkImageState extends State<CustomNetworkImage> {

  @override
  void initState() {
    super.initState();
    Holder.newThumbnail.addListener(saveSetState);
  }

  @override
  void dispose() {
    super.dispose();
    Holder.newThumbnail.removeListener(saveSetState);
  }

  @override
  Widget build(BuildContext context) {
    if(Holder.handler.currentTrack != null) {
      String url = Holder.handler.currentTrack!.thumbnailURLHR;
      if(widget.isHighRes) url = url.replaceAll('hqdefault', 'maxresdefault');
      return Container(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Image.network(url,
          width: double.infinity,
          opacity: AlwaysStoppedAnimation(widget.isHighRes? 1.0 : 0.5),
          fit: BoxFit.cover,
          errorBuilder: (context, object, stacktrace) {
            return Image.asset('assets/default_image.png');
          },
          loadingBuilder: (context, temp, event) {
            return AnimatedSwitcher(duration: const Duration(milliseconds: 200), reverseDuration: const Duration(milliseconds: 200), child: event == null? temp : Container(color: Colors.transparent,),);
          },
        ),
      );
    }
    else {
      return const SizedBox();
    }
  }

  saveSetState() {
    try {
      setState(() {});
    } catch (_) {}
  }

}