#!/usr/bin/env python3
# Unit tests for DataProcessor (sample_code.py)

import unittest
import tempfile
import os
import sys
from unittest.mock import patch, mock_open
from io import StringIO

# Add the applications directory to the path so we can import our modules
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'applications'))

from sample_code import DataProcessor


class TestDataProcessor(unittest.TestCase):
    """Test cases for DataProcessor class."""
    
    def setUp(self):
        """Set up test fixtures before each test method."""
        self.processor = DataProcessor()
    
    def tearDown(self):
        """Clean up after each test method."""
        self.processor = None
    
    def test_initialization(self):
        """Test DataProcessor initialization."""
        self.assertIsInstance(self.processor, DataProcessor)
        self.assertIsInstance(self.processor.data, list)
        self.assertIsInstance(self.processor.processed_data, list)
        self.assertEqual(len(self.processor.data), 0)
        self.assertEqual(len(self.processor.processed_data), 0)
    
    def test_normalize_name(self):
        """Test name normalization."""
        # Test basic normalization
        self.assertEqual(self.processor._normalize_name("Test Name"), "test_name")
        self.assertEqual(self.processor._normalize_name("UPPERCASE"), "uppercase")
        self.assertEqual(self.processor._normalize_name("Multiple   Spaces"), "multiple___spaces")
        self.assertEqual(self.processor._normalize_name(""), "")
    
    def test_transform_item(self):
        """Test single item transformation."""
        item = {'name': 'Test Item', 'value': 5.0}
        transformed = self.processor._transform_item(item)
        
        expected = {
            'original_name': 'Test Item',
            'normalized_name': 'test_item',
            'original_value': 5.0,
            'squared_value': 25.0,
            'is_positive': True
        }
        
        self.assertEqual(transformed, expected)
    
    def test_transform_item_negative_value(self):
        """Test transformation with negative value."""
        item = {'name': 'Negative Item', 'value': -3.0}
        transformed = self.processor._transform_item(item)
        
        self.assertEqual(transformed['squared_value'], 9.0)
        self.assertEqual(transformed['is_positive'], False)
    
    def test_transform_item_zero_value(self):
        """Test transformation with zero value."""
        item = {'name': 'Zero Item', 'value': 0.0}
        transformed = self.processor._transform_item(item)
        
        self.assertEqual(transformed['squared_value'], 0.0)
        self.assertEqual(transformed['is_positive'], False)
    
    def test_process_single_line_valid(self):
        """Test processing a single valid line."""
        line = "Product A, 10.5"
        self.processor._process_single_line(line, 1)
        
        self.assertEqual(len(self.processor.data), 1)
        self.assertEqual(self.processor.data[0]['name'], 'Product A')
        self.assertEqual(self.processor.data[0]['value'], 10.5)
    
    def test_process_single_line_with_extra_spaces(self):
        """Test processing a line with extra spaces."""
        line = "  Product B  ,  20.5  "
        self.processor._process_single_line(line, 1)
        
        self.assertEqual(len(self.processor.data), 1)
        self.assertEqual(self.processor.data[0]['name'], 'Product B')
        self.assertEqual(self.processor.data[0]['value'], 20.5)
    
    def test_process_single_line_empty(self):
        """Test processing an empty line."""
        line = ""
        self.processor._process_single_line(line, 1)
        
        self.assertEqual(len(self.processor.data), 0)
    
    def test_process_single_line_comment(self):
        """Test processing a comment line."""
        line = "# This is a comment"
        self.processor._process_single_line(line, 1)
        
        self.assertEqual(len(self.processor.data), 0)
    
    def test_process_single_line_insufficient_parts(self):
        """Test processing a line with insufficient data parts."""
        line = "Product C"  # Missing value
        
        with self.assertRaises(ValueError) as context:
            self.processor._process_single_line(line, 1)
        
        self.assertIn("Insufficient data parts", str(context.exception))
        self.assertEqual(len(self.processor.data), 0)
    
    def test_process_single_line_invalid_value(self):
        """Test processing a line with invalid numeric value."""
        line = "Product D, invalid_number"
        
        with self.assertRaises(ValueError) as context:
            self.processor._process_single_line(line, 1)
        
        self.assertIn("Invalid data format", str(context.exception))
        self.assertEqual(len(self.processor.data), 0)
    
    def test_process_lines_mixed_content(self):
        """Test processing multiple lines with mixed content."""
        lines = [
            "Product A, 10.5\n",
            "# This is a comment\n",
            "Product B, 20.0\n",
            "\n",  # Empty line
            "Product C, -5.5\n"
        ]
        
        self.processor._process_lines(lines)
        
        self.assertEqual(len(self.processor.data), 3)
        self.assertEqual(self.processor.data[0]['name'], 'Product A')
        self.assertEqual(self.processor.data[1]['name'], 'Product B')
        self.assertEqual(self.processor.data[2]['name'], 'Product C')
        self.assertEqual(self.processor.data[2]['value'], -5.5)
    
    def test_process_lines_with_invalid_line(self):
        """Test processing lines with one invalid line (should skip and continue)."""
        lines = [
            "Product A, 10.5\n",
            "Invalid line\n",  # This should be skipped
            "Product B, 20.0\n"
        ]
        
        # Should not raise exception, but should log warning
        self.processor._process_lines(lines)
        
        # Should have processed the valid lines
        self.assertEqual(len(self.processor.data), 2)
        self.assertEqual(self.processor.data[0]['name'], 'Product A')
        self.assertEqual(self.processor.data[1]['name'], 'Product B')
    
    def test_load_data_file_not_found(self):
        """Test loading data from non-existent file."""
        with self.assertRaises(FileNotFoundError):
            self.processor.load_data("nonexistent_file.csv")
    
    def test_load_data_valid_file(self):
        """Test loading data from a valid file."""
        # Create a temporary file with test data
        test_data = """Product A, 10.5
# This is a comment
Product B, 20.0
Product C, -5.5"""
        
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.csv') as f:
            f.write(test_data)
            temp_filename = f.name
        
        try:
            self.processor.load_data(temp_filename)
            
            self.assertEqual(len(self.processor.data), 3)
            self.assertEqual(self.processor.data[0]['name'], 'Product A')
            self.assertEqual(self.processor.data[0]['value'], 10.5)
            self.assertEqual(self.processor.data[1]['name'], 'Product B')
            self.assertEqual(self.processor.data[1]['value'], 20.0)
            self.assertEqual(self.processor.data[2]['name'], 'Product C')
            self.assertEqual(self.processor.data[2]['value'], -5.5)
        finally:
            os.unlink(temp_filename)
    
    def test_process_data(self):
        """Test processing loaded data."""
        # Manually add some test data
        self.processor.data = [
            {'name': 'Product A', 'value': 10.0},
            {'name': 'Product B', 'value': -5.0},
            {'name': 'Product C', 'value': 0.0}
        ]
        
        self.processor.process_data()
        
        self.assertEqual(len(self.processor.processed_data), 3)
        
        # Check first item
        item1 = self.processor.processed_data[0]
        self.assertEqual(item1['original_name'], 'Product A')
        self.assertEqual(item1['normalized_name'], 'product_a')
        self.assertEqual(item1['original_value'], 10.0)
        self.assertEqual(item1['squared_value'], 100.0)
        self.assertTrue(item1['is_positive'])
        
        # Check second item (negative)
        item2 = self.processor.processed_data[1]
        self.assertEqual(item2['original_name'], 'Product B')
        self.assertEqual(item2['squared_value'], 25.0)
        self.assertFalse(item2['is_positive'])
        
        # Check third item (zero)
        item3 = self.processor.processed_data[2]
        self.assertEqual(item3['squared_value'], 0.0)
        self.assertFalse(item3['is_positive'])
    
    def test_save_results(self):
        """Test saving results to file."""
        # Set up processed data
        self.processor.processed_data = [
            {
                'normalized_name': 'product_a',
                'squared_value': 100.0
            },
            {
                'normalized_name': 'product_b',
                'squared_value': 25.0
            }
        ]
        
        # Create a temporary file for output
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.csv') as f:
            temp_filename = f.name
        
        try:
            self.processor.save_results(temp_filename)
            
            # Read back the file and verify contents
            with open(temp_filename, 'r') as f:
                content = f.read()
            
            expected_content = "product_a,100.0\nproduct_b,25.0\n"
            self.assertEqual(content, expected_content)
        finally:
            os.unlink(temp_filename)
    
    def test_get_stats_empty_data(self):
        """Test getting statistics with no processed data."""
        stats = self.processor.get_stats()
        
        expected = {'total_items': 0}
        self.assertEqual(stats, expected)
    
    def test_get_stats_with_data(self):
        """Test getting statistics with processed data."""
        # Set up processed data
        self.processor.processed_data = [
            {'original_value': 10.0, 'is_positive': True},
            {'original_value': -5.0, 'is_positive': False},
            {'original_value': 15.0, 'is_positive': True},
            {'original_value': 0.0, 'is_positive': False}
        ]
        
        stats = self.processor.get_stats()
        
        self.assertEqual(stats['total_items'], 4)
        self.assertEqual(stats['positive_items'], 2)
        self.assertEqual(stats['average_value'], 5.0)  # (10 + (-5) + 15 + 0) / 4
        self.assertEqual(stats['max_value'], 15.0)
        self.assertEqual(stats['min_value'], -5.0)


class TestDataProcessorIntegration(unittest.TestCase):
    """Integration tests for DataProcessor."""
    
    def test_complete_workflow(self):
        """Test a complete data processing workflow."""
        processor = DataProcessor()
        
        # Create test data file
        test_data = """Product Alpha, 25.5
Product Beta, 10.0
# Comment line should be ignored
Product Gamma, -5.0
Product Delta, 0.0
Product Epsilon, 100.0"""
        
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.csv') as input_file:
            input_file.write(test_data)
            input_filename = input_file.name
        
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.csv') as output_file:
            output_filename = output_file.name
        
        try:
            # Complete workflow
            processor.load_data(input_filename)
            processor.process_data()
            processor.save_results(output_filename)
            
            # Verify loaded data
            self.assertEqual(len(processor.data), 5)
            
            # Verify processed data
            self.assertEqual(len(processor.processed_data), 5)
            
            # Verify statistics
            stats = processor.get_stats()
            self.assertEqual(stats['total_items'], 5)
            self.assertEqual(stats['positive_items'], 3)  # 25.5, 10.0, 100.0
            self.assertEqual(stats['average_value'], 26.1)  # (25.5 + 10 + (-5) + 0 + 100) / 5
            
            # Verify output file
            with open(output_filename, 'r') as f:
                lines = f.readlines()
            
            self.assertEqual(len(lines), 5)
            self.assertIn('product_alpha,650.25', lines[0])  # 25.5^2 = 650.25
            self.assertIn('product_epsilon,10000.0', lines[4])  # 100^2 = 10000
            
        finally:
            os.unlink(input_filename)
            os.unlink(output_filename)


if __name__ == '__main__':
    # Set up logging to reduce noise during tests
    import logging
    logging.basicConfig(level=logging.CRITICAL)
    
    # Run the tests
    unittest.main(verbosity=2)
