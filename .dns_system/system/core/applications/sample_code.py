#!/usr/bin/env python3
# Sample code for refactoring demonstration

import logging
from typing import List, Dict, Any, Optional

# Constants
MIN_PARTS_COUNT = 2
NAME_INDEX = 0
VALUE_INDEX = 1
COMMENT_PREFIX = '#'

class DataProcessor:
    def __init__(self):
        self.data: List[Dict[str, Any]] = []
        self.processed_data: List[Dict[str, Any]] = []
        self.logger = logging.getLogger(self.__class__.__name__)
        logging.basicConfig(level=logging.INFO)
    
    def load_data(self, filename: str) -> None:
        """Load data from CSV file with proper error handling and logging."""
        self.logger.info(f"Loading data from {filename}")
        try:
            with open(filename, 'r') as file:
                lines = file.readlines()
                self._process_lines(lines)
        except FileNotFoundError:
            self.logger.error(f"File not found: {filename}")
            raise
        except Exception as e:
            self.logger.error(f"Error loading data: {e}")
            raise
    
    def _process_lines(self, lines: List[str]) -> None:
        """Process individual lines from the file."""
        for line_num, line in enumerate(lines, 1):
            try:
                self._process_single_line(line.strip(), line_num)
            except ValueError as e:
                self.logger.warning(f"Skipping invalid line {line_num}: {e}")
    
    def _process_single_line(self, line: str, line_num: int) -> None:
        """Process a single line of data."""
        if not line or line.startswith(COMMENT_PREFIX):
            return
        
        parts = line.split(',')
        if len(parts) < MIN_PARTS_COUNT:
            raise ValueError(f"Insufficient data parts: {line}")
        
        try:
            name = parts[NAME_INDEX].strip()
            value = float(parts[VALUE_INDEX].strip())
            self.data.append({'name': name, 'value': value})
        except (ValueError, IndexError) as e:
            raise ValueError(f"Invalid data format: {line} - {e}")
    
    def process_data(self) -> None:
        """Process loaded data with transformations."""
        self.logger.info(f"Processing {len(self.data)} data items")
        self.processed_data = [self._transform_item(item) for item in self.data]
        self.logger.info(f"Processed {len(self.processed_data)} items")
    
    def _transform_item(self, item: Dict[str, Any]) -> Dict[str, Any]:
        """Transform a single data item."""
        return {
            'original_name': item['name'],
            'normalized_name': self._normalize_name(item['name']),
            'original_value': item['value'],
            'squared_value': item['value'] ** 2,
            'is_positive': item['value'] > 0
        }
    
    def _normalize_name(self, name: str) -> str:
        """Normalize name by converting to lowercase and replacing spaces with underscores."""
        return name.lower().replace(' ', '_')
    
    def save_results(self, filename: str) -> None:
        """Save processed results to file."""
        self.logger.info(f"Saving results to {filename}")
        try:
            with open(filename, 'w') as file:
                for item in self.processed_data:
                    file.write(f"{item['normalized_name']},{item['squared_value']}\n")
            self.logger.info(f"Successfully saved {len(self.processed_data)} items")
        except Exception as e:
            self.logger.error(f"Error saving results: {e}")
            raise
    
    def get_stats(self) -> Dict[str, Any]:
        """Get statistics about the processed data."""
        if not self.processed_data:
            return {'total_items': 0}
        
        values = [item['original_value'] for item in self.processed_data]
        return {
            'total_items': len(self.processed_data),
            'positive_items': sum(1 for item in self.processed_data if item['is_positive']),
            'average_value': sum(values) / len(values),
            'max_value': max(values),
            'min_value': min(values)
        }

# Usage example
if __name__ == "__main__":
    processor = DataProcessor()
    try:
        processor.load_data("input.csv")
        processor.process_data()
        processor.save_results("output.csv")
        
        # Display statistics
        stats = processor.get_stats()
        print(f"Processing complete! Stats: {stats}")
    except Exception as e:
        logging.error(f"Processing failed: {e}")
