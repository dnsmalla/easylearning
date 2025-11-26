// auto_cursor - 2025-08-30
// Intelligent implementation for: Flutter Shopping Cart Widget (Type: ecommerce)

import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// FlutterShoppingCartWidget - Intelligently generated based on requirements analysis.
/// 
/// This class implements functionality for: Flutter Shopping Cart Widget
/// Detected type: ecommerce
/// Generated on: 2025-08-30
/// 
/// Follows Flutter/Dart conventions and best practices.
class FlutterShoppingCartWidget extends StatefulWidget {
  
  // Public configuration
  final Map<String, dynamic> config;
  
  /// Initialize FlutterShoppingCartWidget with flexible configuration.
  /// 
  /// [config] Optional configuration map
  const FlutterShoppingCartWidget({Key? key, this.config = const <String, dynamic>{}}) : super(key: key);
  
  @override
  State<FlutterShoppingCartWidget> createState() => _FlutterShoppingCartWidgetState();
}

class _FlutterShoppingCartWidgetState extends State<FlutterShoppingCartWidget> {
  
  // Cart items
  List<CartItem> _cartItems = [];
  double _totalPrice = 0.0;
  
  @override
  void initState() {
    super.initState();
    developer.log('Initialized FlutterShoppingCartWidget with type: ecommerce');
    _setup();
  }
  
  /// Internal setup method for initialization.
  void _setup() {
    developer.log('Running internal setup...', name: 'FlutterShoppingCartWidget');
    // Initialize with sample data if configured
    if (widget.config.containsKey('sampleData') && widget.config['sampleData'] == true) {
      _addSampleItems();
    }
  }
  
  void _addSampleItems() {
    _cartItems = [
      CartItem(id: '1', name: 'Sample Product 1', price: 19.99, quantity: 1),
      CartItem(id: '2', name: 'Sample Product 2', price: 29.99, quantity: 2),
    ];
    _calculateTotal();
  }
  
  void _calculateTotal() {
    _totalPrice = _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
  
  void _addItem(CartItem item) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
      if (existingIndex >= 0) {
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity + 1
        );
      } else {
        _cartItems.add(item);
      }
      _calculateTotal();
    });
  }
  
  void _removeItem(String itemId) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == itemId);
      _calculateTotal();
    });
  }
  
  void _updateQuantity(String itemId, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _removeItem(itemId);
      } else {
        final index = _cartItems.indexWhere((item) => item.id == itemId);
        if (index >= 0) {
          _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
          _calculateTotal();
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _updateQuantity(item.id, item.quantity - 1),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _updateQuantity(item.id, item.quantity + 1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(item.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cartItems.isEmpty ? null : _checkout,
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleItem,
        tooltip: 'Add Sample Item',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _checkout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Checkout'),
          content: Text('Total: \$${_totalPrice.toStringAsFixed(2)}\nItems: ${_cartItems.length}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order placed successfully!')),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
  
  void _addSampleItem() {
    final newItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'New Product ${_cartItems.length + 1}',
      price: (10 + (_cartItems.length * 5)).toDouble(),
      quantity: 1,
    );
    _addItem(newItem);
  }
  
  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _totalPrice = 0.0;
    });
  }
  
  /// Get instance information.
  /// 
  /// Returns Map containing instance metadata
  Map<String, dynamic> getInfo() {
    return {
      'class': 'FlutterShoppingCartWidget',
      'type': 'ecommerce',
      'itemCount': _cartItems.length,
      'totalPrice': _totalPrice,
      'config': Map<String, dynamic>.from(widget.config),
    };
  }
}

/// CartItem model class
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  
  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
  
  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.quantity == quantity;
  }
  
  @override
  int get hashCode => Object.hash(id, name, price, quantity);
}

// Example usage
void main() {
  runApp(MaterialApp(
    home: const FlutterShoppingCartWidget(config: {'sampleData': true}),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
  ));
}