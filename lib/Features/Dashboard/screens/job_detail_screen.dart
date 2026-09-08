import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailScreen extends StatelessWidget {
final String documentId;
final Map<String, dynamic> jobData;

const JobDetailScreen({
Key? key,
required this.documentId,
required this.jobData,
}) : super(key: key);

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Job Details'),
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// =========================================================
// JOB HEADER
// =========================================================
_buildJobHeader(),

const SizedBox(height: 20),

// =========================================================
// ALL JOB INFORMATION
// =========================================================
...jobData.entries.map(
(entry) {
return _buildField(
context,
entry.key,
entry.value,
0,
);
},
),

const SizedBox(height: 30),
],
),
),
);
}

// =================================================================
// JOB HEADER
// =================================================================

Widget _buildJobHeader() {
final designer =
jobData['designer'] as Map<String, dynamic>?;

final designerData =
designer?['data'] as Map<String, dynamic>?;

final jobNumber =
designerData?['LpmAutoIncrement']?.toString() ??
documentId;

final partyName =
designerData?['PartyName']?.toString() ?? '';

final jobName =
designerData?['particularJobName']?.toString() ?? '';

final delivery =
jobData['delivery'] as Map<String, dynamic>?;

final deliveryData =
delivery?['data'] as Map<String, dynamic>?;

final deliveryStatus =
deliveryData?['DeliveryStatus']?.toString() ?? '';

return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(16),
gradient: LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
Colors.blue.shade50,
Colors.white,
],
),
border: Border.all(
color: Colors.blue.shade100,
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// JOB NUMBER
Text(
jobNumber,
style: const TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),

if (partyName.isNotEmpty) ...[
const SizedBox(height: 8),
Text(
partyName,
style: TextStyle(
fontSize: 17,
color: Colors.grey.shade700,
fontWeight: FontWeight.w500,
),
),
],

if (jobName.isNotEmpty) ...[
const SizedBox(height: 6),
Text(
jobName,
style: TextStyle(
fontSize: 14,
color: Colors.grey.shade600,
),
),
],

const SizedBox(height: 14),

// DELIVERY STATUS
if (deliveryStatus.isNotEmpty)
Container(
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 7,
),
decoration: BoxDecoration(
color: Colors.green.withOpacity(0.1),
borderRadius: BorderRadius.circular(20),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(
Icons.check_circle,
size: 18,
color: Colors.green,
),
const SizedBox(width: 6),
Text(
deliveryStatus,
style: const TextStyle(
color: Colors.green,
fontWeight: FontWeight.bold,
),
),
],
),
),
],
),
);
}

// =================================================================
// BUILD FIELD
// =================================================================

Widget _buildField(
BuildContext context,
String key,
dynamic value,
int level,
) {
// ---------------------------------------------------------------
// MAP
// ---------------------------------------------------------------
if (value is Map) {
return _buildMapSection(
context,
key,
value,
level,
);
}

// ---------------------------------------------------------------
// LIST / ARRAY
// ---------------------------------------------------------------
if (value is List) {
return _buildListSection(
context,
key,
value,
level,
);
}

// ---------------------------------------------------------------
// TIMESTAMP
// ---------------------------------------------------------------
if (value is Timestamp) {
return _buildSimpleField(
context,
key,
_formatTimestamp(value),
level,
);
}

// ---------------------------------------------------------------
// NULL
// ---------------------------------------------------------------
if (value == null) {
return _buildSimpleField(
context,
key,
'null',
level,
);
}

// ---------------------------------------------------------------
// STRING
// ---------------------------------------------------------------
if (value is String) {
return _buildSimpleField(
context,
key,
value,
level,
);
}

// ---------------------------------------------------------------
// BOOLEAN
// ---------------------------------------------------------------
if (value is bool) {
return _buildSimpleField(
context,
key,
value ? 'true' : 'false',
level,
);
}

// ---------------------------------------------------------------
// NUMBER
// ---------------------------------------------------------------
if (value is num) {
return _buildSimpleField(
context,
key,
value.toString(),
level,
);
}

// ---------------------------------------------------------------
// FALLBACK
// ---------------------------------------------------------------
return _buildSimpleField(
context,
key,
value.toString(),
level,
);
}

// =================================================================
// MAP SECTION
// =================================================================

Widget _buildMapSection(
BuildContext context,
String key,
Map map,
int level,
) {
final entries = map.entries.toList();

return Container(
width: double.infinity,
margin: EdgeInsets.only(
left: level * 8.0,
bottom: 12,
),
decoration: BoxDecoration(
color: level == 0
? Colors.grey.shade50
    : Colors.white,
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: Colors.grey.shade300,
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// -----------------------------------------------------------
// SECTION TITLE
// -----------------------------------------------------------
Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 12,
),
decoration: BoxDecoration(
color: Colors.blue.withOpacity(0.06),
borderRadius: const BorderRadius.only(
topLeft: Radius.circular(12),
topRight: Radius.circular(12),
),
),
child: Text(
_formatKey(key),
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
),

// -----------------------------------------------------------
// MAP CONTENT
// -----------------------------------------------------------
Padding(
padding: const EdgeInsets.all(12),
child: Column(
children: entries.map((entry) {
return _buildField(
context,
entry.key.toString(),
entry.value,
level + 1,
);
}).toList(),
),
),
],
),
);
}

// =================================================================
// LIST SECTION
// =================================================================

Widget _buildListSection(
BuildContext context,
String key,
List list,
int level,
) {
return Container(
width: double.infinity,
margin: EdgeInsets.only(
left: level * 8.0,
bottom: 12,
),
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: Colors.grey.shade50,
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: Colors.grey.shade300,
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
_formatKey(key),
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

...list.asMap().entries.map(
(entry) {
final index = entry.key;
final value = entry.value;

if (value is Map) {
return _buildMapSection(
context,
'Item ${index + 1}',
value,
level + 1,
);
}

return Padding(
padding: const EdgeInsets.only(
bottom: 6,
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'${index + 1}. ',
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
Expanded(
child: Text(
_formatValue(value),
),
),
],
),
);
},
),
],
),
);
}

// =================================================================
// SIMPLE FIELD
// =================================================================

Widget _buildSimpleField(
BuildContext context,
String key,
String value,
int level,
) {
final bool isEmpty = value.trim().isEmpty;

// Don't make the UI unnecessarily huge with empty fields.
// The key is still shown, but the value is displayed as "-".
final displayValue = isEmpty ? '-' : value;

final bool isUrl = _isUrl(value);

return Container(
width: double.infinity,
margin: EdgeInsets.only(
left: level * 8.0,
bottom: 8,
),
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 10,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(8),
border: Border.all(
color: Colors.grey.shade200,
),
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// KEY
Expanded(
flex: 4,
child: Text(
_formatKey(key),
style: TextStyle(
fontSize: 13,
color: Colors.grey.shade700,
fontWeight: FontWeight.w600,
),
),
),

const SizedBox(width: 12),

// VALUE
Expanded(
flex: 6,
child: isUrl
? InkWell(
onTap: () => _openUrl(
context,
value,
),
child: Text(
value,
style: const TextStyle(
fontSize: 13,
color: Colors.blue,
decoration:
TextDecoration.underline,
),
),
)
    : Text(
displayValue,
style: const TextStyle(
fontSize: 13,
color: Colors.black87,
),
),
),
],
),
);
}

// =================================================================
// FORMAT KEY
// =================================================================

String _formatKey(String key) {
if (key.isEmpty) {
return key;
}

// Replace underscores with spaces.
String formatted = key.replaceAll('_', ' ');

// Insert space before capital letters.
formatted = formatted.replaceAllMapped(
RegExp(r'(?<=[a-z])(?=[A-Z])'),
(match) => ' ',
);

// Capitalize first character.
if (formatted.isNotEmpty) {
formatted =
formatted[0].toUpperCase() +
formatted.substring(1);
}

return formatted;
}

// =================================================================
// FORMAT VALUE
// =================================================================

String _formatValue(dynamic value) {
if (value == null) {
return 'null';
}

if (value is Timestamp) {
return _formatTimestamp(value);
}

if (value is bool) {
return value ? 'true' : 'false';
}

if (value is Map) {
return value.toString();
}

if (value is List) {
return value.join(', ');
}

return value.toString();
}

// =================================================================
// FORMAT TIMESTAMP
// =================================================================

String _formatTimestamp(Timestamp timestamp) {
final date = timestamp.toDate();

String twoDigits(int value) {
return value.toString().padLeft(2, '0');
}

return '${twoDigits(date.day)}/'
'${twoDigits(date.month)}/'
'${date.year} '
'${twoDigits(date.hour)}:'
'${twoDigits(date.minute)}:'
'${twoDigits(date.second)}';
}

// =================================================================
// CHECK URL
// =================================================================

bool _isUrl(String value) {
return value.startsWith('http://') ||
value.startsWith('https://');
}

// =================================================================
// OPEN URL
// =================================================================

Future<void> _openUrl(
BuildContext context,
String url,
) async {
final uri = Uri.tryParse(url);

if (uri == null) {
return;
}

try {
final launched = await launchUrl(
uri,
mode: LaunchMode.externalApplication,
);

if (!launched && context.mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Could not open this file',
),
),
);
}
} catch (e) {
if (context.mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Could not open file: $e',
),
),
);
}
}
}
}
