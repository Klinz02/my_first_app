import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'schedule_screen.dart';

const _ink = Color(0xFF17233B);
const _muted = Color(0xFF78839A);
const _blue = Color(0xFF4A67E8);
const _blueSoft = Color(0xFFEDF1FF);
const _line = Color(0xFFE7EAF1);
const _page = Color(0xFFF6F7FB);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  CollectionReference<Map<String, dynamic>>? get _commitments {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('commitments');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    final firstName = displayName == null || displayName.isEmpty
        ? 'there'
        : displayName.split(RegExp(r'\s+')).first;

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: _page,
        surfaceTintColor: _page,
        titleSpacing: 20,
        title: const Row(
          children: [
            _BrandMark(),
            SizedBox(width: 10),
            Text(
              'linksy go',
              style: TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            icon: const Icon(Icons.logout_rounded, color: _muted),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _selectedTab == 2
            ? const _GroupsPreview()
            : _TodayDashboard(
                firstName: firstName,
                commitments: _commitments,
                onOpenSchedule: _openSchedule,
              ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: _blueSoft,
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          if (index == 1) {
            _openSchedule();
          } else {
            setState(() => _selectedTab = index);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.access_time_rounded),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            label: 'Groups',
          ),
        ],
      ),
    );
  }

  Future<void> _openSchedule() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ScheduleScreen()),
    );
    if (mounted) setState(() => _selectedTab = 0);
  }
}

class _TodayDashboard extends StatelessWidget {
  final String firstName;
  final CollectionReference<Map<String, dynamic>>? commitments;
  final VoidCallback onOpenSchedule;

  const _TodayDashboard({
    required this.firstName,
    required this.commitments,
    required this.onOpenSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel =
        '${_weekdays[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text(
          dateLabel.toUpperCase(),
          style: const TextStyle(
            color: _muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Good ${_greeting()}, $firstName',
          style: const TextStyle(
            color: _ink,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: 22),
        const _HeroCard(),
        const SizedBox(height: 25),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Today’s commitments',
                style: TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onOpenSchedule,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: _blue,
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFDCE3FF)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _TodayCommitments(collection: commitments),
        const SizedBox(height: 20),
        const _StudySuggestionCard(),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A67E8), Color(0xFF7188F4)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -42,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(.16)),
              ),
            ),
          ),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A LITTLE MORE ORGANIZED',
                      style: TextStyle(
                        color: Color(0xFFE3E8FF),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your day, made clearer.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Classes, work and study plans together.',
                      style: TextStyle(color: Color(0xFFE6EAFF), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withOpacity(.95),
                size: 34,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayCommitments extends StatelessWidget {
  final CollectionReference<Map<String, dynamic>>? collection;

  const _TodayCommitments({required this.collection});

  @override
  Widget build(BuildContext context) {
    if (collection == null) {
      return const _EmptyCommitments(
        message: 'Sign in to see your classes, shifts, and deadlines.',
      );
    }

    final date = _dateKey(DateTime.now());
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: collection!.where('date', isEqualTo: date).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _EmptyCommitments(
            message: 'Today’s schedule could not be loaded. Try again shortly.',
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(26),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final items = snapshot.data!.docs
            .map(Commitment.fromDocument)
            .toList()
          ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
        if (items.isEmpty) {
          return const _EmptyCommitments(
            message: 'Nothing planned yet. Add a class, shift, or deadline.',
          );
        }

        return Column(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              _CommitmentTile(item: items[index]),
              if (index < items.length - 1) const SizedBox(height: 9),
            ],
          ],
        );
      },
    );
  }
}

class _CommitmentTile extends StatelessWidget {
  final Commitment item;

  const _CommitmentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(item.type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            child: Text(
              _formatTime(item.startMinutes),
              style: const TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 4,
            height: 43,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_formatTime(item.startMinutes)} – '
                  '${_formatTime(item.endMinutes)}'
                  '${item.location.isEmpty ? '' : ' · ${item.location}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5F8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.type,
              style: const TextStyle(color: _muted, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCommitments extends StatelessWidget {
  final String message;

  const _EmptyCommitments({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 19),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_note_outlined, color: _blue, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: _muted, fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
      );
}

class _StudySuggestionCard extends StatelessWidget {
  const _StudySuggestionCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5FF),
          border: Border.all(color: const Color(0xFFE6EAFF)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'STUDY SUGGESTION',
              style: TextStyle(
                color: _blue,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Make room for a focused study session',
              style: TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add your classes and shifts to see where study time could fit.',
              style: TextStyle(color: _muted, fontSize: 11, height: 1.45),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ScheduleScreen(),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: Color(0xFFDCE3FF)),
                backgroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Adjust schedule'),
            ),
          ],
        ),
      );
}

class _GroupsPreview extends StatelessWidget {
  const _GroupsPreview();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          const Text(
            'STAY IN TOUCH',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Your groups',
            style: TextStyle(
              color: _ink,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Project conversations and files in one place.',
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          const SizedBox(height: 22),
          const _GroupPreviewTile(
            initial: 'B',
            title: 'Biology project',
            subtitle: '4 members · group',
            color: _blue,
            background: _blueSoft,
          ),
          const SizedBox(height: 9),
          const _GroupPreviewTile(
            initial: 'H',
            title: 'History presentation',
            subtitle: '3 members · group',
            color: Color(0xFFBB6416),
            background: Color(0xFFFFF1E4),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Group conversations and direct messaging are the next part of the LinksyGo build.',
              style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      );
}

class _GroupPreviewTile extends StatelessWidget {
  final String initial;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;

  const _GroupPreviewTile({
    required this.initial,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: background,
              foregroundColor: color,
              child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: _ink, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _muted),
          ],
        ),
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          color: _blue,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const Text(
          'L',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      );
}

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'morning';
  if (hour < 17) return 'afternoon';
  return 'evening';
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _formatTime(int value) {
  final hour = value ~/ 60;
  final minute = value % 60;
  final suffix = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
}

Color _typeColor(String type) => switch (type) {
      'Work' => const Color(0xFFF3A648),
      'Deadline' => const Color(0xFFEF6B76),
      _ => _blue,
    };
