import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../services/firebase_service.dart';

class MasterItemEditor extends StatefulWidget {
  const MasterItemEditor({super.key});

  @override
  State<MasterItemEditor> createState() => _MasterItemEditorState();
}

class _MasterItemEditorState extends State<MasterItemEditor> {
  final _firebaseService = FirebaseService();

  void _addItem() {
    showDialog(
      context: context,
      builder: (_) => const ItemEditDialog(item: null),
    );
  }

  void _editItem(MenuItem item) {
    showDialog(
      context: context,
      builder: (_) => ItemEditDialog(item: item),
    );
  }

  void _deleteItem(MenuItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _firebaseService.deleteMenuMasterItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Item deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master Menu Items')),
      body: StreamBuilder<List<MenuItem>>(
        stream: _firebaseService.streamMenuMaster(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No items yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addItem,
                    child: const Text('Add First Item'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('${item.meal} • ₹${item.price}'),
                trailing: PopupMenuButton(
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: () => _editItem(item),
                    ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () => _deleteItem(item),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ItemEditDialog extends StatefulWidget {
  final MenuItem? item;

  const ItemEditDialog({super.key, required this.item});

  @override
  State<ItemEditDialog> createState() => _ItemEditDialogState();
}

class _ItemEditDialogState extends State<ItemEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _imageUrlController;
  late String _selectedMeal;
  final _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(
      text: widget.item?.price.toString() ?? '',
    );
    _descController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.item?.imageUrl ?? '',
    );
    _selectedMeal = widget.item?.meal ?? 'breakfast';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    final item = MenuItem(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      price: int.tryParse(_priceController.text) ?? 0,
      meal: _selectedMeal,
      enabled: true,
      imageUrl: _imageUrlController.text,
      description: _descController.text,
    );

    if (widget.item == null) {
      await _firebaseService.addMenuMasterItem(item);
    } else {
      await _firebaseService.updateMenuMasterItem(item.id, item);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item ${widget.item == null ? 'added' : 'updated'}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedMeal,
              decoration: const InputDecoration(labelText: 'Meal Type'),
              items: [
                'breakfast',
                'lunch',
                'snack',
                'dinner',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) =>
                  setState(() => _selectedMeal = v ?? 'breakfast'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
