import 'package:bsit3bcrud/home.dart';
import 'package:flutter/material.dart';
import 'package:bsit3bcrud/login.dart';
import 'users.dart';
import 'api.dart';
import 'notifications.dart';

void main() {
  runApp(
    const MaterialApp(
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  UserScreenState createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  late Future<List<User>> futureUsers;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  int? editingId;

  @override
  void initState() {
    super.initState();
    refreshUsers();
  }

  void refreshUsers() {
    setState(() {
      futureUsers = ApiService.getUsers();
    });
  }

  void handleSave() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      showMessage("Please fill in both fields.");
      return;
    }

    try {
      if (editingId == null) {
        await ApiService.addUser(name, email);
        showMessage("User added successfully!");
      } else {
        await ApiService.updateUser(editingId!, name, email);
        showMessage("User updated successfully!");
      }

      nameController.clear();
      emailController.clear();
      editingId = null;
      refreshUsers();
    } catch (e) {
      showMessage("Error adding user!");
    }
  }

  void handleEdit(User user) {
    setState(() {
      nameController.text = user.name;
      emailController.text = user.email;
      editingId = user.id;
    });
  }

  void handleDelete(int id) async {
    await ApiService.deleteUser(id);
    showMessage("User deleted!");
    refreshUsers();
  }

  void handleLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
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

      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            hintText: "Enter username",
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(height: 10),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            hintText: "Enter user email",
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: handleSave,
            label: Text(
              editingId == null ? "Add Friend" : "Update User",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: FutureBuilder<List<User>>(
              future: futureUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Users Found"));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    User user = snapshot.data![index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.grey),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(user.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => handleDelete(user.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, 
        onTap: (index) {
          if (index == 0) {
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FacebookPost()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewsfeedScreen()),
            );
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
}
