import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_card.dart';

class SubAccountsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> subAccounts;
  final String mainAccountName;
  final Function(List<Map<String, dynamic>>) onSubAccountsChanged;

  const SubAccountsScreen({
    super.key,
    required this.subAccounts,
    required this.mainAccountName,
    required this.onSubAccountsChanged,
  });

  @override
  State<SubAccountsScreen> createState() => _SubAccountsScreenState();
}

class _SubAccountsScreenState extends State<SubAccountsScreen> {
  late List<Map<String, dynamic>> _subAccounts;

  @override
  void initState() {
    super.initState();
    _subAccounts = List.from(widget.subAccounts);
  }

  void _addSubAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubAccountEditorScreen(
          mainAccountName: widget.mainAccountName,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _subAccounts.add(result);
      });
      widget.onSubAccountsChanged(_subAccounts);
      _showSuccessSnackBar('Sub-account added');
    }
  }

  void _editSubAccount(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubAccountEditorScreen(
          mainAccountName: widget.mainAccountName,
          subAccount: _subAccounts[index],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _subAccounts[index] = result;
      });
      widget.onSubAccountsChanged(_subAccounts);
      _showSuccessSnackBar('Sub-account updated');
    }
  }

  void _deleteSubAccount(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              const Text(
                'Delete Sub-Account?',
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone.',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _subAccounts.removeAt(index);
      });
      widget.onSubAccountsChanged(_subAccounts);
      _showSuccessSnackBar('Sub-account deleted');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _subAccounts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _subAccounts.length,
                        itemBuilder: (context, index) {
                          return _buildSubAccountCard(index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSubAccount,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('Add Sub-Account'),
      ).animate().scale(delay: 300.ms),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfaceColor.withOpacity(0.5),
              foregroundColor: Colors.white,
            ),
          ).animate().scale(duration: 300.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sub-Accounts',
                  style: AppTheme.headingMedium,
                ).animate().fadeIn().slideX(begin: -0.2, duration: 300.ms),
                Text(
                  'Linked to ${widget.mainAccountName}',
                  style: AppTheme.caption,
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_subAccounts.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ).animate().scale(delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_tree,
              size: 80,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Sub-Accounts Yet',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add accounts linked to ${widget.mainAccountName}',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn().scale(duration: 400.ms),
    );
  }

  Widget _buildSubAccountCard(int index) {
    final subAccount = _subAccounts[index];
    final identifiers = subAccount['identifiers'] as List?;
    final hasPassword = subAccount['accountPassword'] != null && 
                        (subAccount['accountPassword'] as String).isNotEmpty;
    final hasSubscription = subAccount['hasSubscription'] == true;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        gradient: [
          Colors.deepPurple.withOpacity(0.2),
          Colors.deepPurple.withOpacity(0.05),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Account Name and Actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subAccount['accountName']?.toString() ?? 'Sub-Account',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _editSubAccount(index),
                  icon: const Icon(Icons.edit, color: Colors.white70),
                ),
                IconButton(
                  onPressed: () => _deleteSubAccount(index),
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                ),
              ],
            ),
            
            // Identifiers Section
            if (identifiers != null && identifiers.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              ...identifiers.map((identifier) {
                final type = identifier['type']?.toString() ?? 'ID';
                final value = identifier['value']?.toString() ?? '';
                if (value.isEmpty) return const SizedBox.shrink();
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _getIdentifierIcon(type),
                        color: Colors.white60,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              value,
                              style: AppTheme.caption.copyWith(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        color: Colors.white38,
                        onPressed: () => _copyToClipboard(value, 'Copied $type'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            
            // Password Section
            if (hasPassword) ...[
              const SizedBox(height: 8),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.lock, color: Colors.white60, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '••••••••',
                          style: AppTheme.caption.copyWith(
                            color: Colors.white70,
                            fontSize: 13,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    color: Colors.white38,
                    onPressed: () => _copyToClipboard(
                      subAccount['accountPassword']?.toString() ?? '',
                      'Password copied',
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
            
            // Subscription Section
            if (hasSubscription) ...[
              const SizedBox(height: 8),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.deepPurple.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.subscriptions,
                          color: Colors.deepPurple,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subAccount['planName']?.toString() ?? 'Subscription',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (subAccount['subscriptionStartDate'] != null ||
                        subAccount['subscriptionEndDate'] != null) ...[
                      const SizedBox(height: 8),
                      if (subAccount['subscriptionStartDate'] != null)
                        _buildDateRow(
                          'Start Date',
                          subAccount['subscriptionStartDate'].toString(),
                        ),
                      if (subAccount['subscriptionEndDate'] != null) ...[
                        if (subAccount['subscriptionStartDate'] != null)
                          const SizedBox(height: 4),
                        _buildDateRow(
                          'End Date',
                          subAccount['subscriptionEndDate'].toString(),
                          isEndDate: true,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ).animate().fadeIn(delay: (100 + index * 50).ms).slideX(begin: -0.2),
    );
  }
  
  IconData _getIdentifierIcon(String type) {
    switch (type.toLowerCase()) {
      case 'email':
        return Icons.email;
      case 'phone number':
        return Icons.phone;
      case 'username':
        return Icons.person;
      default:
        return Icons.info;
    }
  }
  
  Widget _buildDateRow(String label, String dateString, {bool isEndDate = false}) {
    DateTime? date;
    try {
      date = DateTime.parse(dateString);
    } catch (e) {
      return const SizedBox.shrink();
    }
    
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final now = DateTime.now();
    final isExpired = isEndDate && date.isBefore(now);
    final isExpiringSoon = isEndDate && 
                          date.isAfter(now) && 
                          date.difference(now).inDays <= 30;
    
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
        Text(
          formattedDate,
          style: TextStyle(
            color: isExpired 
                ? Colors.red 
                : isExpiringSoon 
                    ? Colors.orange 
                    : Colors.white70,
            fontSize: 12,
            fontWeight: isExpired || isExpiringSoon ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isExpired) ...[
          const SizedBox(width: 4),
          const Icon(Icons.warning, color: Colors.red, size: 12),
        ] else if (isExpiringSoon) ...[
          const SizedBox(width: 4),
          const Icon(Icons.warning_amber, color: Colors.orange, size: 12),
        ],
      ],
    );
  }
  
  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Sub-Account Editor Screen
class SubAccountEditorScreen extends StatefulWidget {
  final String mainAccountName;
  final Map<String, dynamic>? subAccount;

  const SubAccountEditorScreen({
    super.key,
    required this.mainAccountName,
    this.subAccount,
  });

  @override
  State<SubAccountEditorScreen> createState() => _SubAccountEditorScreenState();
}

class _SubAccountEditorScreenState extends State<SubAccountEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _accountNameController;
  List<Map<String, dynamic>> _identifiers = [];
  late TextEditingController _passwordController;
  bool _showPassword = false;
  bool _hasSubscription = false;
  late TextEditingController _planNameController;
  DateTime? _subscriptionStartDate;
  DateTime? _subscriptionEndDate;

  @override
  void initState() {
    super.initState();
    
    if (widget.subAccount != null) {
      _loadSubAccountData(widget.subAccount!);
    } else {
      _accountNameController = TextEditingController();
      _passwordController = TextEditingController();
      _planNameController = TextEditingController();
    }
  }

  void _loadSubAccountData(Map<String, dynamic> data) {
    _accountNameController = TextEditingController(
      text: data['accountName']?.toString() ?? '',
    );
    _passwordController = TextEditingController(
      text: data['accountPassword']?.toString() ?? '',
    );
    _planNameController = TextEditingController(
      text: data['planName']?.toString() ?? '',
    );
    _hasSubscription = data['hasSubscription'] == true;
    
    if (data['identifiers'] != null) {
      _identifiers = (data['identifiers'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    
    if (data['subscriptionStartDate'] != null) {
      _subscriptionStartDate = DateTime.parse(data['subscriptionStartDate'].toString());
    }
    
    if (data['subscriptionEndDate'] != null) {
      _subscriptionEndDate = DateTime.parse(data['subscriptionEndDate'].toString());
    }
  }

  void _saveSubAccount() {
    if (!_formKey.currentState!.validate()) return;

    final result = {
      'accountName': _accountNameController.text,
      'identifiers': _identifiers,
      'accountPassword': _passwordController.text,
      'hasSubscription': _hasSubscription,
      'planName': _planNameController.text,
      'subscriptionStartDate': _subscriptionStartDate?.toIso8601String(),
      'subscriptionEndDate': _subscriptionEndDate?.toIso8601String(),
    };

    Navigator.pop(context, result);
  }

  void _addIdentifier() {
    setState(() {
      _identifiers.add({
        'type': 'Username',
        'value': '',
      });
    });
  }

  void _removeIdentifier(int index) {
    setState(() {
      _identifiers.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? (_subscriptionStartDate ?? DateTime.now())
        : (_subscriptionEndDate ?? DateTime.now());
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _subscriptionStartDate = pickedDate;
        } else {
          _subscriptionEndDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAccountNameField(),
                        const SizedBox(height: 16),
                        _buildIdentifiersSection(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 16),
                        _buildSubscriptionSection(),
                        const SizedBox(height: 30),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfaceColor.withOpacity(0.5),
              foregroundColor: Colors.white,
            ),
          ).animate().scale(duration: 300.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subAccount == null ? 'New Sub-Account' : 'Edit Sub-Account',
                  style: AppTheme.headingMedium,
                ).animate().fadeIn().slideX(begin: -0.2, duration: 300.ms),
                Text(
                  'For ${widget.mainAccountName}',
                  style: AppTheme.caption,
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountNameField() {
    return GlassCard(
      child: TextFormField(
        controller: _accountNameController,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Account Name',
          labelStyle: TextStyle(color: Colors.white70),
          hintText: 'e.g., Facebook, Netflix, Instagram',
          hintStyle: TextStyle(color: Colors.white38),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          icon: Icon(Icons.business, color: Colors.white70),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter account name';
          }
          return null;
        },
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2);
  }

  Widget _buildIdentifiersSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.person, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Username / Email / Number',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _addIdentifier,
                icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                tooltip: 'Add identifier',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_identifiers.isEmpty)
            Center(
              child: TextButton.icon(
                onPressed: _addIdentifier,
                icon: const Icon(Icons.add, color: Colors.white70),
                label: const Text(
                  'Add username, email or number',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            ..._identifiers.asMap().entries.map((entry) {
              final index = entry.key;
              final identifier = entry.value;
              return _buildIdentifierField(index, identifier);
            }).toList(),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: -0.2);
  }

  Widget _buildIdentifierField(int index, Map<String, dynamic> identifier) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: identifier['type'] ?? 'Username',
                    dropdownColor: AppTheme.surfaceColor,
                    style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: TextStyle(color: Colors.white70, fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.only(left: 12, right: 12,),
                    ),
                    items: ['Username', 'Email', 'Phone Number', 'Other']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _identifiers[index]['type'] = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => _removeIdentifier(index),
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                  tooltip: 'Remove',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: identifier['value'] ?? '',
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Value',
                labelStyle: TextStyle(color: Colors.white70, fontSize: 12),
                hintText: 'Enter value',
                hintStyle: TextStyle(color: Colors.white38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.only(left: 12, right: 12,),
              ),
              onChanged: (value) {
                _identifiers[index]['value'] = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter value';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      children: [
        // Password Security Warning
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade300,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Security Note: Passwords are stored in plain text. For maximum security, encrypt the main account note using the encryption toggle.',
                  style: TextStyle(
                    color: Colors.orange.shade100,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 280.ms),
        
        const SizedBox(height: 16),
        
        // Password Field (Optional)
        GlassCard(
          child: TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: 'Password (Optional)',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'Leave empty if not needed',
              hintStyle: const TextStyle(color: Colors.white38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              icon: const Icon(Icons.lock, color: Colors.white70),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _showPassword = !_showPassword),
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
              ),
            ),
            // No validator - field is optional
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2),
      ],
    );
  }

  Widget _buildSubscriptionSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.subscriptions, color: Colors.white70),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Has Subscription',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch(
                value: _hasSubscription,
                onChanged: (value) => setState(() => _hasSubscription = value),
                activeColor: Colors.deepPurple,
              ),
            ],
          ),
          if (_hasSubscription) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            // Plan Name
            TextFormField(
              controller: _planNameController,
              style: const TextStyle(color: Colors.white),
              decoration:  InputDecoration(
                labelText: 'Plan Name (Optional)',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'e.g., Premium, Pro, Business',
                hintStyle: TextStyle(color: Colors.white38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                icon: Icon(Icons.card_membership, color: Colors.white70),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Start Date
            InkWell(
              onTap: () => _selectDate(context, true),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Start Date (Optional)',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  icon: Icon(Icons.calendar_today, color: Colors.white70),
                ),
                child: Text(
                  _subscriptionStartDate != null
                      ? _subscriptionStartDate!.toString().split(' ')[0]
                      : 'Select start date',
                  style: TextStyle(
                    color: _subscriptionStartDate != null
                        ? Colors.white
                        : Colors.white38,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // End Date
            InkWell(
              onTap: () => _selectDate(context, false),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'End Date (Optional)',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  icon: Icon(Icons.event, color: Colors.white70),
                ),
                child: Text(
                  _subscriptionEndDate != null
                      ? _subscriptionEndDate!.toString().split(' ')[0]
                      : 'Select end date',
                  style: TextStyle(
                    color: _subscriptionEndDate != null
                        ? Colors.white
                        : Colors.white38,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: -0.2);
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveSubAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save),
            const SizedBox(width: 8),
            Text(
              widget.subAccount == null ? 'Create Sub-Account' : 'Update Sub-Account',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).scale(duration: 300.ms);
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _passwordController.dispose();
    _planNameController.dispose();
    super.dispose();
  }
}

