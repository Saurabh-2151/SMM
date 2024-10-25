import 'package:flutter/material.dart';
import 'package:smm/Story/storyeditor.dart';
import 'package:smm/screen/add_post.dart';


class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

int _currentIndex = 0;

class _AddScreenState extends State<AddScreen> {
  late PageController pageController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              children:[
                 const AddPostScreen(),
                MediaPickerScreen()
                
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: 10,
              right: _currentIndex == 0 ? 100 : 150,
              child: Container(
                width: 120,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        navigationTapped(0);
                      },
                      child: Text(
                        'Post',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color:
                              _currentIndex == 0 ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        navigationTapped(1);
                      },
                      child: Text(
                        'Story',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color:
                              _currentIndex == 1 ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}