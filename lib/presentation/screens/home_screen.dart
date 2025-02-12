import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Xionico Demo'),
      // ),

      body: Center(
        child: Stack(
          children: [
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(20),
            //   child: Image.asset("images/background.jpg", fit: BoxFit.fitHeight,),
              
            // ),
            Text("BIENVENIDOS AL SISTEMA!", style: TextStyle(fontSize: 24, color: colors.inversePrimary),),
          ],
        ),
      ),
      backgroundColor: colors.primary,
      drawer: Drawer(
        child: Column(
          children: [
            Text("asdad")
          ],
        ),
      ),
    );
  }
}