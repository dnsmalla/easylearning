# auto_cursor - Enhanced Base Application Classes
# Created to reduce code duplication across generated templates
# Enhanced with security, validation, persistence, and error handling

from __future__ import annotations
import logging
import hashlib
import json
from datetime import datetime, timezone
from typing import Optional, Dict, List, Any, Union, Callable
from abc import ABC, abstractmethod
from dataclasses import dataclass, asdict
from enum import Enum
import bleach
from pathlib import Path


# Enhanced Data Models and Enums
class ApplicationStatus(Enum):
    """Application status enumeration."""
    ACTIVE = "active"
    INACTIVE = "inactive"
    MAINTENANCE = "maintenance"
    DEPRECATED = "deprecated"


class ValidationError(Exception):
    """Custom validation error."""
    pass


class SecurityError(Exception):
    """Custom security error."""
    pass


class PersistenceError(Exception):
    """Custom persistence error."""
    pass


@dataclass
class ValidationSchema:
    """Schema for input validation."""
    required_fields: List[str]
    optional_fields: List[str] = None
    field_types: Dict[str, type] = None
    field_validators: Dict[str, Callable] = None
    max_lengths: Dict[str, int] = None


@dataclass
class OperationResult:
    """Standardized operation result."""
    success: bool
    data: Any = None
    error: str = None
    error_code: str = None
    timestamp: datetime = None
    
    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = datetime.now(timezone.utc)


class SecurityManager:
    """Enhanced security management."""
    
    @staticmethod
    def sanitize_input(data: Any) -> Any:
        """Sanitize input data to prevent XSS and injection attacks."""
        if isinstance(data, str):
            return bleach.clean(data.strip(), tags=[], attributes={}, strip=True)
        elif isinstance(data, dict):
            return {k: SecurityManager.sanitize_input(v) for k, v in data.items()}
        elif isinstance(data, list):
            return [SecurityManager.sanitize_input(item) for item in data]
        return data
    
    @staticmethod
    def generate_secure_id(prefix: str = "", length: int = 8) -> str:
        """Generate a secure unique identifier."""
        timestamp = str(int(datetime.now().timestamp() * 1000))
        hash_input = f"{prefix}{timestamp}{hash(datetime.now())}"
        secure_hash = hashlib.sha256(hash_input.encode()).hexdigest()[:length]
        return f"{prefix}_{secure_hash}" if prefix else secure_hash
    
    @staticmethod
    def validate_id_format(id_value: str, expected_prefix: str = None) -> bool:
        """Validate ID format."""
        if not isinstance(id_value, str) or not id_value:
            return False
        if expected_prefix and not id_value.startswith(f"{expected_prefix}_"):
            return False
        return True


class DataValidator:
    """Enhanced data validation."""
    
    @staticmethod
    def validate_data(data: Dict[str, Any], schema: ValidationSchema) -> OperationResult:
        """Validate data against schema."""
        try:
            # Check required fields
            for field in schema.required_fields:
                if field not in data or data[field] is None:
                    return OperationResult(
                        success=False,
                        error=f"Required field '{field}' is missing",
                        error_code="MISSING_REQUIRED_FIELD"
                    )
            
            # Check field types
            if schema.field_types:
                for field, expected_type in schema.field_types.items():
                    if field in data and not isinstance(data[field], expected_type):
                        return OperationResult(
                            success=False,
                            error=f"Field '{field}' must be of type {expected_type.__name__}",
                            error_code="INVALID_FIELD_TYPE"
                        )
            
            # Check max lengths
            if schema.max_lengths:
                for field, max_length in schema.max_lengths.items():
                    if field in data and isinstance(data[field], str) and len(data[field]) > max_length:
                        return OperationResult(
                            success=False,
                            error=f"Field '{field}' exceeds maximum length of {max_length}",
                            error_code="FIELD_TOO_LONG"
                        )
            
            # Run custom validators
            if schema.field_validators:
                for field, validator in schema.field_validators.items():
                    if field in data:
                        try:
                            if not validator(data[field]):
                                return OperationResult(
                                    success=False,
                                    error=f"Field '{field}' failed validation",
                                    error_code="CUSTOM_VALIDATION_FAILED"
                                )
                        except Exception as e:
                            return OperationResult(
                                success=False,
                                error=f"Validation error for field '{field}': {str(e)}",
                                error_code="VALIDATION_ERROR"
                            )
            
            return OperationResult(success=True, data=data)
            
        except Exception as e:
            return OperationResult(
                success=False,
                error=f"Validation failed: {str(e)}",
                error_code="VALIDATION_EXCEPTION"
            )


class PersistenceManager:
    """Simple file-based persistence manager."""
    
    def __init__(self, data_dir: str = "data"):
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(exist_ok=True)
    
    def save_data(self, filename: str, data: Any) -> OperationResult:
        """Save data to file."""
        try:
            file_path = self.data_dir / f"{filename}.json"
            with open(file_path, 'w') as f:
                json.dump(data, f, indent=2, default=str)
            return OperationResult(success=True, data=str(file_path))
        except Exception as e:
            return OperationResult(
                success=False,
                error=f"Failed to save data: {str(e)}",
                error_code="SAVE_ERROR"
            )
    
    def load_data(self, filename: str) -> OperationResult:
        """Load data from file."""
        try:
            file_path = self.data_dir / f"{filename}.json"
            if not file_path.exists():
                return OperationResult(success=True, data=[])
            
            with open(file_path, 'r') as f:
                data = json.load(f)
            return OperationResult(success=True, data=data)
        except Exception as e:
            return OperationResult(
                success=False,
                error=f"Failed to load data: {str(e)}",
                error_code="LOAD_ERROR"
            )


class BaseApplication(ABC):
    """
    Enhanced base class for all generated applications.
    Provides security, validation, persistence, and error handling.
    """
    
    def __init__(self, config: Optional[Dict] = None, **kwargs):
        """Initialize BaseApplication with enhanced configuration."""
        # Sanitize input configuration
        raw_config = config or {}
        raw_config.update(kwargs)
        self.config = SecurityManager.sanitize_input(raw_config)
        
        # Core attributes
        self.created_at = datetime.now(timezone.utc)
        self.status = ApplicationStatus.ACTIVE
        self.logger = logging.getLogger(self.__class__.__name__)
        
        # Enhanced components
        self.security_manager = SecurityManager()
        self.data_validator = DataValidator()
        self.persistence_manager = PersistenceManager(
            data_dir=self.config.get('data_dir', f'data/{self.__class__.__name__.lower()}')
        )
        
        # Performance tracking
        self.operation_count = 0
        self.last_operation_time = None
        
        self.logger.info(f"Initialized {self.__class__.__name__} with enhanced security")
        self._setup()
    
    def _setup(self):
        """Internal setup method for initialization. Override in subclasses."""
        self.logger.debug("Running enhanced base setup...")
        # Load persisted data if available
        self._load_persisted_state()
    
    def _load_persisted_state(self):
        """Load persisted application state."""
        try:
            result = self.persistence_manager.load_data(f"{self.__class__.__name__}_state")
            if result.success and result.data:
                self.logger.info("Loaded persisted state")
        except Exception as e:
            self.logger.warning(f"Could not load persisted state: {e}")
    
    def _save_state(self):
        """Save current application state."""
        try:
            state_data = {
                'created_at': self.created_at.isoformat(),
                'status': self.status.value,
                'operation_count': self.operation_count,
                'last_operation_time': self.last_operation_time.isoformat() if self.last_operation_time else None
            }
            result = self.persistence_manager.save_data(f"{self.__class__.__name__}_state", state_data)
            if result.success:
                self.logger.debug("State saved successfully")
        except Exception as e:
            self.logger.warning(f"Could not save state: {e}")
    
    def validate_input(self, data: Dict[str, Any], schema: ValidationSchema = None) -> OperationResult:
        """Enhanced input validation with comprehensive schema support."""
        try:
            # Sanitize input first
            sanitized_data = self.security_manager.sanitize_input(data)
            
            # Basic null check
            if not sanitized_data:
                return OperationResult(
                    success=False,
                    error="Input data is required",
                    error_code="NULL_INPUT"
                )
            
            # Schema validation if provided
            if schema:
                return self.data_validator.validate_data(sanitized_data, schema)
            
            return OperationResult(success=True, data=sanitized_data)
            
        except Exception as e:
            self.logger.error(f"Validation error: {e}")
            return OperationResult(
                success=False,
                error=f"Validation failed: {str(e)}",
                error_code="VALIDATION_EXCEPTION"
            )
    
    def execute_operation(self, operation_name: str, operation_func: Callable, *args, **kwargs) -> OperationResult:
        """Execute an operation with comprehensive error handling and logging."""
        start_time = datetime.now(timezone.utc)
        self.operation_count += 1
        
        try:
            self.logger.info(f"Executing operation: {operation_name}")
            
            # Execute the operation
            result = operation_func(*args, **kwargs)
            
            # Ensure result is an OperationResult
            if not isinstance(result, OperationResult):
                result = OperationResult(success=True, data=result)
            
            self.last_operation_time = datetime.now(timezone.utc)
            execution_time = (self.last_operation_time - start_time).total_seconds()
            
            self.logger.info(f"Operation {operation_name} completed in {execution_time:.3f}s")
            
            # Auto-save state periodically
            if self.operation_count % 10 == 0:
                self._save_state()
            
            return result
            
        except ValidationError as e:
            self.logger.warning(f"Validation error in {operation_name}: {e}")
            return OperationResult(
                success=False,
                error=str(e),
                error_code="VALIDATION_ERROR"
            )
        except SecurityError as e:
            self.logger.error(f"Security error in {operation_name}: {e}")
            return OperationResult(
                success=False,
                error="Security violation detected",
                error_code="SECURITY_ERROR"
            )
        except Exception as e:
            self.logger.error(f"Unexpected error in {operation_name}: {e}")
            return OperationResult(
                success=False,
                error=f"Operation failed: {str(e)}",
                error_code="OPERATION_ERROR"
            )
    
    def get_info(self) -> Dict[str, Any]:
        """Get comprehensive instance information."""
        return {
            "class": self.__class__.__name__,
            "type": self.get_application_type(),
            "created_at": self.created_at.isoformat(),
            "status": self.status.value,
            "operation_count": self.operation_count,
            "last_operation_time": self.last_operation_time.isoformat() if self.last_operation_time else None,
            "config": {k: v for k, v in self.config.items() if not k.startswith('_')}  # Hide private config
        }
    
    def get_health_status(self) -> Dict[str, Any]:
        """Get application health status."""
        return {
            "status": self.status.value,
            "uptime_seconds": (datetime.now(timezone.utc) - self.created_at).total_seconds(),
            "operation_count": self.operation_count,
            "last_operation_time": self.last_operation_time.isoformat() if self.last_operation_time else None,
            "healthy": self.status == ApplicationStatus.ACTIVE
        }
    
    @abstractmethod
    def get_application_type(self) -> str:
        """Return the application type. Must be implemented by subclasses."""
        pass
    
    def shutdown(self):
        """Gracefully shutdown the application."""
        self.logger.info(f"Shutting down {self.__class__.__name__}")
        self.status = ApplicationStatus.INACTIVE
        self._save_state()
    
    def __str__(self) -> str:
        return f"{self.__class__.__name__}(type={self.get_application_type()}, status={self.status.value}, created_at={self.created_at})"
    
    def __repr__(self) -> str:
        return f"{self.__class__.__name__}(config={self.config})"


class ECommerceApplication(BaseApplication):
    """Enhanced base class for e-commerce applications with security and persistence."""
    
    def __init__(self, config: Optional[Dict] = None, **kwargs):
        super().__init__(config, **kwargs)
        
        # Data storage with indexing for performance
        self.products: List[Dict] = []
        self.orders: List[Dict] = []
        self.customers: List[Dict] = []
        self.cart_sessions: Dict[str, List[Dict]] = {}
        
        # Performance indexes
        self._product_index: Dict[str, Dict] = {}
        self._customer_index: Dict[str, Dict] = {}
        
        # Load persisted data
        self._load_ecommerce_data()
    
    def get_application_type(self) -> str:
        return "ecommerce"
    
    def _load_ecommerce_data(self):
        """Load persisted e-commerce data."""
        try:
            # Load products
            result = self.persistence_manager.load_data("products")
            if result.success and result.data:
                self.products = result.data
                self._rebuild_product_index()
            
            # Load customers
            result = self.persistence_manager.load_data("customers")
            if result.success and result.data:
                self.customers = result.data
                self._rebuild_customer_index()
                
            self.logger.info("E-commerce data loaded successfully")
        except Exception as e:
            self.logger.warning(f"Could not load e-commerce data: {e}")
    
    def _save_ecommerce_data(self):
        """Save e-commerce data to persistence."""
        try:
            self.persistence_manager.save_data("products", self.products)
            self.persistence_manager.save_data("customers", self.customers)
            self.persistence_manager.save_data("orders", self.orders)
        except Exception as e:
            self.logger.error(f"Failed to save e-commerce data: {e}")
    
    def _rebuild_product_index(self):
        """Rebuild product index for O(1) lookups."""
        self._product_index = {product['id']: product for product in self.products}
    
    def _rebuild_customer_index(self):
        """Rebuild customer index for O(1) lookups."""
        self._customer_index = {customer['id']: customer for customer in self.customers}
    
    def add_product(self, product_data: Dict) -> OperationResult:
        """Add a new product with enhanced validation and security."""
        def _add_product_operation():
            # Define validation schema
            schema = ValidationSchema(
                required_fields=['name', 'price'],
                field_types={'name': str, 'price': (int, float)},
                max_lengths={'name': 200, 'description': 1000},
                field_validators={
                    'price': lambda x: x > 0,
                    'name': lambda x: len(x.strip()) > 0
                }
            )
            
            # Validate input
            validation_result = self.validate_input(product_data, schema)
            if not validation_result.success:
                return validation_result
            
            sanitized_data = validation_result.data
            
            # Generate secure product ID
            product_id = self.security_manager.generate_secure_id("prod")
            
            # Create product with enhanced data
            product = {
                'id': product_id,
                'name': sanitized_data['name'],
                'price': float(sanitized_data['price']),
                'description': sanitized_data.get('description', ''),
                'category': sanitized_data.get('category', 'general'),
                'stock': sanitized_data.get('stock', 0),
                'active': sanitized_data.get('active', True),
                'created_at': datetime.now(timezone.utc).isoformat(),
                'updated_at': datetime.now(timezone.utc).isoformat()
            }
            
            # Add to storage and index
            self.products.append(product)
            self._product_index[product_id] = product
            
            # Save to persistence
            self._save_ecommerce_data()
            
            self.logger.info(f"Added product: {product_id}")
            return OperationResult(success=True, data={'product_id': product_id, 'product': product})
        
        return self.execute_operation("add_product", _add_product_operation)
    
    def get_product(self, product_id: str) -> OperationResult:
        """Get product by ID with validation."""
        def _get_product_operation():
            # Validate product ID format
            if not self.security_manager.validate_id_format(product_id, "prod"):
                return OperationResult(
                    success=False,
                    error="Invalid product ID format",
                    error_code="INVALID_PRODUCT_ID"
                )
            
            # Use index for O(1) lookup
            product = self._product_index.get(product_id)
            if not product:
                return OperationResult(
                    success=False,
                    error="Product not found",
                    error_code="PRODUCT_NOT_FOUND"
                )
            
            return OperationResult(success=True, data=product)
        
        return self.execute_operation("get_product", _get_product_operation)
    
    def search_products(self, query: str, filters: Dict[str, Any] = None) -> OperationResult:
        """Search products with enhanced filtering."""
        def _search_products_operation():
            if not query or len(query.strip()) < 2:
                return OperationResult(
                    success=False,
                    error="Search query must be at least 2 characters",
                    error_code="INVALID_SEARCH_QUERY"
                )
            
            sanitized_query = self.security_manager.sanitize_input(query.lower())
            filters = filters or {}
            results = []
            
            for product in self.products:
                # Skip inactive products
                if not product.get('active', True):
                    continue
                
                # Text search
                if (sanitized_query in product['name'].lower() or 
                    sanitized_query in product.get('description', '').lower()):
                    
                    # Apply filters
                    matches_filters = True
                    for filter_key, filter_value in filters.items():
                        if filter_key in product and product[filter_key] != filter_value:
                            matches_filters = False
                            break
                    
                    if matches_filters:
                        results.append(product)
            
            return OperationResult(success=True, data={
                'query': query,
                'results': results,
                'count': len(results)
            })
        
        return self.execute_operation("search_products", _search_products_operation)


class ManagementApplication(BaseApplication):
    """Base class for management applications."""
    
    def __init__(self, config: Optional[Dict] = None, **kwargs):
        super().__init__(config, **kwargs)
        self.items: List[Dict] = []
        self.categories: List[str] = []
    
    def get_application_type(self) -> str:
        return "management"
    
    def create_item(self, item_data: Dict) -> str:
        """Create a new item. Template method - override for specific implementation."""
        required_fields = ['name']
        if not self.validate_input(item_data, {'required': required_fields}):
            raise ValueError("Item data missing required fields")
        
        item_id = f"item_{len(self.items) + 1:04d}"
        item = {
            'id': item_id,
            'name': item_data['name'],
            'status': item_data.get('status', 'active'),
            'created_at': datetime.now().isoformat(),
            **{k: v for k, v in item_data.items() if k not in ['name', 'status']}
        }
        self.items.append(item)
        self.logger.info(f"Created item: {item_id}")
        return item_id
    
    def get_item(self, item_id: str) -> Optional[Dict]:
        """Get item by ID."""
        for item in self.items:
            if item['id'] == item_id:
                return item
        return None
    
    def update_item_status(self, item_id: str, status: str) -> bool:
        """Update item status."""
        item = self.get_item(item_id)
        if item:
            item['status'] = status
            item['updated_at'] = datetime.now().isoformat()
            self.logger.info(f"Updated item {item_id} status to {status}")
            return True
        return False


class DatabaseApplication(BaseApplication):
    """Base class for database/data analysis applications."""
    
    def __init__(self, config: Optional[Dict] = None, **kwargs):
        super().__init__(config, **kwargs)
        self.records: List[Dict] = []
    
    def get_application_type(self) -> str:
        return "database"
    
    def create(self, data: dict) -> str:
        """Create new record with flexible data structure."""
        record_id = f"record_{len(self.records) + 1:06d}"
        record = {
            'id': record_id,
            'created_at': datetime.now().isoformat(),
            **data
        }
        self.records.append(record)
        self.logger.info(f"Created record: {record_id}")
        return record_id
    
    def read(self, query: dict) -> list:
        """Read records with flexible query parameters."""
        self.logger.info(f"Reading records with query: {query}")
        results = []
        
        for record in self.records:
            match = True
            for key, value in query.items():
                if key not in record or record[key] != value:
                    match = False
                    break
            if match:
                results.append(record)
        
        return results
    
    def update(self, record_id: str, data: dict) -> bool:
        """Update record with new data."""
        for record in self.records:
            if record['id'] == record_id:
                record.update(data)
                record['updated_at'] = datetime.now().isoformat()
                self.logger.info(f"Updated record {record_id}")
                return True
        return False
    
    def delete(self, record_id: str) -> bool:
        """Delete record by ID."""
        for i, record in enumerate(self.records):
            if record['id'] == record_id:
                del self.records[i]
                self.logger.info(f"Deleted record {record_id}")
                return True
        return False


class MobileApplication(BaseApplication):
    """Base class for mobile applications."""
    
    def __init__(self, config: Optional[Dict] = None, **kwargs):
        super().__init__(config, **kwargs)
        self.user_data: Dict = {}
        self.app_state: Dict = {}
    
    def get_application_type(self) -> str:
        return "mobile"
    
    def save_user_data(self, key: str, value: Any) -> None:
        """Save user data."""
        self.user_data[key] = value
        self.logger.info(f"Saved user data: {key}")
    
    def get_user_data(self, key: str, default: Any = None) -> Any:
        """Get user data."""
        return self.user_data.get(key, default)
    
    def update_app_state(self, state_data: Dict) -> None:
        """Update application state."""
        self.app_state.update(state_data)
        self.logger.info("Updated app state")
    
    def get_app_state(self) -> Dict:
        """Get current application state."""
        return self.app_state.copy()
