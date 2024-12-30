
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:notes/database.dart';

import 'package:notes/notes.dart';
import 'package:notes/riverpod.dart';

class Homepage extends ConsumerStatefulWidget {
  const Homepage({super.key});

  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends ConsumerState<Homepage> {

  //List<Map<String, dynamic>>  notes = [];
  bool annuler = false;
  late TextEditingController search ;

  @override void initState() {
   ref.read(databaseme.notifier).readData();
    search = TextEditingController();
    fort();
    super.initState();
  }

  Future<void> fort() async{
     await initializeDateFormatting("fr", null);
  }
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }
  List<Map<String, dynamic>> notes = [];
   
  @override
  Widget build(BuildContext context) {

    notes = ref.watch(databaseme).notes;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
       backgroundColor: Colors.black,
        appBar: AppBar(
         toolbarHeight: 90,
          backgroundColor: Colors.black,
          centerTitle: true,
        title: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top :5, left: 5, right: 5),
          child: Column(
              children: [
                const Text("Notes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),),
                Container(
                  height: 40,
                  padding: const EdgeInsets.only(bottom:  5),
                  margin: const EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: search,
                    style: const TextStyle(color: Colors.white, fontSize: 14, ),
                    textAlign: TextAlign.start,
                    cursorColor: Colors.amber[600],
                    keyboardType: TextInputType.text,
                    decoration:  InputDecoration(
                      hintText: "Recherche ...",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search, color: Colors.amber[600],),
                      suffixIcon: Icon(Icons.filter_list, color: Colors.amber[600],),
                      contentPadding: const EdgeInsets.symmetric(vertical: 1),
                      focusedBorder:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey[800]!,
                        width: 1.5,)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey[800]!,
                        width: 1.5,)),
                        ),
                    onChanged: (value) {
                      setState(() {
                        ref.read(databaseme.notifier).filterNotes(value);
                        annuler = true;
                      });
                    },
                  ),
                ),
              
              ],
              
            ),
        ),),
          body: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only( left: 20, right: 20),
                padding: const EdgeInsets.only(bottom: 30),
                child: GroupedListView<dynamic, String>(
                      elements: notes,
                      groupBy: (note) => category(DateTime.tryParse(note["date"])),
                      groupSeparatorBuilder: (String groupByValue) => Container(margin:const EdgeInsets.only(top: 15, bottom: 15) ,child: Text(groupByValue, style:  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                      groupItemBuilder: (context, dynamic note, bool premier, bool dernier) {
                       
                          return Dismissible(
                            key: Key(note["id"].toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.all(25),
                             color: Colors.amber[600],
                             child: Icon(Icons.delete, color: Colors.grey[900],),
                            ),
                            onDismissed: (direction) {
                              ref.read(databaseme.notifier).deleteData(note["id"]);
                            },
                            child: Container(
                              
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: 
                                premier == true && dernier == true
                                ? BorderRadius.circular(25)
                                :premier && (premier != dernier)
                                ?  const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
                                : dernier && (premier != dernier)
                                ? const BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)): BorderRadius.circular(0),
                                ),
                              
                              child:GestureDetector(
                                
                                child: Container(
                                  margin: const EdgeInsets.only(left:  30),
                                  decoration: BoxDecoration(
                                 
                                  border: Border(
                                    bottom:dernier?BorderSide.none: BorderSide(
                                        color: Colors.grey[400]!, width: 0.3) )),
                                  child: Container(
                                   margin: const EdgeInsets.only(top: 13, bottom: 13),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(note["titre"].isEmpty? "pas de titre":note["titre"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18,overflow: TextOverflow.ellipsis)),
                                        Row(children: [
                                          Text(formatage(note["date"]), style: const TextStyle(color: Colors.white),),
                                          const SizedBox(width: 10,),
                                          Expanded(
                                            child: Text(note["note"].isEmpty?"pas de texte":note["note"].replaceAll("\n", " "), style: const TextStyle(color: Colors.white,
                                                              overflow: TextOverflow.ellipsis,),),
                                          ),
                                        ],)
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: (){
                                  setState(() {
                                    Navigator.of(context).push( MaterialPageRoute(builder: ( context){
                              return Notes(id: note["id"]??"", titre: note["titre"]??"", note: note["note"]??"", date: DateTime.tryParse(note["date"])!);
                            }));
                                  });
                                },
                              )
                              
                              ),
                          );
                             
                      },
                      useStickyGroupSeparators: true,
                       itemComparator: (item1, item2) => item1['date'].compareTo(item2['date']),
                      stickyHeaderBackgroundColor: Colors.black.withOpacity(0.8),
                      order: GroupedListOrder.ASC, // optional
                     footer: notes.isEmpty?  Padding(
                       padding: const EdgeInsets.all(45.0),
                       child: Text("Vos notes Apparaissent ici.", style: TextStyle(color: Colors.grey[300]), textAlign: TextAlign.center,),
                     ):const Text(""), // optional
                 ),
              ),
      
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 65,
                  child: ClipRRect(
                    child: Stack(
                      children: [
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                          child: Container(
                            color: Colors.grey[900]!.withOpacity(0.3),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 25, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            annuler? GestureDetector(
                              onTap: (){
          setState(() {
            FocusScope.of(context).requestFocus(FocusNode());
          });
          ref.read(databaseme.notifier).readData();
          annuler = false;
          search.text = "";
        },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text("Annuler", style: TextStyle(color: Colors.amber[600], fontSize: 16, fontWeight: FontWeight.w500)),
                              ),
                            ): const SizedBox(width: 35,),
                              Text(
                                "${notes.length} notes",
                                style: TextStyle(color: Colors.amber[600]),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    ref.read(editPage.notifier).state = 1;
                                  },
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.amber[600],
                                        size: 16,
                                        weight: 9,
                                      ),
                                      Icon(
                                        Icons.crop_square_outlined,
                                        color: Colors.amber[600],
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  formatage(String date){
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('dd MMMM yyyy', 'fr_FR').format(dateTime);
    return formattedDate;
  }

   category( autre){
    DateTime now = DateTime.now();
    var difference = now.difference(autre).inDays;

    if(difference == 0){
      return "Aujourd'hui";
    }else if(difference == 1){
      return "Hier";
    }else if(difference == 2){
      return "Il y a 03 jours";
    }else if(difference <= 7){
      return "Il y a 07 jours";
    }else  if(difference <= 30){
      return "Les 30 derniers jours";
    }else if(difference > 30){
      return DateFormat('MMMM', 'fr_FR').format(autre);
    }else if(difference > 365){
      return DateFormat('yyyy', 'fr_FR').format(autre);
   }else{
     return "${autre.month}";
   }
  }
}
