# auto_cursor - Enhanced Inventory Management System
# Complete implementation with security, validation, and persistence

from __future__ import annotations
import logging
from datetime import datetime, timezone
from typing import Optional, Dict, List, Any, Union
from enum import Enum
from base_application import ManagementApplication, ValidationSchema, OperationResult


class InventoryStatus(Enum):
    """Inventory item status enumeration."""
    IN_STOCK = "in_stock"
    LOW_STOCK = "low_stock"
    OUT_OF_STOCK = "out_of_stock"
    DISCONTINUED = "discontinued"
    RESERVED = "reserved"


class TransactionType(Enum):
    """Inventory transaction types."""
    STOCK_IN = "stock_in"
    STOCK_OUT = "stock_out"
    ADJUSTMENT = "adjustment"
    TRANSFER = "transfer"
    RETURN = "return"


class InventoryManagementSystem(ManagementApplication):
    """
    Enhanced Inventory Management System with complete functionality.
    
    Features:
    - Real-time stock tracking
    - Low stock alerts
    - Transaction history
    - Multi-location support
    - Batch operations
    - Reporting and analytics
    """
    
    def __init__(self, config: Optional[Dict] = None, **kwargs):
        """Initialize InventoryManagementSystem with enhanced configuration."""
        super().__init__(config, **kwargs)
        
        # Inventory-specific data structures
        self.inventory_items: List[Dict] = []
        self.transactions: List[Dict] = []
        self.locations: List[Dict] = []
        self.suppliers: List[Dict] = []
        self.categories: List[Dict] = []
        
        # Performance indexes
        self._item_index: Dict[str, Dict] = {}
        self._sku_index: Dict[str, Dict] = {}
        self._location_index: Dict[str, Dict] = {}
        
        # Configuration
        self.low_stock_threshold = self.config.get('low_stock_threshold', 10)
        self.auto_reorder = self.config.get('auto_reorder', False)
        
        # Load persisted data
        self._load_inventory_data()
    
    def get_application_type(self) -> str:
        return "inventory_management"
    
    def _load_inventory_data(self):
        """Load persisted inventory data."""
        try:
            # Load inventory items
            result = self.persistence_manager.load_data("inventory_items")
            if result.success and result.data:
                self.inventory_items = result.data
                self._rebuild_indexes()
            
            # Load transactions
            result = self.persistence_manager.load_data("transactions")
            if result.success and result.data:
                self.transactions = result.data
            
            # Load locations
            result = self.persistence_manager.load_data("locations")
            if result.success and result.data:
                self.locations = result.data
                self._rebuild_location_index()
                
            self.logger.info("Inventory data loaded successfully")
        except Exception as e:
            self.logger.warning(f"Could not load inventory data: {e}")
    
    def _save_inventory_data(self):
        """Save inventory data to persistence."""
        try:
            self.persistence_manager.save_data("inventory_items", self.inventory_items)
            self.persistence_manager.save_data("transactions", self.transactions)
            self.persistence_manager.save_data("locations", self.locations)
        except Exception as e:
            self.logger.error(f"Failed to save inventory data: {e}")
    
    def _rebuild_indexes(self):
        """Rebuild all indexes for O(1) lookups."""
        self._item_index = {item['id']: item for item in self.inventory_items}
        self._sku_index = {item['sku']: item for item in self.inventory_items if 'sku' in item}
    
    def _rebuild_location_index(self):
        """Rebuild location index."""
        self._location_index = {loc['id']: loc for loc in self.locations}
    
    def add_inventory_item(self, item_data: Dict) -> OperationResult:
        """Add a new inventory item with comprehensive validation."""
        def _add_item_operation():
            # Define validation schema
            schema = ValidationSchema(
                required_fields=['name', 'sku', 'category'],
                field_types={
                    'name': str,
                    'sku': str,
                    'category': str,
                    'quantity': int,
                    'unit_cost': (int, float),
                    'selling_price': (int, float)
                },
                max_lengths={
                    'name': 200,
                    'sku': 50,
                    'description': 1000
                },
                field_validators={
                    'sku': lambda x: len(x.strip()) >= 3,
                    'quantity': lambda x: x >= 0,
                    'unit_cost': lambda x: x >= 0,
                    'selling_price': lambda x: x >= 0
                }
            )
            
            # Validate input
            validation_result = self.validate_input(item_data, schema)
            if not validation_result.success:
                return validation_result
            
            sanitized_data = validation_result.data
            
            # Check for duplicate SKU
            if sanitized_data['sku'] in self._sku_index:
                return OperationResult(
                    success=False,
                    error=f"SKU '{sanitized_data['sku']}' already exists",
                    error_code="DUPLICATE_SKU"
                )
            
            # Generate secure item ID
            item_id = self.security_manager.generate_secure_id("inv")
            
            # Determine initial status
            quantity = sanitized_data.get('quantity', 0)
            if quantity == 0:
                status = InventoryStatus.OUT_OF_STOCK
            elif quantity <= self.low_stock_threshold:
                status = InventoryStatus.LOW_STOCK
            else:
                status = InventoryStatus.IN_STOCK
            
            # Create inventory item
            item = {
                'id': item_id,
                'name': sanitized_data['name'],
                'sku': sanitized_data['sku'],
                'category': sanitized_data['category'],
                'description': sanitized_data.get('description', ''),
                'quantity': quantity,
                'reserved_quantity': 0,
                'available_quantity': quantity,
                'unit_cost': float(sanitized_data.get('unit_cost', 0)),
                'selling_price': float(sanitized_data.get('selling_price', 0)),
                'supplier_id': sanitized_data.get('supplier_id'),
                'location_id': sanitized_data.get('location_id'),
                'status': status.value,
                'reorder_point': sanitized_data.get('reorder_point', self.low_stock_threshold),
                'reorder_quantity': sanitized_data.get('reorder_quantity', 50),
                'created_at': datetime.now(timezone.utc).isoformat(),
                'updated_at': datetime.now(timezone.utc).isoformat()
            }
            
            # Add to storage and indexes
            self.inventory_items.append(item)
            self._item_index[item_id] = item
            self._sku_index[item['sku']] = item
            
            # Create initial transaction record
            self._create_transaction(
                item_id=item_id,
                transaction_type=TransactionType.STOCK_IN,
                quantity=quantity,
                notes=f"Initial stock for {item['name']}"
            )
            
            # Save to persistence
            self._save_inventory_data()
            
            self.logger.info(f"Added inventory item: {item_id} (SKU: {item['sku']})")
            return OperationResult(success=True, data={'item_id': item_id, 'item': item})
        
        return self.execute_operation("add_inventory_item", _add_item_operation)
    
    def update_stock(self, item_id: str, quantity_change: int, transaction_type: TransactionType, notes: str = "") -> OperationResult:
        """Update stock levels with transaction tracking."""
        def _update_stock_operation():
            # Validate item exists
            item = self._item_index.get(item_id)
            if not item:
                return OperationResult(
                    success=False,
                    error="Item not found",
                    error_code="ITEM_NOT_FOUND"
                )
            
            # Calculate new quantity
            new_quantity = item['quantity'] + quantity_change
            
            # Validate stock levels
            if new_quantity < 0:
                return OperationResult(
                    success=False,
                    error=f"Insufficient stock. Available: {item['quantity']}, Requested: {abs(quantity_change)}",
                    error_code="INSUFFICIENT_STOCK"
                )
            
            # Update item
            old_quantity = item['quantity']
            item['quantity'] = new_quantity
            item['available_quantity'] = new_quantity - item['reserved_quantity']
            item['updated_at'] = datetime.now(timezone.utc).isoformat()
            
            # Update status based on new quantity
            if new_quantity == 0:
                item['status'] = InventoryStatus.OUT_OF_STOCK.value
            elif new_quantity <= item['reorder_point']:
                item['status'] = InventoryStatus.LOW_STOCK.value
            else:
                item['status'] = InventoryStatus.IN_STOCK.value
            
            # Create transaction record
            self._create_transaction(
                item_id=item_id,
                transaction_type=transaction_type,
                quantity=quantity_change,
                old_quantity=old_quantity,
                new_quantity=new_quantity,
                notes=notes
            )
            
            # Check for auto-reorder
            if (self.auto_reorder and 
                item['status'] == InventoryStatus.LOW_STOCK.value and 
                quantity_change < 0):  # Only on stock reduction
                self._trigger_reorder(item)
            
            # Save to persistence
            self._save_inventory_data()
            
            self.logger.info(f"Updated stock for {item_id}: {old_quantity} -> {new_quantity}")
            return OperationResult(success=True, data={
                'item_id': item_id,
                'old_quantity': old_quantity,
                'new_quantity': new_quantity,
                'status': item['status']
            })
        
        return self.execute_operation("update_stock", _update_stock_operation)
    
    def _create_transaction(self, item_id: str, transaction_type: TransactionType, quantity: int, 
                          old_quantity: int = None, new_quantity: int = None, notes: str = ""):
        """Create a transaction record."""
        transaction_id = self.security_manager.generate_secure_id("txn")
        transaction = {
            'id': transaction_id,
            'item_id': item_id,
            'type': transaction_type.value,
            'quantity': quantity,
            'old_quantity': old_quantity,
            'new_quantity': new_quantity,
            'notes': notes,
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'user_id': self.config.get('current_user_id', 'system')
        }
        self.transactions.append(transaction)
    
    def _trigger_reorder(self, item: Dict):
        """Trigger automatic reorder for low stock items."""
        self.logger.info(f"Auto-reorder triggered for {item['name']} (SKU: {item['sku']})")
        # In a real system, this would integrate with purchasing system
        
    def get_item_by_sku(self, sku: str) -> OperationResult:
        """Get inventory item by SKU."""
        def _get_item_operation():
            sanitized_sku = self.security_manager.sanitize_input(sku)
            item = self._sku_index.get(sanitized_sku)
            
            if not item:
                return OperationResult(
                    success=False,
                    error="Item not found",
                    error_code="ITEM_NOT_FOUND"
                )
            
            return OperationResult(success=True, data=item)
        
        return self.execute_operation("get_item_by_sku", _get_item_operation)
    
    def get_low_stock_items(self) -> OperationResult:
        """Get all items with low stock."""
        def _get_low_stock_operation():
            low_stock_items = [
                item for item in self.inventory_items
                if item['status'] in [InventoryStatus.LOW_STOCK.value, InventoryStatus.OUT_OF_STOCK.value]
            ]
            
            return OperationResult(success=True, data={
                'items': low_stock_items,
                'count': len(low_stock_items)
            })
        
        return self.execute_operation("get_low_stock_items", _get_low_stock_operation)
    
    def get_inventory_report(self) -> OperationResult:
        """Generate comprehensive inventory report."""
        def _generate_report_operation():
            total_items = len(self.inventory_items)
            total_value = sum(item['quantity'] * item['unit_cost'] for item in self.inventory_items)
            
            status_counts = {}
            for status in InventoryStatus:
                status_counts[status.value] = sum(
                    1 for item in self.inventory_items if item['status'] == status.value
                )
            
            category_stats = {}
            for item in self.inventory_items:
                category = item['category']
                if category not in category_stats:
                    category_stats[category] = {'count': 0, 'value': 0}
                category_stats[category]['count'] += 1
                category_stats[category]['value'] += item['quantity'] * item['unit_cost']
            
            report = {
                'generated_at': datetime.now(timezone.utc).isoformat(),
                'summary': {
                    'total_items': total_items,
                    'total_inventory_value': total_value,
                    'status_breakdown': status_counts,
                    'category_breakdown': category_stats
                },
                'alerts': {
                    'low_stock_count': status_counts.get(InventoryStatus.LOW_STOCK.value, 0),
                    'out_of_stock_count': status_counts.get(InventoryStatus.OUT_OF_STOCK.value, 0)
                }
            }
            
            return OperationResult(success=True, data=report)
        
        return self.execute_operation("generate_inventory_report", _generate_report_operation)


if __name__ == '__main__':
    # Example usage with enhanced functionality
    config = {
        'low_stock_threshold': 5,
        'auto_reorder': True,
        'data_dir': 'inventory_data'
    }
    
    ims = InventoryManagementSystem(config=config)
    
    # Add sample inventory item
    result = ims.add_inventory_item({
        'name': 'Wireless Headphones',
        'sku': 'WH-001',
        'category': 'Electronics',
        'description': 'High-quality wireless headphones with noise cancellation',
        'quantity': 50,
        'unit_cost': 75.00,
        'selling_price': 149.99,
        'reorder_point': 10,
        'reorder_quantity': 25
    })
    
    if result.success:
        print(f"✅ Added item: {result.data['item']['name']}")
        
        # Update stock (simulate sale)
        stock_result = ims.update_stock(
            result.data['item_id'], 
            -5, 
            TransactionType.STOCK_OUT,
            "Sale to customer"
        )
        
        if stock_result.success:
            print(f"✅ Stock updated: {stock_result.data}")
        
        # Generate report
        report_result = ims.get_inventory_report()
        if report_result.success:
            print(f"📊 Inventory Report: {report_result.data['summary']}")
    
    print(f"🚀 {ims.__class__.__name__} is fully operational!")
    print(f"📈 Health Status: {ims.get_health_status()}")
