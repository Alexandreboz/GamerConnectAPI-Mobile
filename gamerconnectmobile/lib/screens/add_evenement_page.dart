import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/design_system.dart';

class AddEvenementPage extends StatefulWidget {
  final int userId;

  const AddEvenementPage({super.key, required this.userId});

  @override
  State<AddEvenementPage> createState() => _AddEvenementPageState();
}

class _AddEvenementPageState extends State<AddEvenementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _jeuController = TextEditingController();
  final _lieuController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _selectedDate;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _jeuController.dispose();
    _lieuController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final localContext = context;
    final now = DateTime.now();
    final date = await showDatePicker(
      // ignore: use_build_context_synchronously
      context: localContext,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (date == null) return;

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: localContext,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );
    if (time == null) return;

    if (!mounted) return;
    setState(() {
      _selectedDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _dateController.text = _formatDateTime(_selectedDate!);
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sélectionne une date et une heure valides.'),
        backgroundColor: AppColors.accent,
      ));
      return;
    }

    setState(() => _submitting = true);

    final result = await ApiService.createEvenement(
      widget.userId,
      _nameController.text.trim(),
      _descriptionController.text.trim(),
      _dateController.text.trim(),
      _jeuController.text.trim(),
      _lieuController.text.trim(),
    );

    setState(() => _submitting = false);
    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Événement créé avec succès !'),
        backgroundColor: AppColors.green,
      ));
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(result['error']?.toString() ?? 'Erreur lors de la création.'),
      backgroundColor: AppColors.accent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un événement',
            style: AppStyles.heading.copyWith(fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Nom de l’événement'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Description requise'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jeuController,
                decoration: const InputDecoration(labelText: 'Jeu'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Jeu requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lieuController,
                decoration: const InputDecoration(labelText: 'Lieu'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Lieu requis'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date et heure',
                  hintText: 'Sélectionner une date',
                ),
                onTap: _pickDateTime,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Date requise'
                    : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _submitting ? 'Création...' : 'Créer l’événement',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
