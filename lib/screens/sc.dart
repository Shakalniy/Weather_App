import 'package:flutter/material.dart';
import 'dart:math';

class PullRefreshPage extends StatefulWidget {
  const PullRefreshPage();

  @override
  State<PullRefreshPage> createState() => _PullRefreshPageState();
}

class _PullRefreshPageState extends State<PullRefreshPage> {
  List<String> numbersList = NumberGenerator().numbers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: ListView.builder(
          itemCount: numbersList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(numbersList[index], style: TextStyle(color: Colors.orange),),
            );
          },),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    List<String> freshNumbers = await NumberGenerator().slowNumbers();
    setState(() {
      numbersList = freshNumbers;
    });
    // why use freshNumbers var? https://stackoverflow.com/a/52992836/2301224
  }
}

class NumberGenerator {
  Future<List<String>> slowNumbers() async {
    return Future.delayed(const Duration(milliseconds: 10), () => numbers,);
  }

  List<String> get numbers => List.generate(5, (index) => number);


  String get number => Random().nextInt(99999).toString();
}