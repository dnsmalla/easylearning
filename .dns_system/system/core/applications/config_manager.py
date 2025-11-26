# auto_cursor - Enhanced Configuration Management System
# Centralized configuration with environment support and validation

from __future__ import annotations
import os
import yaml
import json
import logging
from pathlib import Path
from typing import Dict, Any, Optional, Union, List
from dataclasses import dataclass, field
from enum import Enum
from datetime import datetime, timezone

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    logging.warning("python-dotenv not installed. Environment variables will be loaded from system only.")


class Environment(Enum):
    """Application environment types."""
    DEVELOPMENT = "development"
    TESTING = "testing"
    STAGING = "staging"
    PRODUCTION = "production"


@dataclass
class DatabaseConfig:
    """Database configuration."""
    url: str = "sqlite:///data/app.db"
    pool_size: int = 10
    max_overflow: int = 20
    echo: bool = False
    
    def __post_init__(self):
        # Expand environment variables in URL
        self.url = os.path.expandvars(self.url)


@dataclass
class RedisConfig:
    """Redis configuration."""
    host: str = "localhost"
    port: int = 6379
    db: int = 0
    password: Optional[str] = None
    ssl: bool = False
    
    @property
    def url(self) -> str:
        """Generate Redis URL."""
        protocol = "rediss" if self.ssl else "redis"
        auth = f":{self.password}@" if self.password else ""
        return f"{protocol}://{auth}{self.host}:{self.port}/{self.db}"


@dataclass
class SecurityConfig:
    """Security configuration."""
    secret_key: str = "dev-secret-key-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7
    password_min_length: int = 8
    max_login_attempts: int = 5
    lockout_duration_minutes: int = 15
    
    def __post_init__(self):
        if self.secret_key == "dev-secret-key-change-in-production":
            logging.warning("Using default secret key. Change this in production!")


@dataclass
class APIConfig:
    """API server configuration."""
    host: str = "0.0.0.0"
    port: int = 8000
    reload: bool = False
    workers: int = 1
    log_level: str = "info"
    cors_origins: List[str] = field(default_factory=lambda: ["http://localhost:3000"])
    trusted_hosts: List[str] = field(default_factory=lambda: ["localhost", "127.0.0.1"])
    rate_limit_per_minute: int = 100


@dataclass
class LoggingConfig:
    """Logging configuration."""
    level: str = "INFO"
    format: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    file_path: Optional[str] = None
    max_file_size_mb: int = 10
    backup_count: int = 5
    json_format: bool = False


@dataclass
class ApplicationConfig:
    """Individual application configuration."""
    enabled: bool = True
    data_dir: str = "data"
    auto_save_interval_seconds: int = 300
    max_items: int = 10000
    cache_ttl_seconds: int = 3600


@dataclass
class InventoryConfig(ApplicationConfig):
    """Inventory management specific configuration."""
    low_stock_threshold: int = 10
    auto_reorder: bool = False
    reorder_quantity: int = 50
    enable_barcode_scanning: bool = False
    multi_location_support: bool = False


@dataclass
class ECommerceConfig(ApplicationConfig):
    """E-commerce specific configuration."""
    default_currency: str = "USD"
    tax_rate: float = 0.08
    shipping_cost: float = 9.99
    free_shipping_threshold: float = 50.00
    payment_gateway: str = "stripe"
    inventory_tracking: bool = True


@dataclass
class TaskManagementConfig(ApplicationConfig):
    """Task management specific configuration."""
    default_priority: str = "medium"
    auto_assign: bool = False
    notification_enabled: bool = True
    due_date_reminders: bool = True
    max_assignees_per_task: int = 5


class ConfigManager:
    """Enhanced configuration manager with environment support."""
    
    def __init__(self, config_file: Optional[str] = None, environment: Optional[str] = None):
        """Initialize configuration manager."""
        self.environment = Environment(environment or os.getenv("APP_ENV", "development"))
        self.config_file = config_file or self._get_default_config_file()
        self.config_data: Dict[str, Any] = {}
        
        # Load configuration
        self._load_configuration()
        
        # Initialize configuration objects
        self.database = self._create_database_config()
        self.redis = self._create_redis_config()
        self.security = self._create_security_config()
        self.api = self._create_api_config()
        self.logging = self._create_logging_config()
        self.inventory = self._create_inventory_config()
        self.ecommerce = self._create_ecommerce_config()
        self.task_management = self._create_task_management_config()
        
        # Setup logging with the new configuration
        self._setup_logging()
        
        logging.info(f"Configuration loaded for environment: {self.environment.value}")
    
    def _get_default_config_file(self) -> str:
        """Get default configuration file based on environment."""
        base_path = Path("config")
        base_path.mkdir(exist_ok=True)
        
        config_files = {
            Environment.DEVELOPMENT: "config.dev.yaml",
            Environment.TESTING: "config.test.yaml",
            Environment.STAGING: "config.staging.yaml",
            Environment.PRODUCTION: "config.prod.yaml"
        }
        
        return str(base_path / config_files[self.environment])
    
    def _load_configuration(self):
        """Load configuration from file and environment variables."""
        # Load from file if exists
        config_path = Path(self.config_file)
        if config_path.exists():
            try:
                with open(config_path, 'r') as f:
                    if config_path.suffix.lower() in ['.yaml', '.yml']:
                        self.config_data = yaml.safe_load(f) or {}
                    elif config_path.suffix.lower() == '.json':
                        self.config_data = json.load(f)
                    else:
                        logging.warning(f"Unsupported config file format: {config_path.suffix}")
                        self.config_data = {}
            except Exception as e:
                logging.error(f"Failed to load config file {self.config_file}: {e}")
                self.config_data = {}
        else:
            logging.info(f"Config file {self.config_file} not found, using defaults")
            self.config_data = {}
            # Create default config file
            self._create_default_config_file()
    
    def _create_default_config_file(self):
        """Create a default configuration file."""
        default_config = {
            'environment': self.environment.value,
            'database': {
                'url': 'sqlite:///data/app.db',
                'echo': self.environment == Environment.DEVELOPMENT
            },
            'redis': {
                'host': 'localhost',
                'port': 6379,
                'db': 0
            },
            'security': {
                'secret_key': 'dev-secret-key-change-in-production',
                'access_token_expire_minutes': 30
            },
            'api': {
                'host': '0.0.0.0',
                'port': 8000,
                'reload': self.environment == Environment.DEVELOPMENT,
                'cors_origins': ['http://localhost:3000', 'http://localhost:8080']
            },
            'logging': {
                'level': 'DEBUG' if self.environment == Environment.DEVELOPMENT else 'INFO',
                'file_path': f'logs/app_{self.environment.value}.log'
            },
            'applications': {
                'inventory': {
                    'enabled': True,
                    'low_stock_threshold': 10,
                    'auto_reorder': False
                },
                'ecommerce': {
                    'enabled': True,
                    'default_currency': 'USD',
                    'tax_rate': 0.08
                },
                'task_management': {
                    'enabled': True,
                    'default_priority': 'medium',
                    'notification_enabled': True
                }
            }
        }
        
        try:
            config_path = Path(self.config_file)
            config_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(config_path, 'w') as f:
                yaml.dump(default_config, f, default_flow_style=False, indent=2)
            
            logging.info(f"Created default config file: {self.config_file}")
            self.config_data = default_config
        except Exception as e:
            logging.error(f"Failed to create default config file: {e}")
    
    def get(self, key: str, default: Any = None) -> Any:
        """Get configuration value with dot notation support."""
        keys = key.split('.')
        value = self.config_data
        
        for k in keys:
            if isinstance(value, dict) and k in value:
                value = value[k]
            else:
                # Try environment variable
                env_key = '_'.join(keys).upper()
                env_value = os.getenv(env_key)
                if env_value is not None:
                    # Try to convert to appropriate type
                    if default is not None:
                        try:
                            if isinstance(default, bool):
                                return env_value.lower() in ('true', '1', 'yes', 'on')
                            elif isinstance(default, int):
                                return int(env_value)
                            elif isinstance(default, float):
                                return float(env_value)
                            elif isinstance(default, list):
                                return env_value.split(',')
                        except (ValueError, TypeError):
                            pass
                    return env_value
                return default
        
        return value
    
    def _create_database_config(self) -> DatabaseConfig:
        """Create database configuration."""
        return DatabaseConfig(
            url=self.get('database.url', 'sqlite:///data/app.db'),
            pool_size=self.get('database.pool_size', 10),
            max_overflow=self.get('database.max_overflow', 20),
            echo=self.get('database.echo', self.environment == Environment.DEVELOPMENT)
        )
    
    def _create_redis_config(self) -> RedisConfig:
        """Create Redis configuration."""
        return RedisConfig(
            host=self.get('redis.host', 'localhost'),
            port=self.get('redis.port', 6379),
            db=self.get('redis.db', 0),
            password=self.get('redis.password'),
            ssl=self.get('redis.ssl', False)
        )
    
    def _create_security_config(self) -> SecurityConfig:
        """Create security configuration."""
        return SecurityConfig(
            secret_key=self.get('security.secret_key', 'dev-secret-key-change-in-production'),
            algorithm=self.get('security.algorithm', 'HS256'),
            access_token_expire_minutes=self.get('security.access_token_expire_minutes', 30),
            refresh_token_expire_days=self.get('security.refresh_token_expire_days', 7),
            password_min_length=self.get('security.password_min_length', 8),
            max_login_attempts=self.get('security.max_login_attempts', 5),
            lockout_duration_minutes=self.get('security.lockout_duration_minutes', 15)
        )
    
    def _create_api_config(self) -> APIConfig:
        """Create API configuration."""
        return APIConfig(
            host=self.get('api.host', '0.0.0.0'),
            port=self.get('api.port', 8000),
            reload=self.get('api.reload', self.environment == Environment.DEVELOPMENT),
            workers=self.get('api.workers', 1),
            log_level=self.get('api.log_level', 'info'),
            cors_origins=self.get('api.cors_origins', ['http://localhost:3000']),
            trusted_hosts=self.get('api.trusted_hosts', ['localhost', '127.0.0.1']),
            rate_limit_per_minute=self.get('api.rate_limit_per_minute', 100)
        )
    
    def _create_logging_config(self) -> LoggingConfig:
        """Create logging configuration."""
        default_level = 'DEBUG' if self.environment == Environment.DEVELOPMENT else 'INFO'
        return LoggingConfig(
            level=self.get('logging.level', default_level),
            format=self.get('logging.format', '%(asctime)s - %(name)s - %(levelname)s - %(message)s'),
            file_path=self.get('logging.file_path'),
            max_file_size_mb=self.get('logging.max_file_size_mb', 10),
            backup_count=self.get('logging.backup_count', 5),
            json_format=self.get('logging.json_format', False)
        )
    
    def _create_inventory_config(self) -> InventoryConfig:
        """Create inventory configuration."""
        return InventoryConfig(
            enabled=self.get('applications.inventory.enabled', True),
            data_dir=self.get('applications.inventory.data_dir', 'data/inventory'),
            low_stock_threshold=self.get('applications.inventory.low_stock_threshold', 10),
            auto_reorder=self.get('applications.inventory.auto_reorder', False),
            reorder_quantity=self.get('applications.inventory.reorder_quantity', 50),
            enable_barcode_scanning=self.get('applications.inventory.enable_barcode_scanning', False),
            multi_location_support=self.get('applications.inventory.multi_location_support', False)
        )
    
    def _create_ecommerce_config(self) -> ECommerceConfig:
        """Create e-commerce configuration."""
        return ECommerceConfig(
            enabled=self.get('applications.ecommerce.enabled', True),
            data_dir=self.get('applications.ecommerce.data_dir', 'data/ecommerce'),
            default_currency=self.get('applications.ecommerce.default_currency', 'USD'),
            tax_rate=self.get('applications.ecommerce.tax_rate', 0.08),
            shipping_cost=self.get('applications.ecommerce.shipping_cost', 9.99),
            free_shipping_threshold=self.get('applications.ecommerce.free_shipping_threshold', 50.00),
            payment_gateway=self.get('applications.ecommerce.payment_gateway', 'stripe'),
            inventory_tracking=self.get('applications.ecommerce.inventory_tracking', True)
        )
    
    def _create_task_management_config(self) -> TaskManagementConfig:
        """Create task management configuration."""
        return TaskManagementConfig(
            enabled=self.get('applications.task_management.enabled', True),
            data_dir=self.get('applications.task_management.data_dir', 'data/tasks'),
            default_priority=self.get('applications.task_management.default_priority', 'medium'),
            auto_assign=self.get('applications.task_management.auto_assign', False),
            notification_enabled=self.get('applications.task_management.notification_enabled', True),
            due_date_reminders=self.get('applications.task_management.due_date_reminders', True),
            max_assignees_per_task=self.get('applications.task_management.max_assignees_per_task', 5)
        )
    
    def _setup_logging(self):
        """Setup logging based on configuration."""
        import logging.handlers
        
        # Create logs directory if file logging is enabled
        if self.logging.file_path:
            log_path = Path(self.logging.file_path)
            log_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Configure root logger
        root_logger = logging.getLogger()
        root_logger.setLevel(getattr(logging, self.logging.level.upper()))
        
        # Clear existing handlers
        root_logger.handlers.clear()
        
        # Console handler
        console_handler = logging.StreamHandler()
        console_handler.setLevel(getattr(logging, self.logging.level.upper()))
        
        # File handler if configured
        if self.logging.file_path:
            file_handler = logging.handlers.RotatingFileHandler(
                self.logging.file_path,
                maxBytes=self.logging.max_file_size_mb * 1024 * 1024,
                backupCount=self.logging.backup_count
            )
            file_handler.setLevel(getattr(logging, self.logging.level.upper()))
            root_logger.addHandler(file_handler)
        
        # Set formatter
        if self.logging.json_format:
            # JSON formatter would require additional dependency
            formatter = logging.Formatter(self.logging.format)
        else:
            formatter = logging.Formatter(self.logging.format)
        
        console_handler.setFormatter(formatter)
        if self.logging.file_path:
            file_handler.setFormatter(formatter)
        
        root_logger.addHandler(console_handler)
    
    def get_app_config_dict(self, app_name: str) -> Dict[str, Any]:
        """Get configuration dictionary for a specific application."""
        app_config = getattr(self, app_name, None)
        if app_config:
            return {
                'data_dir': app_config.data_dir,
                'enabled': app_config.enabled,
                'auto_save_interval_seconds': app_config.auto_save_interval_seconds,
                'max_items': app_config.max_items,
                'cache_ttl_seconds': app_config.cache_ttl_seconds,
                **{k: v for k, v in app_config.__dict__.items() 
                   if not k.startswith('_') and k not in ['data_dir', 'enabled', 'auto_save_interval_seconds', 'max_items', 'cache_ttl_seconds']}
            }
        return {}
    
    def validate_configuration(self) -> List[str]:
        """Validate configuration and return list of issues."""
        issues = []
        
        # Security validation
        if self.security.secret_key == "dev-secret-key-change-in-production" and self.environment == Environment.PRODUCTION:
            issues.append("Production environment is using default secret key")
        
        if self.security.password_min_length < 8:
            issues.append("Password minimum length should be at least 8 characters")
        
        # Database validation
        if not self.database.url:
            issues.append("Database URL is required")
        
        # API validation
        if self.api.port < 1 or self.api.port > 65535:
            issues.append("API port must be between 1 and 65535")
        
        return issues
    
    def __str__(self) -> str:
        return f"ConfigManager(environment={self.environment.value}, config_file={self.config_file})"


# Global configuration instance
config: Optional[ConfigManager] = None


def get_config() -> ConfigManager:
    """Get global configuration instance."""
    global config
    if config is None:
        config = ConfigManager()
    return config


def initialize_config(config_file: Optional[str] = None, environment: Optional[str] = None) -> ConfigManager:
    """Initialize global configuration."""
    global config
    config = ConfigManager(config_file, environment)
    return config


if __name__ == "__main__":
    # Example usage
    config_manager = ConfigManager()
    
    print(f"Environment: {config_manager.environment.value}")
    print(f"Database URL: {config_manager.database.url}")
    print(f"API Port: {config_manager.api.port}")
    print(f"Redis URL: {config_manager.redis.url}")
    
    # Validate configuration
    issues = config_manager.validate_configuration()
    if issues:
        print("Configuration issues found:")
        for issue in issues:
            print(f"  - {issue}")
    else:
        print("Configuration is valid!")
