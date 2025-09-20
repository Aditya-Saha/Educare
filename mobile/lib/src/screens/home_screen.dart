import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool isDarkMode = true;

  // Animation controller for toggle icon rotation
  late AnimationController _iconAnimation;

  static const List<Widget> _pages = <Widget>[
    CoursesPage(),
    BuyCoursesPage(),
    AssignmentsPage(),
    ProgressPage(),
    SettingsPage(),
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
    // Define dynamic colors
    final bgColor = isDarkMode ? const Color(0xFF0F1724) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.grey[200];
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

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
          // Dark/Light Mode Toggle
          IconButton(
            icon: AnimatedBuilder(
              animation: _iconAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _iconAnimation.value * 3.14, // rotate 180 degrees
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


// =======================
// My Courses Page
// =======================
class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          color: const Color(0xFF1E293B),
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course["title"] as String,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: course["progress"] as double,
                  backgroundColor: Colors.white12,
                  color: Colors.blueAccent,
                  minHeight: 6,
                ),
                const SizedBox(height: 4),
                Text(
                  "${((course["progress"] as double) * 100).toInt()}% Completed",
                  style: const TextStyle(color: Colors.white70),
                ),
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
// Global cart list
List<Map<String, Object>> cart = [];

class BuyCoursesPage extends StatelessWidget {
  const BuyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> courses = [
      {
        "title": "Advanced Flutter",
        "price": 49.99,
        "description":
        "Deep dive into Flutter: state management, animations, and advanced patterns."
      },
      {
        "title": "Machine Learning",
        "price": 59.99,
        "description":
        "Learn ML fundamentals, supervised & unsupervised learning, and Python implementations."
      },
      {
        "title": "UI/UX Design",
        "price": 29.99,
        "description":
        "Master the principles of UI/UX design and create user-friendly apps and websites."
      },
    ];

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          color: const Color(0xFF1E293B),
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(
              course["title"] as String,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "\$${course["price"]}",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing:
            const Icon(Icons.arrow_forward, color: Colors.white70),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailsPage(
                    title: course["title"] as String,
                    price: course["price"] as double,
                    description: course["description"] as String,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}



// =======================
// Course Detail
// =======================

class CourseDetailsPage extends StatefulWidget {
  final String title;
  final double price;
  final String description;

  const CourseDetailsPage(
      {super.key,
        required this.title,
        required this.price,
        required this.description});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  bool isAdded = false;

  void addToCart() {
    if (!isAdded) {
      cart.add({
        "title": widget.title,
        "price": widget.price,
      });
      setState(() {
        isAdded = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${widget.title} added to cart!"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1724),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CartPage()));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "\$${widget.price.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              widget.description,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: addToCart,
                icon: const Icon(Icons.shopping_cart),
                label: Text(isAdded ? "Added" : "Add to Cart"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAdded ? Colors.grey : Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// =======================
// Add to Cart
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
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(item["title"] as String,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text("\$${item["price"]}",
                        style:
                        const TextStyle(color: Colors.white70)),
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
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Checkout successful!"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    setState(() {
                      cart.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
  const AssignmentsPage({super.key});

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
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(
              assignment["title"]!,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "Due: ${assignment["due"]}",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
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
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "Your Learning Progress",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LinearProgressIndicator(
            value: 0.5,
            backgroundColor: Colors.white12,
            color: Colors.greenAccent,
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "50% Completed",
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: ListView(
            children: const [
              Card(
                color: Color(0xFF1E293B),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text("Flutter Development",
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text("70% Completed",
                      style: TextStyle(color: Colors.white70)),
                ),
              ),
              Card(
                color: Color(0xFF1E293B),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text("Data Science",
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text("40% Completed",
                      style: TextStyle(color: Colors.white70)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =======================
// Settings Page
// =======================
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          color: const Color(0xFF1E293B),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text("Profile", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ),
        Card(
          color: const Color(0xFF1E293B),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.lock, color: Colors.white),
            title: const Text("Change Password",
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ),
        Card(
          color: const Color(0xFF1E293B),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white),
            title: const Text("Notifications",
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
