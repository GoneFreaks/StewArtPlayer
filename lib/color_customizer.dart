import 'package:flutter/material.dart';
import 'package:stew_art_player/dto/theme_dto.dart';
import 'package:stew_art_player/minor_widgets/page_position.dart';
import '../helper/db_loader.dart' as db;

import '../helper/variable_holder.dart';

class ColorCustomizer extends StatefulWidget {
  const ColorCustomizer({super.key});

  @override
  State<ColorCustomizer> createState() => ColorCustomizerState();
}

class ColorCustomizerState extends State<ColorCustomizer> {

  static const BorderSide borderSide = BorderSide(color: Colors.black, width: 3);
  static const int appBarFlex = 5;
  static const int bodyFlex = 22;
  static const int playerFlex = 6;
  static const double circleRadius = 13;

  bool showCheck = false;

  @override
  void dispose(){
    super.dispose();
    Holder.theme.removeListener(saveSetState);
  }

  @override
  void initState(){
    super.initState();
    Holder.theme.addListener(saveSetState);
    Holder.currentPosition.value = Holder.theme.value;
  }

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: Holder.theme.value);
    ThemeDTO currentTheme = ThemeDTO.themes[Holder.theme.value];
    return Scaffold(
        backgroundColor: currentTheme.primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Thema ändern',
            style: ThemeDTO.getTitleLarge(),
          ),
          backgroundColor: currentTheme.primaryColor,
        ),
        body: Column(
          children: [
            Container(
              height: 3,
              color: currentTheme.textColor.withOpacity(0.3),
            ),
            SizedBox(
              height: 35,
              child: PagePosition(
                controller: controller,
              ),
            ),
            Container(
              height: 3,
              color: currentTheme.textColor.withOpacity(0.3),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ThemeDTO.themes[Holder.theme.value].secondaryColor,
                        ThemeDTO.themes[Holder.theme.value].primaryColor
                      ]),
                ),
                child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ThemeDTO.themes[Holder.theme.value].secondaryColor,
                            ThemeDTO.themes[Holder.theme.value].primaryColor
                          ]),
                      image: const DecorationImage(
                          image: AssetImage('assets/phone-black.png'),
                          fit: BoxFit.cover),
                    ),
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(60, 60, 56, 80),
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: controller,
                              itemCount: ThemeDTO.themes.length,
                              itemBuilder: (context, index) {
                                ThemeDTO current = ThemeDTO.themes[index];
                                return InkWell(
                                  onTap: () {
                                    showFeedback();
                                    Holder.theme.value = index;
                                    db.writeTheme(index);
                                  },
                                  child: getFakeAppView(
                                      current, index, currentTheme),
                                );
                              },
                              onPageChanged: (index) {
                                Holder.currentPosition.value = index;
                              },
                            ),
                            AnimatedCrossFade(
                              firstChild: const Align(
                                  alignment: Alignment.topCenter,
                                  child: CircleAvatar(
                                    radius: 200,
                                    backgroundColor: Colors.black38,
                                    child: Icon(Icons.check,
                                        color: Colors.green, size: 300),
                                  )),
                              firstCurve: Curves.fastEaseInToSlowEaseOut,
                              secondChild:
                                  const SizedBox(width: 400, height: 400),
                              secondCurve: Curves.fastEaseInToSlowEaseOut,
                              crossFadeState: showCheck
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              duration: const Duration(milliseconds: 500),
                            ),
                          ],
                        ))),
              ),
            ),
          ],
        ));
  }

  Widget colorAsCircle(Color color) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  void saveSetState() {
    try {
      if(context.mounted) setState(() {});
    } catch (_) {}

  }

  Widget getFakeAppView(ThemeDTO current, int index, ThemeDTO currentTheme) {
    return SizedBox(
      child: Column(
        children: [
          Expanded(
            flex: appBarFlex,
            child: Container(
                color: current.primaryColor,
                child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        const SizedBox(width: 15,),
                        Text('StewArt', style: TextStyle(color: current.textColor, fontWeight: FontWeight.bold, fontSize: 16),),
                        const Spacer(),
                        Icon(Icons.color_lens_outlined, color: current.textColor, size: 25,),
                        const SizedBox(width: 10,),
                        Icon(Icons.settings, color: current.textColor, size: 25,),
                        const SizedBox(width: 10,),
                      ],
                    ),
                    const SizedBox(height: 15,),
                    Row(
                      children: [
                        const SizedBox(width: 25,),
                        const Column(
                          children: [
                            Icon(Icons.wifi, color: Color.fromARGB(255, 100, 100, 100), size: 16,),
                            Text('Internet', style: TextStyle(color: Color.fromARGB(255, 100, 100, 100), fontSize: 10),),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            Icon(Icons.folder, color: current.textColor, size: 16,),
                            Text('Lokal', style: TextStyle(color: current.textColor, fontSize: 10),),
                          ],
                        ),
                        const Spacer(),
                        const Column(
                          children: [
                            Icon(Icons.playlist_play, color: Color.fromARGB(255, 100, 100, 100), size: 16,),
                            Text('Ansehen', style: TextStyle(color: Color.fromARGB(255, 100, 100, 100), fontSize: 10),),
                          ],
                        ),
                        const SizedBox(width: 25,),
                      ],
                    )
                  ],
                )
            ),
          ),
          Container(
            height: 3,
            color: Colors.white30,
          ),
          Expanded(
            flex: bodyFlex,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [current.secondaryColor, current.primaryColor]),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sort,
                        color: current.textColor,
                        size: 25,
                      ),
                      const SizedBox(width: 5,),
                      Icon(
                        Icons.search,
                        color: current.textColor,
                        size: 25,
                      ),
                    ],
                  ),
                  Expanded(child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: current.textColor.withOpacity(0.2),
                      border: Border.all(color: current.primaryColor.withOpacity(0.3), width: 1),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        getSimpleVideoWidget('Crazy Frog', 'Axel F', 'assets/tn/04.jpg', current),
                        const SizedBox(height: 7,),
                        getSimpleVideoWidget('Dancing Queen', 'ABBA', 'assets/tn/03.jpg', current),
                        const SizedBox(height: 7,),
                        getSimpleVideoWidget('Never Gonna Give...', 'Rick Astley', 'assets/tn/02.jpg', current),
                        const SizedBox(height: 7,),
                        getSimpleVideoWidget('Sandstorm', 'Darude', 'assets/tn/01.jpg', current),
                        const SizedBox(height: 7,),
                        getSimpleVideoWidget('Witch Doctor', 'Cartoons', 'assets/tn/05.jpg', current),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          Container(
            height: 3,
            color: Colors.white30,
          ),
          Expanded(
            flex: playerFlex,
            child: Container(
                decoration: BoxDecoration(
                    color: current.primaryColor,
                    image: const DecorationImage(
                      image: AssetImage('assets/tn/02big.jpg'),
                      opacity: 0.4,
                      fit: BoxFit.cover,
                    )
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 5,),
                        Text('Never Gonna Give You Up', style: TextStyle(color: current.textColor, fontSize: 11),),
                        Text('Up next Sandstorm', style: TextStyle(color: current.textColor, fontSize: 9),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 5,),
                            Text('1:53', style: TextStyle(color: current.textColor, fontSize: 11),),
                            Expanded(
                              child: Slider(
                                value: 113.0/212.0,
                                onChanged: (value){},
                                inactiveColor: current.textColor,
                                activeColor: current.secondaryColor,
                              ),
                            ),
                            Text('3:32', style: TextStyle(color: current.textColor, fontSize: 11),),
                            const SizedBox(width: 5,),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Spacer(),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Spacer(flex: 3,),

                          CircleAvatar(backgroundColor: current.secondaryColor, radius: circleRadius, child: Icon(Icons.navigate_before, color: current.textColor, size: circleRadius,),),
                          const SizedBox(width: 5,),
                          CircleAvatar(backgroundColor: current.secondaryColor, radius: circleRadius, child: Icon(Icons.play_arrow, color: current.textColor, size: circleRadius,),),
                          const SizedBox(width: 5,),
                          CircleAvatar(backgroundColor: current.secondaryColor, radius: circleRadius, child: Icon(Icons.navigate_next, color: current.textColor, size: circleRadius,),),

                          const Spacer(flex: 1,),

                          CircleAvatar(backgroundColor: current.secondaryColor, radius: circleRadius, child: Icon(Icons.repeat_one, color: current.textColor, size: circleRadius,),),
                          const SizedBox(width: 5,),
                          CircleAvatar(backgroundColor: current.secondaryColor, radius: circleRadius, child: Icon(Icons.shuffle, color: current.textColor, size: circleRadius,),),
                          const SizedBox(width: 3,),
                        ],),
                        const SizedBox(height: 4,),
                      ],
                    ),
                  ],
                )
            ),
          )
        ],
      ),
    );
  }

  Widget getSimpleVideoWidget(String title, String interpret, String assetImage, ThemeDTO current) {
    return Container(
      height: 60,
      color: current.primaryColor.withOpacity(0.12),
      child: Row(
        children: [
          Image.asset(
            assetImage,
            fit: BoxFit.fitHeight,
          ),
          const SizedBox(width: 10,),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Spacer(),
            Text(title, style: TextStyle(color: current.textColor, fontWeight: FontWeight.bold, fontSize: 11, overflow: TextOverflow.ellipsis),),
            Text(interpret, style: TextStyle(color: current.textColor, fontSize: 9),),
            const Spacer(),
          ],)
        ],
      ),
    );
  }

  void showFeedback() async {
    showCheck = true;
    saveSetState();
    await Future.delayed(const Duration(seconds: 3));
    showCheck = false;
    saveSetState();
  }
}