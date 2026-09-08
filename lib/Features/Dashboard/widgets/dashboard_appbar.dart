import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/core/session/session_manager.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final String username;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;

  const DashboardAppBar({
    Key? key,
    this.showBack = false,
    this.onBack,
    required this.username,
    this.searchController,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  State<DashboardAppBar> createState() => _DashboardAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DashboardAppBarState extends State<DashboardAppBar>
    with SingleTickerProviderStateMixin {
  bool _searchOpen = false;
  late AnimationController _animController;
  late Animation<double> _widthAnim;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _widthAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      _animController.forward();
      Future.delayed(
        const Duration(milliseconds: 260),
            () => _focusNode.requestFocus(),
      );
    } else {
      _animController.reverse();
      _focusNode.unfocus();
      widget.searchController?.clear();
      widget.onSearchChanged?.call('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blueGrey.shade50,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,

      // ── Leading: Drawer / Back button ──────────────────────────────
      leading: widget.showBack
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: widget.onBack ?? () => context.pop(),
      )
          : Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),

      // ── Title: Dashboard + username, collapses when search opens ───
      title: Row(
        children: [
          if (!_searchOpen)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    widget.username,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

          // Animated expanding search bar
          AnimatedBuilder(
            animation: _widthAnim,
            builder: (context, _) {
              final maxW = MediaQuery.of(context).size.width * 0.52;
              final currentW = maxW * _widthAnim.value;
              if (currentW <= 10) return const SizedBox.shrink();
              return SizedBox(
                width: currentW,
                child: Container(
                  height: 36,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: widget.searchController,
                    focusNode: _focusNode,
                    onChanged: widget.onSearchChanged,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 9,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          if (_searchOpen) const Spacer(),
        ],
      ),

      // ── Actions: Search · Notifications · Profile ──────────────────
      actions: [
        // Search toggle / close
        IconButton(
          tooltip: _searchOpen ? 'Close search' : 'Search',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _searchOpen ? Icons.close : Icons.search,
              key: ValueKey(_searchOpen),
              color: Colors.black87,
              size: 22,
            ),
          ),
          onPressed: _toggleSearch,
        ),

        // Notifications — push so the shell child swaps correctly
        // and the back button returns to /dashboard
        IconButton(
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_none, color: Colors.black87),
          onPressed: () {
            final session = SessionManager.getSession();
            context.push(
              '/notifications',
              extra: {
                'partyName': widget.username,
                'email': session?['email'] ?? '',
              },
            );
          },
        ),

        // Profile
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: IconButton(
            tooltip: 'Profile',
            icon: Image.asset(
              'assets/user.png',
              width: 22,
              height: 22,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.person, size: 22, color: Colors.black87),
            ),
            onPressed: () => context.push('/customer-profile'),
          ),
        ),
      ],
    );
  }
}