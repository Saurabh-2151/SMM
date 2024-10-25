import 'package:flutter/material.dart';
import 'package:smm/Profile/profile_screen.dart';
import 'package:smm/Reel/reel.dart';
import 'package:smm/screen/add.dart';
import 'package:smm/screen/home.dart';
 

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();

}

class _HomePageState extends State{

      int _selectedIndex = 0;
    final PageController _pageController = PageController(initialPage: 0);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      body: PageView(
        controller: _pageController,
        children: <Widget>[
    HomeScreen(),
    const AddScreen(), 
   ReelStoriesPageView(),
    const ProfileScreen(),


        ],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
       
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
backgroundColor: Colors.white,
            icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
           backgroundColor: Colors.white,
            icon: Icon(Icons.add_box_outlined),label: 'Post'),
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.video_library), label: 'Reel'),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.person_outline), label: 'You'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:Color.fromARGB(255, 3, 138, 248),
        unselectedItemColor: const Color.fromRGBO(157, 178, 206, 1),
       
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
  
  Widget body1() {
    return Column( );
  }
}