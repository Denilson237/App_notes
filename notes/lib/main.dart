
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/Homepage.dart';
import 'package:notes/notes.dart';
import 'package:notes/riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int index = ref.watch(editPage);
    return [const Homepage(),   Notes(id: null, titre: '', note: '', date: DateTime.now(),)][index];
  }
}