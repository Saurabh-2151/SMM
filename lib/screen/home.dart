import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smm/screen/postwidget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentSnapshot>? _cachedPosts;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts(); // Fetch posts when the screen initializes
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isFetching = true;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      _cachedPosts = snapshot.docs;
      _isFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "  MEMORIES",
          style: GoogleFonts.poppins(
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: PageStorage(
        bucket: PageStorageBucket(), // Create a PageStorageBucket
        child: _isFetching
            ? Center(child: CircularProgressIndicator())
            : (_cachedPosts == null || _cachedPosts!.isEmpty)
                ? Center(child: Text('No posts yet.'))
                : ListView.separated(
                    key: PageStorageKey('postsListView'), // Use a PageStorageKey for ListView
                    
                    itemCount: _cachedPosts!.length,
                    itemBuilder: (context, index) {
                      final post = _cachedPosts![index];
                      final Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
                      final String userId = postData['userId'] ?? 'Unknown User';
                      final String description = postData['description'] ?? '';
                      final List<Map<String, dynamic>> mediaFiles = List<Map<String, dynamic>>.from(postData['mediaFiles'] ?? []);
                      final DateTime? createdAt = (postData['createdAt'] as Timestamp?)?.toDate();

                      return PostWidget(
                        userId: userId,
                        description: description,
                        mediaFiles: mediaFiles,
                        createdAt: createdAt,
                        postId: null,
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 10,),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchPosts, // Allow manual refresh
        child: Icon(Icons.refresh),
      ),
    );
  }
}
