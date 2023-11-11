import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:stew_art_player/dto/download_dto.dart';
import 'package:stew_art_player/helper/variable_holder.dart';
import 'dto/theme_dto.dart';
import 'helper/test_stream.dart' as test;

class DownloadCenter extends StatefulWidget {

  const DownloadCenter({super.key});

  @override
  State<DownloadCenter> createState() => DownloadCenterState();
}

class DownloadCenterState extends State<DownloadCenter>{

  @override
  void initState() {
    super.initState();
    if(Holder.downloads.isEmpty) Holder.downloads.add(DownloadDTO(name: "Test", stream: test.testStream(), id: "id"));
    Holder.newDownload.addListener(saveSetState);
  }

  @override
  void dispose() {
    super.dispose();
    Holder.newDownload.removeListener(saveSetState);
  }

  @override
  Widget build(BuildContext context) {
    ThemeDTO theme = ThemeDTO.themes[Holder.theme.value];
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Download-Center',
            style: ThemeDTO.getTitleLarge(),
          ),
          backgroundColor: theme.primaryColor,
        ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.secondaryColor, theme.primaryColor]
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder(
                  future: buildStreamViews(theme),
                  builder: (context, snapshot) {
                    Widget child;

                    if(snapshot.hasData) {
                      child = ListView(children: snapshot.data!,);
                    } else {
                      child = Container(color: Colors.transparent,);
                    }

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: child,
                    );
                  },
                ),
              ),
            )
          ],
        ),
      )
    );
  }

  Future<List<Widget>> buildStreamViews(ThemeDTO theme) async {
    List<Widget> widgets = [];
    for(DownloadDTO downloadDTO in Holder.downloads) {

      bool isDone = await downloadDTO.stream.isEmpty;

      widgets.add(
        Container(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(35.0), bottomRight: Radius.circular(35.0), topRight: Radius.circular(15.0), bottomLeft: Radius.circular(15.0)),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.textColor.withOpacity(0.4), theme.primaryColor.withOpacity(0.2)]
            ),
            boxShadow: [
              BoxShadow(color: theme.primaryColor.withOpacity(0.25), blurRadius: 10, offset: const Offset(-2.0, 2.0))
            ],
          ),
          child: StreamBuilder(
            initialData: isDone? 1.0 : 0.0,
            stream: downloadDTO.stream,
            builder: (context, snapshot) {
              if(!isDone) isDone = ConnectionState.done == snapshot.connectionState;
              return Row(
                children: [
                  Expanded(
                      flex: 12,
                      child: SizedBox(
                        height: 10,
                        child: LinearProgressIndicator(
                          value: snapshot.data,
                          color: isDone? Colors.green : Colors.white,
                          backgroundColor: Colors.black,
                        ),
                      )
                  ),
                  const SizedBox(width: 5,),
                  if(snapshot.data != null) AnimatedFlipCounter(value: snapshot.data! * 100, suffix: '%',),
                  const Spacer(flex: 1,),
                  Expanded(
                    flex: 12,
                    child: SizedBox(height: 80, child: Align(alignment: Alignment.centerLeft,child: Text(downloadDTO.name, maxLines: 2, style: ThemeDTO.getBodyMedium(),),),),
                  ),
                ],
              );
            },
          ),
        )
      );
      widgets.add(const SizedBox(height: 10,));
    }
    return widgets;
  }

  void saveSetState() {
    try{
      setState(() {});
    } catch(_){}
  }
}