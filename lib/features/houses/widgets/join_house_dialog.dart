import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/providers/auth_provider.dart';

class JoinHouseDialog extends ConsumerStatefulWidget {
  const JoinHouseDialog({super.key});

  @override
  ConsumerState<JoinHouseDialog> createState() => _JoinHouseDialogState();
}

class _JoinHouseDialogState extends ConsumerState<JoinHouseDialog> {
  final _houseNameController = TextEditingController();
  final _houseCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _houseNameController.dispose();
    _houseCodeController.dispose();
    super.dispose();
  }

  String _generateHouseCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<void> _createHouse() async {
    final houseName = _houseNameController.text.trim();
    if (houseName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a house name')),
      );
      return;
    }

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String newCode = '';
      bool created = false;

      while (!created) {
        newCode = _generateHouseCode();
        final docRef = FirebaseFirestore.instance
            .collection('houses')
            .doc(newCode);

        try {
          // Use a transaction or just create and catch collision
          // Simple create for now as collision probability is low
          // But to be safe, we check existence first or handle error
          final doc = await docRef.get();
          if (!doc.exists) {
            await docRef.set({
              'houseName': houseName,
              'members': [user.uid],
              'createdAt': FieldValue.serverTimestamp(),
            });
            created = true;
          }
        } catch (e) {
          debugPrint('Error creating house: $e');
          // If error is not related to existence, break
          break;
        }
      }

      if (created && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('House created! Code: $newCode')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating house: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinHouse() async {
    final houseCode = _houseCodeController.text.trim().toUpperCase();
    if (houseCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('House code must be 6 characters')),
      );
      return;
    }

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('houses')
          .doc(houseCode);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'members': FieldValue.arrayUnion([user.uid]),
        });
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Joined house successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('House not found')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error joining house: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Create or Join House',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Create House Section
            TextField(
              controller: _houseNameController,
              decoration: const InputDecoration(
                labelText: 'House Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createHouse,
                child: const Text('CREATE HOUSE'),
              ),
            ),

            const Divider(height: 32),

            // Join House Section
            TextField(
              controller: _houseCodeController,
              decoration: const InputDecoration(
                labelText: 'House Code',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinHouse,
                child: const Text('JOIN HOUSE'),
              ),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }
}
