import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  bool _saving = false;
  String? _actionMessage;

  CollectionReference<Map<String, dynamic>>? get _commitments {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('commitments');
  }

  DateTime get _weekStart =>
      _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _editCommitment({Commitment? initial}) async {
    final collection = _commitments;
    if (collection == null) return;

    final commitment = await showDialog<Commitment>(
      context: context,
      builder: (_) =>
          CommitmentEditor(initial: initial, initialDate: _selectedDate),
    );
    if (commitment == null || !mounted) return;

    setState(() {
      _saving = true;
      _actionMessage = null;
    });
    try {
      final values = commitment.toMap();
      if (commitment.id == null) {
        await collection.add(values);
      } else {
        await collection.doc(commitment.id).set(values);
      }
      if (mounted) setState(() => _actionMessage = 'Commitment saved.');
    } on FirebaseException catch (error) {
      if (mounted) {
        setState(
          () => _actionMessage =
              'Could not save this commitment. ${error.message ?? ''}',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteCommitment(Commitment item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete commitment?'),
        content: Text('Remove "${item.title}" from your schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      await _commitments?.doc(item.id).delete();
      if (mounted) setState(() => _actionMessage = 'Commitment deleted.');
    } on FirebaseException catch (error) {
      if (mounted) {
        setState(
          () => _actionMessage =
              'Could not delete this commitment. ${error.message ?? ''}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final collection = _commitments;
    if (user == null || collection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schedule')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Sign in to manage your schedule.'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : () => _editCommitment(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Previous week',
                    onPressed: () => setState(
                      () => _selectedDate = _selectedDate.subtract(
                        const Duration(days: 7),
                      ),
                    ),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    '${_shortDate(_weekStart)} – '
                    '${_shortDate(_weekStart.add(const Duration(days: 6)))}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    tooltip: 'Next week',
                    onPressed: () => setState(
                      () => _selectedDate = _selectedDate.add(
                        const Duration(days: 7),
                      ),
                    ),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 72,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final day = _weekStart.add(Duration(days: index));
                  final selected = DateUtils.isSameDay(day, _selectedDate);
                  return ChoiceChip(
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedDate = day),
                    label: SizedBox(
                      width: 44,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_weekday(day.weekday)),
                          Text('${day.day}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_actionMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(
                  _actionMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: collection.orderBy('date').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Schedule could not be loaded. Check your connection and Firebase access rules.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items =
                      snapshot.data!.docs
                          .map(Commitment.fromDocument)
                          .where((item) => item.date == _dateKey(_selectedDate))
                          .toList()
                        ..sort(
                          (a, b) => a.startMinutes.compareTo(b.startMinutes),
                        );

                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_note_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No commitments for ${_longDate(_selectedDate)}.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Add a class, work shift, or deadline to get started.',
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _typeColor(
                              context,
                              item.type,
                            ).withOpacity(0.12),
                            child: Icon(
                              _typeIcon(item.type),
                              color: _typeColor(context, item.type),
                            ),
                          ),
                          title: Text(item.title),
                          subtitle: Text(
                            '${item.type} · ${_formatMinutes(context, item.startMinutes)}–'
                            '${_formatMinutes(context, item.endMinutes)}'
                            '${item.location.isEmpty ? '' : '\n${item.location}'}',
                          ),
                          isThreeLine: item.location.isNotEmpty,
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) {
                              if (action == 'edit') {
                                _editCommitment(initial: item);
                              } else if (action == 'delete') {
                                _deleteCommitment(item);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
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
      ),
    );
  }

  static String _shortDate(DateTime date) =>
      '${date.day} ${_month(date.month)}';
  static String _longDate(DateTime date) =>
      '${_weekday(date.weekday)}, ${date.day} ${_month(date.month)}';
  static String _weekday(int day) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];
  static String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  static String _formatMinutes(BuildContext context, int value) =>
      TimeOfDay(hour: value ~/ 60, minute: value % 60).format(context);

  static IconData _typeIcon(String type) => switch (type) {
    'Work' => Icons.work_outline,
    'Deadline' => Icons.flag_outlined,
    _ => Icons.school_outlined,
  };

  static Color _typeColor(BuildContext context, String type) => switch (type) {
    'Work' => Colors.orange.shade800,
    'Deadline' => Colors.pink.shade700,
    _ => Theme.of(context).colorScheme.primary,
  };
}

class Commitment {
  final String? id;
  final String title;
  final String type;
  final String date;
  final int startMinutes;
  final int endMinutes;
  final String location;

  const Commitment({
    this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    required this.location,
  });

  factory Commitment.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return Commitment(
      id: document.id,
      title: data['title'] as String? ?? '',
      type: data['type'] as String? ?? 'Class',
      date: data['date'] as String? ?? '',
      startMinutes: data['startMinutes'] as int? ?? 540,
      endMinutes: data['endMinutes'] as int? ?? 600,
      location: data['location'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'type': type,
    'date': date,
    'startMinutes': startMinutes,
    'endMinutes': endMinutes,
    'location': location,
  };
}

class CommitmentEditor extends StatefulWidget {
  final Commitment? initial;
  final DateTime initialDate;

  const CommitmentEditor({super.key, this.initial, required this.initialDate});

  @override
  State<CommitmentEditor> createState() => _CommitmentEditorState();
}

class _CommitmentEditorState extends State<CommitmentEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late String _type;
  late DateTime _date;
  late TimeOfDay _start;
  late TimeOfDay _end;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    _titleController = TextEditingController(text: item?.title ?? '');
    _locationController = TextEditingController(text: item?.location ?? '');
    _type = item?.type ?? 'Class';
    _date = DateTime.tryParse(item?.date ?? '') ?? widget.initialDate;
    _start = item == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay(
            hour: item.startMinutes ~/ 60,
            minute: item.startMinutes % 60,
          );
    _end = item == null
        ? const TimeOfDay(hour: 10, minute: 0)
        : TimeOfDay(hour: item.endMinutes ~/ 60, minute: item.endMinutes % 60);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initial == null ? 'Add commitment' : 'Edit commitment',
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a name.'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const ['Class', 'Work', 'Deadline']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _type = value ?? 'Class'),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Date'),
                  subtitle: Text(_longDate(_date)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _date = DateUtils.dateOnly(picked));
                    }
                  },
                ),
                Row(
                  children: [
                    Expanded(child: _timeTile('Starts', _start, true)),
                    Expanded(child: _timeTile('Ends', _end, false)),
                  ],
                ),
                if (_timeError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _timeError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location or note (optional)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Widget _timeTile(String label, TimeOfDay value, bool startTime) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value.format(context)),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value,
        );
        if (picked != null) {
          setState(() {
            if (startTime) {
              _start = picked;
            } else {
              _end = picked;
            }
            _timeError = null;
          });
        }
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_minutes(_end) <= _minutes(_start)) {
      setState(() => _timeError = 'End time must be after start time.');
      return;
    }
    Navigator.pop(
      context,
      Commitment(
        id: widget.initial?.id,
        title: _titleController.text.trim(),
        type: _type,
        date: _ScheduleScreenState._dateKey(_date),
        startMinutes: _minutes(_start),
        endMinutes: _minutes(_end),
        location: _locationController.text.trim(),
      ),
    );
  }

  static String _longDate(DateTime date) =>
      '${_ScheduleScreenState._weekday(date.weekday)}, ${date.day} '
      '${_ScheduleScreenState._month(date.month)}';
}
