import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  bool _isAvailable = true;
  final Map<String, bool> _workingDays = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': true,
    'Sunday': false,
  };

  final Map<String, TimeOfDay> _startTimes = {
    'Monday': const TimeOfDay(hour: 9, minute: 0),
    'Tuesday': const TimeOfDay(hour: 9, minute: 0),
    'Wednesday': const TimeOfDay(hour: 9, minute: 0),
    'Thursday': const TimeOfDay(hour: 9, minute: 0),
    'Friday': const TimeOfDay(hour: 9, minute: 0),
    'Saturday': const TimeOfDay(hour: 10, minute: 0),
    'Sunday': const TimeOfDay(hour: 10, minute: 0),
  };

  final Map<String, TimeOfDay> _endTimes = {
    'Monday': const TimeOfDay(hour: 22, minute: 0),
    'Tuesday': const TimeOfDay(hour: 22, minute: 0),
    'Wednesday': const TimeOfDay(hour: 22, minute: 0),
    'Thursday': const TimeOfDay(hour: 22, minute: 0),
    'Friday': const TimeOfDay(hour: 22, minute: 0),
    'Saturday': const TimeOfDay(hour: 23, minute: 0),
    'Sunday': const TimeOfDay(hour: 20, minute: 0),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveAvailability,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Manage Your Availability',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            // Overall Availability Toggle
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isAvailable ? Icons.check_circle : Icons.cancel,
                        color: _isAvailable ? Colors.green : Colors.red,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isAvailable ? 'Available for Orders' : 'Not Available',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isAvailable ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            _isAvailable 
                                ? 'You are currently accepting orders'
                                : 'You are not accepting orders',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Working Hours
            Text(
              'Working Hours',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    ..._workingDays.entries.map((entry) => _buildDaySchedule(entry.key, entry.value)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Set All Days',
                    Icons.calendar_today,
                    Colors.blue,
                    () => _setAllDays(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'Weekdays Only',
                    Icons.work,
                    Colors.orange,
                    () => _setWeekdaysOnly(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Weekend Only',
                    Icons.weekend,
                    Colors.purple,
                    () => _setWeekendOnly(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'Clear All',
                    Icons.clear_all,
                    Colors.red,
                    () => _setAllDays(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Availability Status
            Text(
              'Current Status',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildStatusItem(
                      'Overall Status',
                      _isAvailable ? 'Available' : 'Not Available',
                      _isAvailable ? Colors.green : Colors.red,
                      Icons.circle,
                    ),
                    _buildStatusItem(
                      'Active Days',
                      '${_workingDays.values.where((day) => day).length} days',
                      Colors.blue,
                      Icons.calendar_month,
                    ),
                    _buildStatusItem(
                      'Next Available',
                      _getNextAvailableTime(),
                      Colors.orange,
                      Icons.schedule,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(String day, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Checkbox(
                  value: isEnabled,
                  onChanged: (value) {
                    setState(() {
                      _workingDays[day] = value ?? false;
                    });
                  },
                ),
                Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: _buildTimeButton(
                    'Start',
                    _startTimes[day]!,
                    isEnabled,
                    (time) {
                      setState(() {
                        _startTimes[day] = time;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text('to'),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeButton(
                    'End',
                    _endTimes[day]!,
                    isEnabled,
                    (time) {
                      setState(() {
                        _endTimes[day] = time;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String label, TimeOfDay time, bool isEnabled, Function(TimeOfDay) onTimeChanged) {
    return GestureDetector(
      onTap: isEnabled ? () => _selectTime(context, time, onTimeChanged) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.grey[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: isEnabled ? Colors.black : Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime, Function(TimeOfDay) onTimeChanged) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      onTimeChanged(picked);
    }
  }

  void _setAllDays(bool enabled) {
    setState(() {
      for (String day in _workingDays.keys) {
        _workingDays[day] = enabled;
      }
    });
  }

  void _setWeekdaysOnly() {
    setState(() {
      _workingDays['Monday'] = true;
      _workingDays['Tuesday'] = true;
      _workingDays['Wednesday'] = true;
      _workingDays['Thursday'] = true;
      _workingDays['Friday'] = true;
      _workingDays['Saturday'] = false;
      _workingDays['Sunday'] = false;
    });
  }

  void _setWeekendOnly() {
    setState(() {
      _workingDays['Monday'] = false;
      _workingDays['Tuesday'] = false;
      _workingDays['Wednesday'] = false;
      _workingDays['Thursday'] = false;
      _workingDays['Friday'] = false;
      _workingDays['Saturday'] = true;
      _workingDays['Sunday'] = true;
    });
  }

  String _getNextAvailableTime() {
    final now = DateTime.now();
    final today = now.weekday;
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    // Find next available day
    for (int i = 0; i < 7; i++) {
      final checkDay = (today + i) % 7;
      final dayName = dayNames[checkDay];
      
      if (_workingDays[dayName] == true) {
        if (i == 0) {
          // Today
          final startTime = _startTimes[dayName]!;
          final nowTime = TimeOfDay.fromDateTime(now);
          
          if (nowTime.hour < startTime.hour || 
              (nowTime.hour == startTime.hour && nowTime.minute < startTime.minute)) {
            return 'Today at ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
          } else {
            return 'Tomorrow at ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
          }
        } else {
                     final startTime = _startTimes[dayName]!;
           return '$dayName at ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
        }
      }
    }
    
    return 'No availability set';
  }

  void _saveAvailability() {
    // TODO: Implement API call to save availability
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Availability settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
