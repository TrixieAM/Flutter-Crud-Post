import 'package:bsit3bcrud/login.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class NewsfeedScreen extends StatefulWidget {
  const NewsfeedScreen({super.key});

  @override
  State<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends State<NewsfeedScreen> {
  List<Map<String, dynamic>> notifications = [
    {
      "user": "Uno",
      "date": "June 30, 2025",
      "message": "liked your post.",
      "image": "images/default.jpg",
      "read": false
    },
    {
      "user": "Trese",
      "date": "June 30, 2025",
      "message": "commented: 'Playyyyyy<3'",
      "image": "images/default.jpg",
      "read": false
    },
    {
      "user": "Trese",
      "date": "June 30, 2025",
      "message": "reacted ❤️ to your post.",
      "image": "images/default.jpg",
      "read": false
    },
    {
      "user": "Fourth",
      "date": "June 23, 2025",
      "message": "liked your comment.",
      "image": "images/default.jpg",
      "read": true
    },
    {
      "user": "Nueve",
      "date": "June 17, 2025",
      "message": "mentioned you in a comment.",
      "image": "images/default.jpg",
      "read": true
    },
  ];

  void _onMenuSelected(int index, String action) {
    setState(() {
      if (action == 'delete') {
        notifications.removeAt(index);
      } else if (action == 'read') {
        notifications[index]["read"] = true;
      }
    });
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index]["read"] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Text(
              "facebook",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
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

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'clear') {
                      setState(() {
                        notifications.clear();
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'clear', child: Text('Clear All')),
                  ],
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationTile(notification, index);
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, 
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); 
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FacebookPost()),
            );
          } else if (index == 2) {
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Friends"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification, int index) {
    return GestureDetector(
      onTap: () => _markAsRead(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: notification["read"] ? Colors.white : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(notification["image"]),
              radius: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                            children: [
                              TextSpan(
                                text: notification["user"],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: " ${notification["message"]}",
                              ),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (action) => _onMenuSelected(index, action),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'read', child: Text('Mark as Read')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                        child: const Icon(Icons.more_horiz, size: 24), 
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        notification["date"],
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      if (!notification["read"])
                        const Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Icon(Icons.circle, size: 8, color: Colors.blue),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
