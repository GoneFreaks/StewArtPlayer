import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dto/location_dto.dart';
import 'helper/track_loader.dart' as loader;
import 'helper/utils.dart' as utils;
import 'helper/db_loader.dart' as db;
import 'helper/variable_holder.dart';
import 'minor_widgets/filter_dropdown.dart';

class EditingControls extends StatefulWidget {
  const EditingControls({super.key});

  @override
  State<EditingControls> createState() => EditingControlsState();
}

class EditingControlsState extends State<EditingControls>{

  List<String> playlistNames = [];
  List<String> interpretNames = [];
  String? playlistName;

  @override
  void initState() {
    super.initState();
    Holder.isEditingMode.addListener(saveSetState);
    Holder.filter.addListener(saveSetState);
    Holder.trueCounter.addListener(saveSetState);
    db.getInterprets().then((value) => interpretNames = value);
  }

  @override
  void dispose() {
    super.dispose();
    Holder.isEditingMode.removeListener(saveSetState);
    Holder.filter.removeListener(saveSetState);
    Holder.trueCounter.removeListener(saveSetState);
  }

  void saveSetState() {
    try {
      setState(() {});
    } catch (_){}
  }

  void resetEditingMode(){
    Holder.isEditingMode.value = false;
    Holder.checkedBoxes = {};
    Holder.trueCounter.value = 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (Holder.isEditingMode.value)
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
            ),
            onPressed: () async {
              List<String> idsToDelete = [];
              Holder.checkedBoxes.forEach((key, value) {
                if (value) idsToDelete.add(key);
              });

              Directory directory =
              await getApplicationDocumentsDirectory();
              for (String id in idsToDelete) {
                File file = File("${directory.path}/$id.m4a");
                await loader.deleteTrack(file.path, id);
              }
              if (context.mounted) {
                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.success,
                    title:
                    "${idsToDelete.length} Track${idsToDelete.length > 1 ? 's' : ''} wurden gelöscht");
              }
              resetEditingMode();
            },
          ),
        if (Holder.isEditingMode.value)
          IconButton(
            icon: const Icon(
              Icons.add_box_outlined,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: utils.getDialogBorder(),
                      backgroundColor: Theme.of(context).colorScheme.background,
                      content: SizedBox(
                        height: 75,
                        width: 300,
                        child: Column(
                          children: [
                            Text('Zu Playliste hinzufügen', style: Theme.of(context).textTheme.titleMedium,),
                            Autocomplete<String>(
                              fieldViewBuilder:
                                  (fieldContext, controller, node, test) {
                                return TextField(
                                  autocorrect: false,
                                  controller: controller,
                                  focusNode: node,
                                  decoration: const InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                );
                              },
                              optionsBuilder: (value) {
                                playlistName = value.text;
                                List<String> matches = [];
                                matches.addAll(playlistNames);
                                matches.retainWhere((s) {
                                  return s
                                      .toLowerCase()
                                      .contains(value.text.toLowerCase());
                                });
                                return matches;
                              },
                              onSelected: (value) {
                                playlistName = value;
                              },
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            playlistName = null;
                            Navigator.pop(context);
                          },
                          child: Text("ABBRECHEN", style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        TextButton(
                          onPressed: () {
                            if (playlistName != null &&
                                playlistName!.isNotEmpty) {
                              List<String> playlistIDs = [];
                              Holder.checkedBoxes.forEach((key, value) {
                                if (value) playlistIDs.add(key);
                              });
                              if (playlistIDs.isEmpty) {
                                CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.error,
                                    title: 'Keine Tracks ausgewählt');
                              } else {
                                db.createPlaylist(
                                    playlistIDs, playlistName!);
                                Navigator.pop(context);
                                resetEditingMode();
                                CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.success,
                                    title:
                                    'Die Playlist $playlistName wurde angelegt');
                              }
                            } else {
                              CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.error,
                                  title:
                                  'Es muss ein Playlist-Name angegeben werden');
                            }
                          },
                          child: Text("OK", style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    );
                  });
            },
          ),
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: utils.getDialogBorder(),
                    backgroundColor: Theme.of(context).colorScheme.background,
                    content: const FilterDropdown(),
                  );
                }
            );
          },
        ),
        IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  TextEditingController controller = TextEditingController();
                  if(Holder.localSearch.value.isNotEmpty) controller.text = Holder.localSearch.value;
                  return AlertDialog(
                    shape: utils.getDialogBorder(),
                    backgroundColor: Theme.of(context).colorScheme.background,
                    content: TextField(
                      decoration: InputDecoration(
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        icon: IconButton(
                          icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.tertiary,),
                          onPressed: () {
                            setState(() {
                              Holder.localSearch.value = '';
                              controller.text = '';
                            });
                          },
                        ),
                      ),
                      autofocus: true,
                      controller: controller,
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged: (value) {
                        setState(() {
                          Holder.localSearch.value = value;
                        });
                      },
                    ),
                  );
                }
            );
          },
          icon: const Icon(Icons.search),
        ),
        if(Holder.isEditingMode.value && Holder.trueCounter.value == 1)
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () async {
              late String id;
              Holder.checkedBoxes.forEach((key, value) {
                if(value) {
                  id = key;
                }
              });
              TextEditingController controller = TextEditingController();
              db.getVideoDTO(id, LocationDTO(location: 1, isInterpret: 1, playlistName: '')).then((value) {
                controller.text = value!.title;
              });

              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: utils.getDialogBorder(),
                      backgroundColor: Theme.of(context).colorScheme.background,
                      content: SizedBox(
                        width: 300,
                        height: 75,
                        child: Column(
                          children: [
                            Text('Track Titel anpassen', style: Theme.of(context).textTheme.titleMedium,),
                            TextField(
                              controller: controller,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Abbrechen", style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        TextButton(
                          onPressed: () async {
                            if(controller.text.isNotEmpty) {
                              await db.renameTrack(id, controller.text);
                              if(context.mounted) Navigator.pop(context);
                              resetEditingMode();
                              if(context.mounted) CoolAlert.show(context: context, type: CoolAlertType.success, title: 'Track erfolgreich umbenannt');
                            }
                          },
                          child: Text("Umbenennen", style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    );
                  }
              );
            },
          ),
        if(Holder.isEditingMode.value && Holder.trueCounter.value > 0)
          IconButton(
            onPressed: () {
              List<String> ids = [];
              Holder.checkedBoxes.forEach((key, value) {
                if(value) ids.add(key);
              });
              String? newInterpret;
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: utils.getDialogBorder(),
                      backgroundColor: Theme.of(context).colorScheme.background,
                      content: SizedBox(
                        width: 300,
                        height: 75,
                        child: Column(
                          children: [
                            Text('Interpret anpassen', style: Theme.of(context).textTheme.titleMedium,),
                            Autocomplete<String>(
                              fieldViewBuilder:
                                  (fieldContext, controller, node, test) {
                                return TextField(
                                  autocorrect: false,
                                  controller: controller,
                                  focusNode: node,
                                  decoration: const InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                );
                              },
                              optionsBuilder: (value) {
                                if(value.text.length < 3) return [];
                                newInterpret = value.text;
                                List<String> matches = [];
                                matches.addAll(interpretNames);
                                matches.retainWhere((s) {
                                  return s.toLowerCase().contains(value.text.toLowerCase());
                                });
                                return matches;
                              },
                              onSelected: (value) {
                                newInterpret = value;
                              },
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Abbrechen", style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        TextButton(
                          onPressed: () async {
                            if(newInterpret != null && newInterpret!.isNotEmpty) {
                              await db.renameInterpret(ids, newInterpret!);
                              if(context.mounted) Navigator.pop(context);
                              resetEditingMode();
                              if(context.mounted) CoolAlert.show(context: context, type: CoolAlertType.success, title: 'Interpret erfolgreich angepasst');
                            }
                          },
                          child: Text("Umbenennen", style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    );
                  }
              );
            },
            icon: const Icon(Icons.person),
          ),
      ],
    );
  }
}