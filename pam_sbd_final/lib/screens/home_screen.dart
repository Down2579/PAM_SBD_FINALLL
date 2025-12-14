import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';
import '../models.dart';
import '../../notification_provider.dart';
import 'detail_screen.dart';
import 'all_items_screen.dart';
import 'my_task_screen.dart';
import 'completed_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // ================= COLORS PALETTE =================
  final Color bgPage = const Color(0xFFF1F3F7);
  final Color darkNavy = const Color(0xFF0F3460);
  final Color cardNavy = const Color(0xFF16213E);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGrey = const Color(0xFF9CA3AF);
  final Color successGreen = const Color(0xFF10B981);
  final Color warningOrange = const Color(0xFFF59E0B);

  final String baseUrlImage = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BarangProvider>(context, listen: false)
          .fetchBarang(refresh: true);
      Provider.of<GeneralProvider>(context, listen: false).loadNotifikasi();
      Provider.of<NotifikasiProvider>(context, listen: false)
          .fetchNotifikasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(context),
      const MyTaskScreen(),
      const CompletedScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: bgPage,
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: darkNavy,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 28), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined, size: 28),
                label: "Task"),
            BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline_rounded, size: 28),
                label: "Done"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded, size: 28),
                label: "Profile"),
          ],
        ),
      ),
    );
  }

  // ================= DASHBOARD =================
  Widget _buildDashboard(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: _cardDecoration(),
                      child: Icon(Icons.inventory_2,
                          color: darkNavy, size: 28),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hello,",
                            style:
                                TextStyle(fontSize: 14, color: textGrey)),
                        Text(
                          user?.namaLengkap ?? 'Guest',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkNavy),
                        ),
                      ],
                    ),
                  ],
                ),
                Consumer<NotifikasiProvider>(
                  builder: (context, notifProv, _) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_none_rounded,
                              size: 30, color: darkNavy),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationScreen()),
                            ).then((_) =>
                                notifProv.fetchNotifikasi());
                          },
                        ),
                        if (notifProv.unreadCount > 0)
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // SEARCH
            Container(
              decoration: _cardDecoration(),
              child: TextField(
                controller: _searchController,
                onSubmitted: (v) {
                  if (v.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AllItemsScreen(filterType: 'All', searchQuery: v),
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  hintText: "Search items...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // BIG STATUS CARD
            Row(
              children: [
                _buildBigStatusCard(
                    "Found", Icons.check_circle_outline, 'Found'),
                const SizedBox(width: 16),
                _buildBigStatusCard(
                    "Lost", Icons.help_outline, 'Lost'),
              ],
            ),

            const SizedBox(height: 30),

            // RECENT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Items",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkNavy)),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const AllItemsScreen(filterType: 'All')),
                  ),
                  child: const Text("See All"),
                ),
              ],
            ),

            Consumer<BarangProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final list = provider.listBarang.take(5).toList();
                return ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 16),
                  itemBuilder: (_, i) =>
                      _buildRecentItemCard(list[i]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= BIG STATUS CARD =================
  Widget _buildBigStatusCard(
      String title, IconData icon, String filterType) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  AllItemsScreen(filterType: filterType)),
        ),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardNavy.withOpacity(0.95),
                cardNavy.withOpacity(0.75),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: cardNavy.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward,
                      color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= RECENT ITEM CARD =================
  Widget _buildRecentItemCard(Barang item) {
    final isLost = item.tipeLaporan == 'hilang';
    final tagText = isLost ? "LOST" : "FOUND";
    final tagColor =
        isLost ? warningOrange : successGreen;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DetailScreen(item: item)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white, width: 1.5),
                image: item.gambarUrl != null &&
                        item.gambarUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(
                          item.gambarUrl!.startsWith('http')
                              ? item.gambarUrl!
                              : '$baseUrlImage${item.gambarUrl}',
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: darkNavy,
              ),
              child: item.gambarUrl == null ||
                      item.gambarUrl!.isEmpty
                  ? const Icon(Icons.inventory_2,
                      color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          tagColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      tagText,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: tagColor,
                          letterSpacing: 0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(item.namaBarang,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textDark)),
                  const SizedBox(height: 4),
                  Text(item.lokasi?.namaLokasi ?? '-',
                      style: TextStyle(
                          fontSize: 12,
                          color: textGrey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  // ================= CARD DECORATION =================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border:
          Border.all(color: Colors.black.withOpacity(0.04)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.6),
          blurRadius: 1,
          offset: const Offset(0, -1),
        ),
      ],
    );
  }
}
