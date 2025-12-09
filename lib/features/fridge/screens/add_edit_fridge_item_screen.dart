import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/houses_provider.dart';
import '../models/fridge_item.dart';
import '../providers/fridge_provider.dart';

class AddEditFridgeItemScreen extends ConsumerStatefulWidget {
  final FridgeItem? item;

  const AddEditFridgeItemScreen({super.key, this.item});

  @override
  ConsumerState<AddEditFridgeItemScreen> createState() =>
      _AddEditFridgeItemScreenState();
}

class _AddEditFridgeItemScreenState
    extends ConsumerState<AddEditFridgeItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late FridgeCategory _selectedCategory;
  late StorageLocation _selectedLocation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '1',
    );
    _unitController = TextEditingController(text: widget.item?.unit ?? 'pcs');
    _selectedCategory = widget.item?.category ?? FridgeCategory.other;
    _selectedLocation = widget.item?.location ?? StorageLocation.fridge;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final houseId = ref.read(currentHouseIdProvider);
    if (houseId == null) return;

    final name = _nameController.text.trim();
    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    final unit = _unitController.text.trim();

    try {
      if (widget.item == null) {
        // Add new item
        final newItem = FridgeItem(
          id: '', // Will be ignored by Firestore add() if not set manually, but we need structure.
          // Actually Firestore 'add' generates ID. We can pass empty string and Firestore ignores it or we let Repo handle it?
          // The Repo 'addFridgeItem' calls .add(item.toMap()). ID in map is not used by add().
          name: name,
          category: _selectedCategory,
          quantity: quantity,
          unit: unit,
          houseId: houseId,
          location: _selectedLocation,
          status: StockStatus.inStock,
        );
        await ref
            .read(fridgeRepositoryProvider)
            .addFridgeItem(houseId, newItem);
      } else {
        // Update existing item
        final updatedItem = widget.item!.copyWith(
          name: name,
          category: _selectedCategory,
          quantity: quantity,
          unit: unit,
          location: _selectedLocation,
        );
        await ref
            .read(fridgeRepositoryProvider)
            .updateFridgeItem(houseId, updatedItem);
      }

      if (mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving item: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter quantity'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit (e.g. pcs, L)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FridgeCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: FridgeCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<StorageLocation>(
                value: _selectedLocation,
                decoration: const InputDecoration(labelText: 'Location'),
                items: StorageLocation.values.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedLocation = value);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveItem,
                child: Text(widget.item == null ? 'Add Item' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
