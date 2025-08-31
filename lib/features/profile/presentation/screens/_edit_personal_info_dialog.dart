import 'package:flutter/material.dart';

class _EditPersonalInfoDialog extends StatefulWidget {
  final String? age;
  final String? gender;
  final String? height;
  final String? weight;

  const _EditPersonalInfoDialog({
    this.age,
    this.gender,
    this.height,
    this.weight,
  });

  @override
  State<_EditPersonalInfoDialog> createState() =>
      _EditPersonalInfoDialogState();
}

class _EditPersonalInfoDialogState extends State<_EditPersonalInfoDialog> {
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: widget.age);
    _heightController = TextEditingController(text: widget.height);
    _weightController = TextEditingController(text: widget.weight);
    _gender = widget.gender;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Personal Info'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
                DropdownMenuItem(
                    value: 'Prefer not to say',
                    child: Text('Prefer not to say')),
              ],
              onChanged: (String? val) => setState(() => _gender = val),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(<String, String?>{
              'age': _ageController.text,
              'gender': _gender,
              'height': _heightController.text,
              'weight': _weightController.text,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
