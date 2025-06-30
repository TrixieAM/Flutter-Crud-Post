import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

import 'login.dart';
import 'main.dart'; 
import 'notifications.dart';

String token = 'YOUR_JWT_TOKEN'; 

class FacebookPost extends StatefulWidget {
  const FacebookPost({super.key});

  @override
  FacebookPostState createState() => FacebookPostState();
}

class FacebookPostState extends State<FacebookPost> {
  final TextEditingController _captionController = TextEditingController();
  final List<String> reactions = ["👍", "❤️", "😆", "😮", "😢", "😡", "🥰"];
  String selectedFilter = "Most Relevant";

  File? _imageFile;
  Uint8List? _webImage;
  XFile? _pickedFile;
  bool _isUploading = false;
  String _message = "";
  bool _showSuccess = false;

  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedFile = picked;
        if (kIsWeb) {
          picked.readAsBytes().then((value) {
            setState(() {
              _webImage = value;
            });
          });
        } else {
          _imageFile = File(picked.path);
        }
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_pickedFile == null || _captionController.text.isEmpty) {
      setState(() {
        _message = "Please select an image and write a caption";
        _showSuccess = false;
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _message = "";
    });

    try {
      final uri = Uri.parse("http://localhost:5000/api/posts");
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['subtext'] = _captionController.text;

      if (kIsWeb && _webImage != null) {
        final multipartFile = http.MultipartFile.fromBytes(
          'image',
          _webImage!,
          filename: _pickedFile!.name,
        );
        request.files.add(multipartFile);
      } else if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _imageFile!.path,
            filename: p.basename(_imageFile!.path),
          ),
        );
      }

      final response = await request.send();
      if (response.statusCode == 201) {
        setState(() {
          _captionController.clear();
          _pickedFile = null;
          _webImage = null;
          _imageFile = null;
          _message = "Post uploaded successfully!";
          _showSuccess = true;
        });
        _fetchPosts();
      } else {
        setState(() {
          _message = "Failed to upload post.";
          _showSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error occurred: $e";
        _showSuccess = false;
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _fetchPosts() async {
    final response = await http.get(
      Uri.parse("http://localhost:5000/api/posts"),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> postList = jsonDecode(response.body);
      setState(() {
        posts = postList.map((post) {
          final createdAt = DateTime.tryParse(post["created_at"] ?? "") ?? DateTime.now();
          final formattedDate = '${DateFormat('MMMM d, yyyy').format(createdAt)}  🌏︎';
          return {
            "id": post["id"],
            "name": "Trixie Morales",
            "date": formattedDate, 
            "caption": post["subtext"],
            "profileImage": "images/meow.jpg",
            "postImage": "http://localhost:5000/uploads/${post["image"]}",
            "likes": "1313",
            "comments": "323 Comments",
            "shares": "33 Shares",
            "showReactions": false,
          };
        }).toList();
      });
    }
  }

  Future<void> _deletePost(int postId, int index) async {
    final response = await http.delete(
      Uri.parse("http://localhost:5000/api/posts/$postId"),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      setState(() {
        posts.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Text("facebook", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
  PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert, color: Colors.black),
    onSelected: (value) {
      if (value == 'logout') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    },
    itemBuilder: (context) => const [
      PopupMenuItem<String>(
        value: 'logout',
        child: Row(
          children: [
            SizedBox(width: 10),
            Text("Logout"),
          ],
        ),
      ),
    ],
  ),
],

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCreatePost(),
              const SizedBox(height: 20),
              ...posts.asMap().entries.map((entry) => _buildFacebookPost(entry.value, entry.key)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.blue,       
        unselectedItemColor: Colors.grey,     
        backgroundColor: Colors.white,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NewsfeedScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Friends"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        ],
      ),
    );
  }

 Widget _buildCreatePost() {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _captionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "What's on your mind?",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),

          if (_pickedFile != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: kIsWeb
                  ? Image.memory(_webImage!, height: 200)
                  : Image.file(_imageFile!, height: 200),
            ),

 
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                label: const Text("Choose Image", style: TextStyle(color: Colors.blue)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                ),
                onPressed: _pickImage,
              ),
              const SizedBox(width: 10),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _uploadPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Post"),
                    ),
            ],
          ),

   
          if (_message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _message,
                style: TextStyle(color: _showSuccess ? Colors.green : Colors.red),
              ),
            ),
        ],
      ),
    ),
  );
}


  Widget _buildFacebookPost(Map<String, dynamic> post, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('images/meow.jpg'),
              radius: 25,
            ),
            title: Text(post["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(post["date"], style: const TextStyle(fontSize: 12)),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "delete") {
                  _deletePost(post["id"], index);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: "delete", child: Text("Delete Post")),
              ],
            ),
          ),
          if (post["caption"] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(post["caption"]),
            ),
          if (post["postImage"] != null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.network(post["postImage"]),
            ),
          _postStats(post),
          const Divider(),
          _reactionButtons(index),
          const Divider(),
          _viewCommentsDropdown(),
          _buildCommentSection('images/meow.jpg'),
        ],
      ),
    );
  }

  Widget _postStats(Map<String, dynamic> post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
                              children: [
                                Icon(Icons.favorite, color: Colors.red, size: 18),
                                Icon(Icons.thumb_up, color: Colors.blue, size: 18),
                                Text("😆"),
                                SizedBox(width: 6),
                                Text("1021"),
                              ],
                            ),
          Text("${post["comments"]} • ${post["shares"]}"),
        ],
      ),
    );
  }

  Widget _reactionButtons(int index) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (posts[index]["showReactions"])
          Positioned(bottom: 40, child: _reactionPopup()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onLongPress: () {
                setState(() {
                  posts[index]["showReactions"] = true;
                });
              },
              onLongPressEnd: (_) {
                setState(() {
                  posts[index]["showReactions"] = false;
                });
              },
              child: _actionButton(Icons.thumb_up_alt_outlined, "Like"),
            ),
            _actionButton(Icons.insert_comment, "Comment"),
            _actionButton(Icons.share, "Share"),
          ],
        ),
      ],
    );
  }

  Widget _reactionPopup() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions
            .map((emoji) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ))
            .toList(),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.grey[800]),
      label: Text(label, style: TextStyle(color: Colors.grey[800])),
    );
  }

  Widget _buildCommentSection(String profileImage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(profileImage),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Write a comment...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
               Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.gif, color: Colors.grey),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.sticky_note_2_outlined, color: Colors.grey),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _viewCommentsDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("View Comments",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: selectedFilter,
            icon: const Icon(Icons.arrow_drop_down),
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.black, fontSize: 14),
            onChanged: (String? newValue) {
              setState(() {
                selectedFilter = newValue!;
              });
            },
            items: const [
              DropdownMenuItem(value: "Most Relevant", child: Text("Most Relevant")),
              DropdownMenuItem(value: "All Comments", child: Text("All Comments")),
            ],
          ),
        ],
      ),
    );
  }
}
