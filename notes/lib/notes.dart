
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notes/database.dart';
import 'package:notes/riverpod.dart';

class Notes extends ConsumerStatefulWidget {
  final int? id; 
  final String? titre;
  final String? note;
  final DateTime date;
  const Notes({this.id,this.titre,this.note,required this.date, super.key});

  @override
  NotesState createState() => NotesState();
}

class NotesState extends ConsumerState<Notes> {

  late TextEditingController titleController ;
  late TextEditingController noteController ;

  late DateTime date;
  late int? id ;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController ();
    noteController = TextEditingController();
  }
  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    id = widget.id;
    titleController.text = widget.titre.toString();
    noteController.text = widget.note.toString();
    date = widget.date;

    

    return  GestureDetector(
         onTap: (){
          setState(() {
            FocusScope.of(context).requestFocus(FocusNode());
          });
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.black ,
            appBar: AppBar(
              backgroundColor: Colors.black,
              centerTitle: false,
              title: Text("Notes", style: TextStyle(color: Colors.amber[600]),),
              actions: [
                GestureDetector(
                  onTap: (){
                    try{
                    Navigator.pop(context);
                    
                  }catch(e){
                    ref.read(editPage.notifier).state = 0;
                  }
                 titleController.text.isEmpty && noteController.text.isEmpty ?"": updateORinsertData();
                  },
                  child: Container(margin:const EdgeInsets.only(right: 25),child:  Text("OK",style: TextStyle(color: Colors.amber[600], fontSize: 16))),
                )
              ],
              leading: GestureDetector(
                onTap:() {
                  try{
                    Navigator.pop(context);
                    
                  }catch(e){
                    ref.read(editPage.notifier).state = 0;
                  }
                 titleController.text.isEmpty && noteController.text.isEmpty ?"": updateORinsertData();
              }, 
              
              child: Icon(Icons.arrow_back_ios, color: Colors.amber[600],)),
            ),
            body:   Center(
              child: Container(
                margin: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                  Center(child: Text(formatage(date.toString()), style: const TextStyle(color: Colors.grey),),) ,
                    TextField(
                controller: titleController,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    cursorColor: Colors.amber[600],
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(0),
                  hintText: "Entrez un Titre... ",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
                    
                    const SizedBox(height: 10),
              Expanded(
                child: TextField(
                  controller: noteController,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  maxLines: null,
                  expands: true,
                  cursorColor: Colors.amber[600],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "ecrivez une Notes ...",
                  hintStyle: TextStyle(color: Colors.grey),
                  ),
          
                ),
              ),
                  ],
                ),
              ))
              
             
          
              ),
          ),
        );
      
    
  }
  onWillpop(){
    titleController.text.isEmpty && noteController.text.isEmpty ?"": updateORinsertData();
    return true;
  }
  
void updateORinsertData() async {

      if (id != null) {
        // Update existing note
        ref.read(databaseme.notifier).updateData(titleController.text, noteController.text, id!);
      } else {
        // Insert new note
        ref.read(databaseme.notifier).insertData(titleController.text, noteController.text, date.toIso8601String());
      }
    }
  formatage(String date){
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(dateTime);
    return formattedDate;}

 
  

}