import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Scroll'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _controller = ScrollController();
  int selectedIndex = 0;
  bool showBottom=true;

  Future<List<Comments>> fetchCommentsData() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/comments'));

    final jsonData = jsonDecode(response.body) as List<dynamic>;

    final List<Comments> comments =
        jsonData.map((comment) => Comments.fromJson(comment)).toList();

    return comments;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.userScrollDirection == ScrollDirection.forward) {
        setState(() {
          showBottom = false;
        });
      } else if (_controller.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          showBottom = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text(widget.title)),
      ),
      body: FutureBuilder<List<Comments>>(
          future: fetchCommentsData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              controller: _controller,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(snapshot.data![index].name),
                          Text(snapshot.data![index].email),
                          Text(snapshot.data![index].id.toString()),
                          Text(snapshot.data![index].postId.toString()),
                          Text(
                            snapshot.data![index].body,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ));
          }),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: !showBottom?kBottomNavigationBarHeight:0.0,
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showUnselectedLabels: true,
          unselectedLabelStyle: const TextStyle(color: Colors.black),
          selectedItemColor: Colors.black.withOpacity(.9),
          unselectedItemColor: Colors.black,
          items: List.generate(
              4,
              (index) => BottomNavigationBarItem(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                  label: 'index$index')),
        ),
      ),
    );
  }
}

class Comments {
  int postId;
  int id;
  String name;
  String email;
  String body;

  Comments(
      {required this.email,
      required this.id,
      required this.name,
      required this.body,
      required this.postId});

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
        email: json['email'],
        id: json['id'],
        name: json['name'],
        body: json['body'],
        postId: json['postId']);
  }
}
