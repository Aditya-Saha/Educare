import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// =======================
// Global cart list
// =======================
List<Map<String, dynamic>> cart = [];

// =======================
// API Service
// =======================
class ApiService {
  // Replace with your PC's LAN IP for emulator testing
  static const String baseUrl = "http://192.168.1.100:5000/api";

  // Fetch all available courses
  static Future<List<Map<String, dynamic>>> fetchCourses() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/courses"));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("Failed to load courses: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching courses: $e");
    }
  }

  // User login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  // User signup
  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  // Checkout cart
  static Future<Map<String, dynamic>> checkout(List<Map<String, dynamic>> cartItems) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/checkout"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"cart": cartItems}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("Checkout failed: $e");
    }
  }
}

// =======================
// Home Screen
// =======================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool isDarkMode = true;
  late AnimationController _iconAnimation;

  List<Widget> get _pages => [
    CoursesPage(isDarkMode: isDarkMode),
    BuyCoursesPage(isDarkMode: isDarkMode),
    AssignmentsPage(isDarkMode: isDarkMode),
    ProgressPage(isDarkMode: isDarkMode),
    SettingsPage(isDarkMode: isDarkMode),
  ];

  @override
  void initState() {
    super.initState();
    _iconAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _iconAnimation.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      if (isDarkMode) {
        _iconAnimation.reverse();
      } else {
        _iconAnimation.forward();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF0F1724) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Educare"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: AnimatedBuilder(
              animation: _iconAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _iconAnimation.value * 3.14,
                  child: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: textColor,
                  ),
                );
              },
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.grey[100],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: isDarkMode ? Colors.white70 : Colors.black45,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'My Courses',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cart.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            label: 'Buy Courses',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Assignments',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Progress',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.logout),
        tooltip: 'Logout',
      ),
    );
  }
}

// =======================
// Courses Page
// =======================
class CoursesPage extends StatelessWidget {
  final bool isDarkMode;
  const CoursesPage({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.grey[200];
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final List<Map<String, Object>> courses = [
      {"title": "Flutter Development", "progress": 0.7},
      {"title": "Data Science Basics", "progress": 0.4},
      {"title": "Digital Marketing", "progress": 0.2},
    ];

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          color: cardColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course["title"] as String,
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: course["progress"] as double,
                  backgroundColor: isDarkMode ? Colors.white12 : Colors.black12,
                  color: Colors.blueAccent,
                  minHeight: 6,
                ),
                const SizedBox(height: 4),
                Text("${((course["progress"] as double) * 100).toInt()}% Completed",
                    style: TextStyle(color: textColor.withOpacity(0.7))),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =======================
// Buy Courses Page
// =======================
class BuyCoursesPage extends StatefulWidget {
  final bool isDarkMode;
  const BuyCoursesPage({super.key, required this.isDarkMode});

  @override
  State<BuyCoursesPage> createState() => _BuyCoursesPageState();
}

class _BuyCoursesPageState extends State<BuyCoursesPage> {
  late Future<List<Map<String, dynamic>>> futureCourses;

  @override
  void initState() {
    super.initState();
    futureCourses = ApiService.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDarkMode ? const Color(0xFF1E293B) : Colors.grey[200];
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureCourses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: textColor)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No courses available", style: TextStyle(color: textColor)));
        }

        final courses = snapshot.data!;
        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Card(
              color: cardColor,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(course["title"], style: TextStyle(color: textColor)),
                subtitle: Text("\$${course["price"]}", style: TextStyle(color: subTextColor)),
                trailing: Icon(Icons.arrow_forward, color: subTextColor),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailsPage(
                        title: course["title"],
                        price: course["price"].toDouble(),
                        description: course["description"],
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// =======================
// Course Details Page
// =======================
class CourseDetailsPage extends StatefulWidget {
  final String title;
  final double price;
  final String description;
  final bool isDarkMode;

  const CourseDetailsPage({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    required this.isDarkMode,
  });

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  bool isAdded = false;

  void addToCart() {
    if (!isAdded) {
      cart.add({"title": widget.title, "price": widget.price});
      setState(() => isAdded = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${widget.title} added to cart!"), duration: const Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? const Color(0xFF0F1724) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            color: textColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.title, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text("\$${widget.price.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(widget.description, style: TextStyle(color: subTextColor, fontSize: 16)),
          const Spacer(),
          Center(
            child: ElevatedButton.icon(
              onPressed: addToCart,
              icon: const Icon(Icons.shopping_cart),
              label: Text(isAdded ? "Added" : "Add to Cart"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdded ? Colors.grey : Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

// =======================
// Cart Page
// =======================
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get totalPrice {
    double total = 0;
    for (var item in cart) {
      total += item["price"] as double;
    }
    return total;
  }

  void removeItem(int index) {
    setState(() {
      cart.removeAt(index);
    });
  }

  void checkout() async {
    try {
      final response = await ApiService.checkout(cart);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Checkout successful!")),
      );
      setState(() {
        cart.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Checkout failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1724),
      appBar: AppBar(
        title: const Text("Cart"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: cart.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(item["title"] as String, style: const TextStyle(color: Colors.white)),
                    subtitle: Text("\$${item["price"]}",
                        style: const TextStyle(color: Colors.white70)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeItem(index),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: \$${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Checkout"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// =======================
// Assignments Page
// =======================
class AssignmentsPage extends StatelessWidget {
  final bool isDarkMode;
  const AssignmentsPage({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> assignments = [
      {"title": "Flutter Project 1", "due": "2025-10-25"},
      {"title": "Marketing Essay", "due": "2025-10-30"},
      {"title": "Data Analysis Task", "due": "2025-11-05"},
    ];

    return ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return Card(
          color: const Color(0xFF1E293B),
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(assignment["title"]!, style: const TextStyle(color: Colors.white)),
            subtitle: Text("Due: ${assignment["due"]}", style: const TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            onTap: () {},
          ),
        );
      },
    );
  }
}

// =======================
// Progress Page
// =======================
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key, required this.isDarkMode});
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, color: Colors.blueAccent, size: 80),
          const SizedBox(height: 20),
          Text("Your Progress Reports",
              style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// =======================
// Settings Page
// =======================
class SettingsPage extends StatelessWidget {
  final bool isDarkMode;
  const SettingsPage({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Center(
      child: Text("Settings Page", style: TextStyle(color: textColor, fontSize: 18)),
    );
  }
}
