#!/usr/bin/env python3
# Comprehensive tests for the enhanced DNS system

import unittest
import tempfile
import shutil
import json
import os
import sys
from datetime import datetime, timezone
from unittest.mock import patch, MagicMock
from pathlib import Path

# Add the applications directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'applications'))

# Import our enhanced modules
from base_application import (
    BaseApplication, ECommerceApplication, ManagementApplication,
    ValidationSchema, OperationResult, SecurityManager, DataValidator,
    PersistenceManager, ApplicationStatus
)
from enhanced_inventory_management_system import (
    InventoryManagementSystem, InventoryStatus, TransactionType
)
from config_manager import ConfigManager, Environment


class TestSecurityManager(unittest.TestCase):
    """Test cases for SecurityManager."""
    
    def test_sanitize_input_string(self):
        """Test string sanitization."""
        # Test basic sanitization
        result = SecurityManager.sanitize_input("<script>alert('xss')</script>Hello")
        self.assertEqual(result, "Hello")
        
        # Test with whitespace
        result = SecurityManager.sanitize_input("  Hello World  ")
        self.assertEqual(result, "Hello World")
        
        # Test empty string
        result = SecurityManager.sanitize_input("")
        self.assertEqual(result, "")
    
    def test_sanitize_input_dict(self):
        """Test dictionary sanitization."""
        input_data = {
            'name': '<script>alert("xss")</script>John',
            'email': 'john@example.com',
            'nested': {
                'value': '<b>Bold</b> text'
            }
        }
        
        result = SecurityManager.sanitize_input(input_data)
        
        self.assertEqual(result['name'], 'John')
        self.assertEqual(result['email'], 'john@example.com')
        self.assertEqual(result['nested']['value'], 'Bold text')
    
    def test_sanitize_input_list(self):
        """Test list sanitization."""
        input_data = ['<script>test</script>', 'normal text', '<b>bold</b>']
        result = SecurityManager.sanitize_input(input_data)
        
        self.assertEqual(result, ['', 'normal text', 'bold'])
    
    def test_generate_secure_id(self):
        """Test secure ID generation."""
        # Test without prefix
        id1 = SecurityManager.generate_secure_id()
        id2 = SecurityManager.generate_secure_id()
        
        self.assertIsInstance(id1, str)
        self.assertIsInstance(id2, str)
        self.assertNotEqual(id1, id2)
        self.assertEqual(len(id1), 8)  # default length
        
        # Test with prefix
        id_with_prefix = SecurityManager.generate_secure_id("test", 10)
        self.assertTrue(id_with_prefix.startswith("test_"))
        self.assertEqual(len(id_with_prefix), 15)  # "test_" + 10 chars
    
    def test_validate_id_format(self):
        """Test ID format validation."""
        # Valid IDs
        self.assertTrue(SecurityManager.validate_id_format("test_12345678"))
        self.assertTrue(SecurityManager.validate_id_format("test_12345678", "test"))
        self.assertTrue(SecurityManager.validate_id_format("simple_id"))
        
        # Invalid IDs
        self.assertFalse(SecurityManager.validate_id_format(""))
        self.assertFalse(SecurityManager.validate_id_format(None))
        self.assertFalse(SecurityManager.validate_id_format("test_12345678", "wrong"))


class TestDataValidator(unittest.TestCase):
    """Test cases for DataValidator."""
    
    def test_validate_required_fields(self):
        """Test required field validation."""
        schema = ValidationSchema(required_fields=['name', 'email'])
        
        # Valid data
        valid_data = {'name': 'John', 'email': 'john@example.com', 'age': 30}
        result = DataValidator.validate_data(valid_data, schema)
        self.assertTrue(result.success)
        self.assertEqual(result.data, valid_data)
        
        # Missing required field
        invalid_data = {'name': 'John'}
        result = DataValidator.validate_data(invalid_data, schema)
        self.assertFalse(result.success)
        self.assertEqual(result.error_code, "MISSING_REQUIRED_FIELD")
        self.assertIn("email", result.error)
    
    def test_validate_field_types(self):
        """Test field type validation."""
        schema = ValidationSchema(
            required_fields=['name'],
            field_types={'name': str, 'age': int, 'price': float}
        )
        
        # Valid types
        valid_data = {'name': 'John', 'age': 30, 'price': 19.99}
        result = DataValidator.validate_data(valid_data, schema)
        self.assertTrue(result.success)
        
        # Invalid type
        invalid_data = {'name': 'John', 'age': 'thirty'}
        result = DataValidator.validate_data(invalid_data, schema)
        self.assertFalse(result.success)
        self.assertEqual(result.error_code, "INVALID_FIELD_TYPE")
    
    def test_validate_max_lengths(self):
        """Test maximum length validation."""
        schema = ValidationSchema(
            required_fields=['name'],
            max_lengths={'name': 10, 'description': 50}
        )
        
        # Valid lengths
        valid_data = {'name': 'John', 'description': 'Short desc'}
        result = DataValidator.validate_data(valid_data, schema)
        self.assertTrue(result.success)
        
        # Exceeds max length
        invalid_data = {'name': 'This name is way too long'}
        result = DataValidator.validate_data(invalid_data, schema)
        self.assertFalse(result.success)
        self.assertEqual(result.error_code, "FIELD_TOO_LONG")
    
    def test_validate_custom_validators(self):
        """Test custom field validators."""
        schema = ValidationSchema(
            required_fields=['email'],
            field_validators={
                'email': lambda x: '@' in x,
                'age': lambda x: x >= 18
            }
        )
        
        # Valid data
        valid_data = {'email': 'john@example.com', 'age': 25}
        result = DataValidator.validate_data(valid_data, schema)
        self.assertTrue(result.success)
        
        # Invalid email
        invalid_data = {'email': 'invalid-email', 'age': 25}
        result = DataValidator.validate_data(invalid_data, schema)
        self.assertFalse(result.success)
        self.assertEqual(result.error_code, "CUSTOM_VALIDATION_FAILED")


class TestPersistenceManager(unittest.TestCase):
    """Test cases for PersistenceManager."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        self.persistence_manager = PersistenceManager(self.temp_dir)
    
    def tearDown(self):
        """Clean up test fixtures."""
        shutil.rmtree(self.temp_dir)
    
    def test_save_and_load_data(self):
        """Test saving and loading data."""
        test_data = {
            'items': [
                {'id': '1', 'name': 'Item 1'},
                {'id': '2', 'name': 'Item 2'}
            ],
            'metadata': {'version': '1.0', 'created_at': '2023-01-01'}
        }
        
        # Save data
        save_result = self.persistence_manager.save_data('test_data', test_data)
        self.assertTrue(save_result.success)
        
        # Load data
        load_result = self.persistence_manager.load_data('test_data')
        self.assertTrue(load_result.success)
        self.assertEqual(load_result.data, test_data)
    
    def test_load_nonexistent_data(self):
        """Test loading non-existent data."""
        result = self.persistence_manager.load_data('nonexistent')
        self.assertTrue(result.success)
        self.assertEqual(result.data, [])
    
    def test_save_invalid_data(self):
        """Test saving invalid data."""
        # Try to save data that can't be JSON serialized
        invalid_data = {'function': lambda x: x}
        result = self.persistence_manager.save_data('invalid', invalid_data)
        self.assertFalse(result.success)
        self.assertEqual(result.error_code, "SAVE_ERROR")


class TestEnhancedBaseApplication(unittest.TestCase):
    """Test cases for enhanced BaseApplication."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        
        # Create a concrete implementation for testing
        class TestApplication(BaseApplication):
            def get_application_type(self) -> str:
                return "test"
        
        self.app = TestApplication(config={'data_dir': self.temp_dir})
    
    def tearDown(self):
        """Clean up test fixtures."""
        shutil.rmtree(self.temp_dir)
    
    def test_initialization(self):
        """Test application initialization."""
        self.assertEqual(self.app.status, ApplicationStatus.ACTIVE)
        self.assertEqual(self.app.operation_count, 0)
        self.assertIsNone(self.app.last_operation_time)
        self.assertIsInstance(self.app.security_manager, SecurityManager)
        self.assertIsInstance(self.app.data_validator, DataValidator)
        self.assertIsInstance(self.app.persistence_manager, PersistenceManager)
    
    def test_validate_input(self):
        """Test input validation."""
        # Valid input
        valid_data = {'name': 'Test', 'value': 123}
        result = self.app.validate_input(valid_data)
        self.assertTrue(result.success)
        
        # Invalid input (None)
        result = self.app.validate_input(None)
        self.assertFalse(result.success)
        self.assertEqual(result.error_code, "NULL_INPUT")
    
    def test_execute_operation(self):
        """Test operation execution."""
        def test_operation(x, y):
            return x + y
        
        result = self.app.execute_operation("test_add", test_operation, 5, 3)
        self.assertTrue(result.success)
        self.assertEqual(result.data, 8)
        self.assertEqual(self.app.operation_count, 1)
        self.assertIsNotNone(self.app.last_operation_time)
    
    def test_execute_operation_with_exception(self):
        """Test operation execution with exception."""
        def failing_operation():
            raise ValueError("Test error")
        
        result = self.app.execute_operation("failing_op", failing_operation)
        self.assertFalse(result.success)
        self.assertEqual(result.error_code, "OPERATION_ERROR")
        self.assertIn("Test error", result.error)
    
    def test_get_info(self):
        """Test getting application info."""
        info = self.app.get_info()
        
        self.assertIn('class', info)
        self.assertIn('type', info)
        self.assertIn('created_at', info)
        self.assertIn('status', info)
        self.assertIn('operation_count', info)
        self.assertEqual(info['type'], 'test')
        self.assertEqual(info['status'], ApplicationStatus.ACTIVE.value)
    
    def test_get_health_status(self):
        """Test getting health status."""
        health = self.app.get_health_status()
        
        self.assertIn('status', health)
        self.assertIn('uptime_seconds', health)
        self.assertIn('operation_count', health)
        self.assertIn('healthy', health)
        self.assertTrue(health['healthy'])
    
    def test_shutdown(self):
        """Test application shutdown."""
        self.app.shutdown()
        self.assertEqual(self.app.status, ApplicationStatus.INACTIVE)


class TestEnhancedInventoryManagementSystem(unittest.TestCase):
    """Test cases for enhanced InventoryManagementSystem."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        config = {
            'data_dir': self.temp_dir,
            'low_stock_threshold': 5,
            'auto_reorder': False
        }
        self.ims = InventoryManagementSystem(config=config)
    
    def tearDown(self):
        """Clean up test fixtures."""
        shutil.rmtree(self.temp_dir)
    
    def test_add_inventory_item_valid(self):
        """Test adding valid inventory item."""
        item_data = {
            'name': 'Test Product',
            'sku': 'TEST-001',
            'category': 'Electronics',
            'description': 'A test product',
            'quantity': 100,
            'unit_cost': 50.0,
            'selling_price': 99.99
        }
        
        result = self.ims.add_inventory_item(item_data)
        
        self.assertTrue(result.success)
        self.assertIn('item_id', result.data)
        self.assertIn('item', result.data)
        
        item = result.data['item']
        self.assertEqual(item['name'], 'Test Product')
        self.assertEqual(item['sku'], 'TEST-001')
        self.assertEqual(item['status'], InventoryStatus.IN_STOCK.value)
        
        # Check that item is in indexes
        item_id = result.data['item_id']
        self.assertIn(item_id, self.ims._item_index)
        self.assertIn('TEST-001', self.ims._sku_index)
    
    def test_add_inventory_item_invalid(self):
        """Test adding invalid inventory item."""
        # Missing required fields
        invalid_data = {
            'name': 'Test Product'
            # Missing 'sku' and 'category'
        }
        
        result = self.ims.add_inventory_item(invalid_data)
        self.assertFalse(result.success)
        self.assertEqual(result.error_code, "MISSING_REQUIRED_FIELD")
    
    def test_add_inventory_item_duplicate_sku(self):
        """Test adding item with duplicate SKU."""
        item_data = {
            'name': 'Test Product 1',
            'sku': 'DUPLICATE-SKU',
            'category': 'Electronics',
            'quantity': 10
        }
        
        # Add first item
        result1 = self.ims.add_inventory_item(item_data)
        self.assertTrue(result1.success)
        
        # Try to add second item with same SKU
        item_data['name'] = 'Test Product 2'
        result2 = self.ims.add_inventory_item(item_data)
        self.assertFalse(result2.success)
        self.assertEqual(result2.error_code, "DUPLICATE_SKU")
    
    def test_update_stock_valid(self):
        """Test valid stock update."""
        # Add an item first
        item_data = {
            'name': 'Test Product',
            'sku': 'STOCK-TEST',
            'category': 'Electronics',
            'quantity': 50
        }
        
        add_result = self.ims.add_inventory_item(item_data)
        self.assertTrue(add_result.success)
        item_id = add_result.data['item_id']
        
        # Update stock (reduce by 10)
        update_result = self.ims.update_stock(
            item_id, -10, TransactionType.STOCK_OUT, "Sale"
        )
        
        self.assertTrue(update_result.success)
        self.assertEqual(update_result.data['old_quantity'], 50)
        self.assertEqual(update_result.data['new_quantity'], 40)
        
        # Check that item was updated
        item = self.ims._item_index[item_id]
        self.assertEqual(item['quantity'], 40)
        
        # Check transaction was created
        self.assertEqual(len(self.ims.transactions), 2)  # Initial + update
    
    def test_update_stock_insufficient(self):
        """Test stock update with insufficient quantity."""
        # Add an item with low stock
        item_data = {
            'name': 'Low Stock Product',
            'sku': 'LOW-STOCK',
            'category': 'Electronics',
            'quantity': 5
        }
        
        add_result = self.ims.add_inventory_item(item_data)
        self.assertTrue(add_result.success)
        item_id = add_result.data['item_id']
        
        # Try to reduce stock by more than available
        update_result = self.ims.update_stock(
            item_id, -10, TransactionType.STOCK_OUT, "Oversale attempt"
        )
        
        self.assertFalse(update_result.success)
        self.assertEqual(update_result.error_code, "INSUFFICIENT_STOCK")
    
    def test_get_item_by_sku(self):
        """Test getting item by SKU."""
        # Add an item
        item_data = {
            'name': 'SKU Test Product',
            'sku': 'SKU-SEARCH',
            'category': 'Electronics',
            'quantity': 25
        }
        
        add_result = self.ims.add_inventory_item(item_data)
        self.assertTrue(add_result.success)
        
        # Get item by SKU
        get_result = self.ims.get_item_by_sku('SKU-SEARCH')
        self.assertTrue(get_result.success)
        self.assertEqual(get_result.data['name'], 'SKU Test Product')
        
        # Try non-existent SKU
        not_found_result = self.ims.get_item_by_sku('NON-EXISTENT')
        self.assertFalse(not_found_result.success)
        self.assertEqual(not_found_result.error_code, "ITEM_NOT_FOUND")
    
    def test_get_low_stock_items(self):
        """Test getting low stock items."""
        # Add items with different stock levels
        items_data = [
            {'name': 'High Stock', 'sku': 'HIGH-001', 'category': 'A', 'quantity': 100},
            {'name': 'Low Stock', 'sku': 'LOW-001', 'category': 'A', 'quantity': 3},
            {'name': 'Out of Stock', 'sku': 'OUT-001', 'category': 'A', 'quantity': 0},
            {'name': 'Normal Stock', 'sku': 'NORM-001', 'category': 'A', 'quantity': 20}
        ]
        
        for item_data in items_data:
            result = self.ims.add_inventory_item(item_data)
            self.assertTrue(result.success)
        
        # Get low stock items
        low_stock_result = self.ims.get_low_stock_items()
        self.assertTrue(low_stock_result.success)
        
        low_stock_items = low_stock_result.data['items']
        self.assertEqual(len(low_stock_items), 2)  # LOW-001 and OUT-001
        
        skus = [item['sku'] for item in low_stock_items]
        self.assertIn('LOW-001', skus)
        self.assertIn('OUT-001', skus)
    
    def test_get_inventory_report(self):
        """Test inventory report generation."""
        # Add some test items
        items_data = [
            {'name': 'Item 1', 'sku': 'RPT-001', 'category': 'Electronics', 'quantity': 50, 'unit_cost': 10.0},
            {'name': 'Item 2', 'sku': 'RPT-002', 'category': 'Electronics', 'quantity': 0, 'unit_cost': 20.0},
            {'name': 'Item 3', 'sku': 'RPT-003', 'category': 'Books', 'quantity': 100, 'unit_cost': 5.0}
        ]
        
        for item_data in items_data:
            result = self.ims.add_inventory_item(item_data)
            self.assertTrue(result.success)
        
        # Generate report
        report_result = self.ims.get_inventory_report()
        self.assertTrue(report_result.success)
        
        report = report_result.data
        self.assertIn('summary', report)
        self.assertIn('alerts', report)
        
        summary = report['summary']
        self.assertEqual(summary['total_items'], 3)
        self.assertEqual(summary['total_inventory_value'], 1000.0)  # 50*10 + 0*20 + 100*5
        
        # Check category breakdown
        self.assertIn('Electronics', summary['category_breakdown'])
        self.assertIn('Books', summary['category_breakdown'])
        self.assertEqual(summary['category_breakdown']['Electronics']['count'], 2)
        self.assertEqual(summary['category_breakdown']['Books']['count'], 1)


class TestConfigManager(unittest.TestCase):
    """Test cases for ConfigManager."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        self.config_file = os.path.join(self.temp_dir, 'test_config.yaml')
    
    def tearDown(self):
        """Clean up test fixtures."""
        shutil.rmtree(self.temp_dir)
    
    def test_config_manager_initialization(self):
        """Test ConfigManager initialization."""
        config_manager = ConfigManager(
            config_file=self.config_file,
            environment="development"
        )
        
        self.assertEqual(config_manager.environment, Environment.DEVELOPMENT)
        self.assertEqual(config_manager.config_file, self.config_file)
        self.assertIsInstance(config_manager.database.url, str)
        self.assertIsInstance(config_manager.api.port, int)
    
    def test_get_configuration_value(self):
        """Test getting configuration values."""
        # Create a test config file
        test_config = {
            'database': {
                'url': 'postgresql://test:test@localhost/testdb',
                'pool_size': 15
            },
            'api': {
                'port': 9000
            }
        }
        
        with open(self.config_file, 'w') as f:
            import yaml
            yaml.dump(test_config, f)
        
        config_manager = ConfigManager(config_file=self.config_file)
        
        # Test dot notation
        self.assertEqual(config_manager.get('database.url'), 'postgresql://test:test@localhost/testdb')
        self.assertEqual(config_manager.get('database.pool_size'), 15)
        self.assertEqual(config_manager.get('api.port'), 9000)
        
        # Test default values
        self.assertEqual(config_manager.get('nonexistent.key', 'default'), 'default')
    
    @patch.dict(os.environ, {'DATABASE_URL': 'env://test'})
    def test_environment_variable_override(self):
        """Test environment variable override."""
        config_manager = ConfigManager(config_file=self.config_file)
        
        # Environment variable should override config file
        self.assertEqual(config_manager.get('database.url'), 'env://test')
    
    def test_validate_configuration(self):
        """Test configuration validation."""
        config_manager = ConfigManager(config_file=self.config_file)
        
        issues = config_manager.validate_configuration()
        
        # Should have at least one issue (default secret key in development)
        self.assertIsInstance(issues, list)
        
        # Check for specific validation issues
        issue_texts = ' '.join(issues)
        if config_manager.environment == Environment.PRODUCTION:
            self.assertIn('secret key', issue_texts.lower())


class TestIntegration(unittest.TestCase):
    """Integration tests for the enhanced system."""
    
    def setUp(self):
        """Set up integration test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        
        # Create config manager
        self.config_manager = ConfigManager(environment="testing")
        
        # Create systems with shared configuration
        config = {
            'data_dir': self.temp_dir,
            'low_stock_threshold': 5,
            'auto_reorder': False
        }
        
        self.inventory_system = InventoryManagementSystem(config=config)
    
    def tearDown(self):
        """Clean up integration test fixtures."""
        shutil.rmtree(self.temp_dir)
    
    def test_complete_inventory_workflow(self):
        """Test complete inventory management workflow."""
        # 1. Add multiple inventory items
        items_data = [
            {
                'name': 'Laptop Computer',
                'sku': 'LAPTOP-001',
                'category': 'Electronics',
                'description': 'High-performance laptop',
                'quantity': 25,
                'unit_cost': 800.0,
                'selling_price': 1299.99,
                'reorder_point': 5,
                'reorder_quantity': 10
            },
            {
                'name': 'Wireless Mouse',
                'sku': 'MOUSE-001',
                'category': 'Electronics',
                'description': 'Ergonomic wireless mouse',
                'quantity': 100,
                'unit_cost': 15.0,
                'selling_price': 29.99,
                'reorder_point': 20,
                'reorder_quantity': 50
            },
            {
                'name': 'Office Chair',
                'sku': 'CHAIR-001',
                'category': 'Furniture',
                'description': 'Comfortable office chair',
                'quantity': 3,  # Low stock
                'unit_cost': 150.0,
                'selling_price': 299.99,
                'reorder_point': 5,
                'reorder_quantity': 10
            }
        ]
        
        item_ids = []
        for item_data in items_data:
            result = self.inventory_system.add_inventory_item(item_data)
            self.assertTrue(result.success, f"Failed to add item: {result.error}")
            item_ids.append(result.data['item_id'])
        
        # 2. Perform stock operations
        # Sell some laptops
        laptop_sale = self.inventory_system.update_stock(
            item_ids[0], -5, TransactionType.STOCK_OUT, "Customer order #1001"
        )
        self.assertTrue(laptop_sale.success)
        
        # Receive more mice
        mouse_restock = self.inventory_system.update_stock(
            item_ids[1], 50, TransactionType.STOCK_IN, "Supplier delivery"
        )
        self.assertTrue(mouse_restock.success)
        
        # Sell chairs (should trigger low stock)
        chair_sale = self.inventory_system.update_stock(
            item_ids[2], -2, TransactionType.STOCK_OUT, "Office setup order"
        )
        self.assertTrue(chair_sale.success)
        
        # 3. Check low stock items
        low_stock_result = self.inventory_system.get_low_stock_items()
        self.assertTrue(low_stock_result.success)
        
        low_stock_items = low_stock_result.data['items']
        self.assertEqual(len(low_stock_items), 1)  # Only chairs should be low stock
        self.assertEqual(low_stock_items[0]['sku'], 'CHAIR-001')
        
        # 4. Generate comprehensive report
        report_result = self.inventory_system.get_inventory_report()
        self.assertTrue(report_result.success)
        
        report = report_result.data
        summary = report['summary']
        
        # Verify report data
        self.assertEqual(summary['total_items'], 3)
        self.assertGreater(summary['total_inventory_value'], 0)
        self.assertEqual(summary['category_breakdown']['Electronics']['count'], 2)
        self.assertEqual(summary['category_breakdown']['Furniture']['count'], 1)
        
        # Check alerts
        alerts = report['alerts']
        self.assertEqual(alerts['low_stock_count'], 1)
        self.assertEqual(alerts['out_of_stock_count'], 0)
        
        # 5. Search functionality
        search_result = self.inventory_system.search_inventory("laptop")
        self.assertTrue(search_result.success)
        self.assertEqual(len(search_result.data['results']), 1)
        self.assertEqual(search_result.data['results'][0]['sku'], 'LAPTOP-001')
        
        # Search with filters
        electronics_search = self.inventory_system.search_inventory(
            "mouse", {'category': 'Electronics'}
        )
        self.assertTrue(electronics_search.success)
        self.assertEqual(len(electronics_search.data['results']), 1)
        
        # 6. Verify transaction history
        self.assertGreater(len(self.inventory_system.transactions), 0)
        
        # Check that all operations were logged
        transaction_types = [txn['type'] for txn in self.inventory_system.transactions]
        self.assertIn(TransactionType.STOCK_IN.value, transaction_types)
        self.assertIn(TransactionType.STOCK_OUT.value, transaction_types)
        
        # 7. Test system health
        health_status = self.inventory_system.get_health_status()
        self.assertTrue(health_status['healthy'])
        self.assertGreater(health_status['operation_count'], 0)
        
        print("✅ Complete inventory workflow test passed!")
        print(f"📊 Final Report Summary: {summary}")
        print(f"🚨 Low Stock Alerts: {alerts}")


if __name__ == '__main__':
    # Configure logging for tests
    logging.basicConfig(
        level=logging.WARNING,  # Reduce noise during tests
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    
    # Create test suite
    test_suite = unittest.TestSuite()
    
    # Add test classes
    test_classes = [
        TestSecurityManager,
        TestDataValidator,
        TestPersistenceManager,
        TestEnhancedBaseApplication,
        TestEnhancedInventoryManagementSystem,
        TestConfigManager,
        TestIntegration
    ]
    
    for test_class in test_classes:
        tests = unittest.TestLoader().loadTestsFromTestCase(test_class)
        test_suite.addTests(tests)
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(test_suite)
    
    # Print summary
    print(f"\n{'='*60}")
    print(f"🧪 TEST SUMMARY")
    print(f"{'='*60}")
    print(f"Tests run: {result.testsRun}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    print(f"Success rate: {((result.testsRun - len(result.failures) - len(result.errors)) / result.testsRun * 100):.1f}%")
    
    if result.failures:
        print(f"\n❌ FAILURES:")
        for test, traceback in result.failures:
            print(f"  - {test}: {traceback.split('AssertionError: ')[-1].split('\\n')[0]}")
    
    if result.errors:
        print(f"\n💥 ERRORS:")
        for test, traceback in result.errors:
            print(f"  - {test}: {traceback.split('\\n')[-2]}")
    
    if not result.failures and not result.errors:
        print(f"\n🎉 ALL TESTS PASSED! The enhanced DNS system is working perfectly!")
    
    # Exit with appropriate code
    sys.exit(0 if result.wasSuccessful() else 1)
