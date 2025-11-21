#!/usr/bin/env python3
# Enhanced DNS System Startup Script
# One-command startup for the complete enhanced system

import os
import sys
import subprocess
import argparse
import logging
from pathlib import Path
from typing import List, Optional

# Add applications directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / "applications"))

try:
    from config_manager import ConfigManager, Environment
    from enhanced_inventory_management_system import InventoryManagementSystem, TransactionType
    from complete_e_commerce_platform import CompleteECommercePlatform
    from task_management_system import TaskManagementSystem
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("💡 Make sure you're running from the project root and dependencies are installed")
    print("   Run: pip install -r requirements.txt")
    sys.exit(1)


class EnhancedSystemLauncher:
    """Enhanced DNS System Launcher with multiple startup modes."""
    
    def __init__(self):
        # Navigate to the actual project root (5 levels up from this file)
        self.project_root = Path(__file__).parent.parent.parent.parent.parent
        self.src_dir = Path(__file__).parent.parent / "applications"
        self.config_dir = Path(__file__).parent.parent.parent / "config"  # Use DNS system config
        self.data_dir = Path(__file__).parent.parent.parent / "workspace" / "data"
        
        # Ensure directories exist (only data dir, config already exists in DNS system)
        self.data_dir.mkdir(exist_ok=True)
        
        # Setup logging
        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
        )
        self.logger = logging.getLogger("EnhancedSystemLauncher")
    
    def check_dependencies(self) -> bool:
        """Check if all required dependencies are installed."""
        required_packages = [
            'fastapi', 'uvicorn', 'pydantic', 'bleach', 'pyyaml'
        ]
        
        missing_packages = []
        for package in required_packages:
            try:
                __import__(package)
            except ImportError:
                missing_packages.append(package)
        
        if missing_packages:
            print(f"❌ Missing required packages: {', '.join(missing_packages)}")
            print("💡 Install with: pip install -r requirements.txt")
            return False
        
        return True
    
    def run_tests(self) -> bool:
        """Run the comprehensive test suite."""
        print("🧪 Running comprehensive test suite...")
        
        test_file = self.src_dir / "test_enhanced_system.py"
        if not test_file.exists():
            print(f"❌ Test file not found: {test_file}")
            return False
        
        try:
            result = subprocess.run([
                sys.executable, str(test_file)
            ], capture_output=True, text=True, cwd=self.project_root)
            
            print(result.stdout)
            if result.stderr:
                print("⚠️ Test warnings/errors:")
                print(result.stderr)
            
            if result.returncode == 0:
                print("✅ All tests passed!")
                return True
            else:
                print("❌ Some tests failed!")
                return False
                
        except Exception as e:
            print(f"❌ Error running tests: {e}")
            return False
    
    def create_sample_data(self) -> None:
        """Create sample data for demonstration."""
        print("📦 Creating sample data...")
        
        try:
            # Initialize systems
            config = {
                'data_dir': str(self.data_dir),
                'low_stock_threshold': 5,
                'auto_reorder': False
            }
            
            # Inventory System Sample Data
            ims = InventoryManagementSystem(config=config)
            
            sample_inventory_items = [
                {
                    'name': 'Wireless Bluetooth Headphones',
                    'sku': 'WBH-001',
                    'category': 'Electronics',
                    'description': 'Premium wireless headphones with noise cancellation',
                    'quantity': 45,
                    'unit_cost': 75.00,
                    'selling_price': 149.99,
                    'reorder_point': 10,
                    'reorder_quantity': 25
                },
                {
                    'name': 'Ergonomic Office Chair',
                    'sku': 'EOC-001',
                    'category': 'Furniture',
                    'description': 'Comfortable ergonomic office chair with lumbar support',
                    'quantity': 8,
                    'unit_cost': 200.00,
                    'selling_price': 399.99,
                    'reorder_point': 5,
                    'reorder_quantity': 10
                },
                {
                    'name': 'Mechanical Keyboard',
                    'sku': 'MKB-001',
                    'category': 'Electronics',
                    'description': 'RGB mechanical gaming keyboard with blue switches',
                    'quantity': 2,  # Low stock
                    'unit_cost': 80.00,
                    'selling_price': 159.99,
                    'reorder_point': 5,
                    'reorder_quantity': 15
                },
                {
                    'name': 'Standing Desk Converter',
                    'sku': 'SDC-001',
                    'category': 'Furniture',
                    'description': 'Adjustable standing desk converter for health and productivity',
                    'quantity': 15,
                    'unit_cost': 120.00,
                    'selling_price': 249.99,
                    'reorder_point': 8,
                    'reorder_quantity': 12
                }
            ]
            
            inventory_items_added = 0
            for item_data in sample_inventory_items:
                result = ims.add_inventory_item(item_data)
                if result.success:
                    inventory_items_added += 1
                    print(f"  ✅ Added inventory item: {item_data['name']}")
                else:
                    print(f"  ❌ Failed to add {item_data['name']}: {result.error}")
            
            # E-commerce System Sample Data
            ecommerce = CompleteECommercePlatform(config=config)
            
            sample_products = [
                {
                    'name': 'Smart Fitness Watch',
                    'price': 299.99,
                    'category': 'Electronics',
                    'description': 'Advanced fitness tracking with heart rate monitor and GPS',
                    'stock': 30
                },
                {
                    'name': 'Organic Coffee Beans',
                    'price': 24.99,
                    'category': 'Food & Beverage',
                    'description': 'Premium organic coffee beans from sustainable farms',
                    'stock': 100
                },
                {
                    'name': 'Yoga Mat Premium',
                    'price': 49.99,
                    'category': 'Sports & Fitness',
                    'description': 'Non-slip premium yoga mat with alignment guides',
                    'stock': 25
                }
            ]
            
            products_added = 0
            for product_data in sample_products:
                result = ecommerce.add_product(product_data)
                if result.success:
                    products_added += 1
                    print(f"  ✅ Added product: {product_data['name']}")
                else:
                    print(f"  ❌ Failed to add {product_data['name']}: {result.error}")
            
            # Task Management System Sample Data
            task_system = TaskManagementSystem(config=config)
            
            # Create a sample project
            project_result = task_system.create_project({
                'name': 'Enhanced DNS System Launch',
                'description': 'Launch and demonstrate the enhanced DNS code generation system'
            })
            
            if isinstance(project_result, str):
                project_id = project_result
            else:
                project_id = None
            
            sample_tasks = [
                {
                    'title': 'Setup Development Environment',
                    'description': 'Install dependencies and configure development environment',
                    'priority': 'high',
                    'project_id': project_id
                },
                {
                    'title': 'Run Comprehensive Tests',
                    'description': 'Execute all test suites to ensure system reliability',
                    'priority': 'high',
                    'project_id': project_id
                },
                {
                    'title': 'Create Sample Data',
                    'description': 'Generate sample inventory, products, and tasks for demonstration',
                    'priority': 'medium',
                    'project_id': project_id
                },
                {
                    'title': 'Launch API Server',
                    'description': 'Start the FastAPI server and verify all endpoints',
                    'priority': 'high',
                    'project_id': project_id
                },
                {
                    'title': 'Performance Testing',
                    'description': 'Conduct load testing and performance optimization',
                    'priority': 'medium',
                    'project_id': project_id
                }
            ]
            
            tasks_added = 0
            for task_data in sample_tasks:
                task_id = task_system.create_task(task_data)
                if task_id:
                    tasks_added += 1
                    print(f"  ✅ Added task: {task_data['title']}")
                    
                    # Update some task statuses for demonstration
                    if 'Setup' in task_data['title']:
                        task_system.update_task_status(task_id, 'completed')
                    elif 'Tests' in task_data['title']:
                        task_system.update_task_status(task_id, 'in_progress')
            
            print(f"📊 Sample data created successfully!")
            print(f"  📦 Inventory items: {inventory_items_added}")
            print(f"  🛒 Products: {products_added}")
            print(f"  📋 Tasks: {tasks_added}")
            
        except Exception as e:
            print(f"❌ Error creating sample data: {e}")
            self.logger.error(f"Sample data creation failed: {e}")
    
    def start_api_server(self, host: str = "0.0.0.0", port: int = 8000, reload: bool = True) -> None:
        """Start the FastAPI server."""
        print(f"🚀 Starting Enhanced DNS API Server...")
        print(f"   📍 URL: http://{host}:{port}")
        print(f"   📚 API Docs: http://{host}:{port}/docs")
        print(f"   🔄 Auto-reload: {reload}")
        print(f"   ⚡ Health Check: http://{host}:{port}/health")
        
        api_file = self.src_dir / "api_server.py"
        if not api_file.exists():
            print(f"❌ API server file not found: {api_file}")
            return
        
        try:
            # Set environment variables for the server
            env = os.environ.copy()
            env['PYTHONPATH'] = str(self.src_dir)
            
            # Start the server
            subprocess.run([
                sys.executable, str(api_file)
            ], cwd=self.project_root, env=env)
            
        except KeyboardInterrupt:
            print("\n🛑 Server stopped by user")
        except Exception as e:
            print(f"❌ Error starting server: {e}")
    
    def show_system_status(self) -> None:
        """Show current system status and information."""
        print("📊 Enhanced DNS System Status")
        print("=" * 50)
        
        try:
            # Initialize config manager
            config_manager = ConfigManager()
            
            print(f"🌍 Environment: {config_manager.environment.value}")
            print(f"📁 Data Directory: {self.data_dir}")
            print(f"⚙️  Config File: {config_manager.config_file}")
            
            # Validate configuration
            issues = config_manager.validate_configuration()
            if issues:
                print(f"⚠️  Configuration Issues: {len(issues)}")
                for issue in issues:
                    print(f"   - {issue}")
            else:
                print("✅ Configuration: Valid")
            
            # Check system components
            config = config_manager.get_app_config_dict('inventory')
            
            try:
                ims = InventoryManagementSystem(config=config)
                health = ims.get_health_status()
                print(f"📦 Inventory System: {'✅ Healthy' if health['healthy'] else '❌ Unhealthy'}")
                print(f"   Operations: {health['operation_count']}")
            except Exception as e:
                print(f"📦 Inventory System: ❌ Error - {e}")
            
            try:
                ecommerce = CompleteECommercePlatform(config=config)
                health = ecommerce.get_health_status()
                print(f"🛒 E-commerce System: {'✅ Healthy' if health['healthy'] else '❌ Unhealthy'}")
                print(f"   Operations: {health['operation_count']}")
            except Exception as e:
                print(f"🛒 E-commerce System: ❌ Error - {e}")
            
            try:
                task_system = TaskManagementSystem(config=config)
                health = task_system.get_health_status()
                print(f"📋 Task System: {'✅ Healthy' if health['healthy'] else '❌ Unhealthy'}")
                print(f"   Operations: {health['operation_count']}")
            except Exception as e:
                print(f"📋 Task System: ❌ Error - {e}")
                
        except Exception as e:
            print(f"❌ Error checking system status: {e}")
    
    def interactive_demo(self) -> None:
        """Run an interactive demonstration of the system."""
        print("🎮 Enhanced DNS System Interactive Demo")
        print("=" * 50)
        
        try:
            config = {
                'data_dir': str(self.data_dir),
                'low_stock_threshold': 5
            }
            
            # Initialize systems
            ims = InventoryManagementSystem(config=config)
            
            print("\n📦 Inventory Management Demo")
            print("-" * 30)
            
            # Add a product interactively
            print("Adding a new inventory item...")
            result = ims.add_inventory_item({
                'name': 'Demo Product',
                'sku': 'DEMO-001',
                'category': 'Demo',
                'description': 'A product created during the interactive demo',
                'quantity': 20,
                'unit_cost': 10.00,
                'selling_price': 19.99
            })
            
            if result.success:
                item_id = result.data['item_id']
                print(f"✅ Created item: {result.data['item']['name']}")
                print(f"   ID: {item_id}")
                print(f"   SKU: {result.data['item']['sku']}")
                print(f"   Status: {result.data['item']['status']}")
                
                # Simulate a sale
                print("\nSimulating a sale of 5 units...")
                sale_result = ims.update_stock(
                    item_id, -5, TransactionType.STOCK_OUT, "Demo sale"
                )
                
                if sale_result.success:
                    print(f"✅ Sale completed!")
                    print(f"   Stock: {sale_result.data['old_quantity']} → {sale_result.data['new_quantity']}")
                    print(f"   Status: {sale_result.data['status']}")
                
                # Generate report
                print("\nGenerating inventory report...")
                report_result = ims.get_inventory_report()
                
                if report_result.success:
                    summary = report_result.data['summary']
                    print(f"📊 Inventory Report:")
                    print(f"   Total Items: {summary['total_items']}")
                    print(f"   Total Value: ${summary['total_inventory_value']:,.2f}")
                    print(f"   Categories: {len(summary['category_breakdown'])}")
                    
                    alerts = report_result.data['alerts']
                    if alerts['low_stock_count'] > 0:
                        print(f"   🚨 Low Stock Alerts: {alerts['low_stock_count']}")
            
            print("\n🎉 Demo completed successfully!")
            print("💡 Start the API server to explore more features: python start_enhanced_system.py --api")
            
        except Exception as e:
            print(f"❌ Demo error: {e}")
            self.logger.error(f"Interactive demo failed: {e}")


def main():
    """Main entry point for the enhanced system launcher."""
    parser = argparse.ArgumentParser(
        description="Enhanced DNS Code Generation System Launcher",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python start_enhanced_system.py --test              # Run tests only
  python start_enhanced_system.py --api               # Start API server
  python start_enhanced_system.py --demo              # Interactive demo
  python start_enhanced_system.py --full              # Full setup and start
  python start_enhanced_system.py --status            # Show system status
        """
    )
    
    parser.add_argument('--test', action='store_true', help='Run comprehensive test suite')
    parser.add_argument('--api', action='store_true', help='Start API server')
    parser.add_argument('--demo', action='store_true', help='Run interactive demo')
    parser.add_argument('--full', action='store_true', help='Full setup: tests + sample data + API server')
    parser.add_argument('--status', action='store_true', help='Show system status')
    parser.add_argument('--sample-data', action='store_true', help='Create sample data only')
    parser.add_argument('--host', default='0.0.0.0', help='API server host (default: 0.0.0.0)')
    parser.add_argument('--port', type=int, default=8000, help='API server port (default: 8000)')
    parser.add_argument('--no-reload', action='store_true', help='Disable auto-reload for API server')
    
    args = parser.parse_args()
    
    # Create launcher instance
    launcher = EnhancedSystemLauncher()
    
    # Check dependencies first
    if not launcher.check_dependencies():
        sys.exit(1)
    
    print("🚀 Enhanced DNS Code Generation System v2.0")
    print("=" * 60)
    
    # Handle different modes
    if args.status:
        launcher.show_system_status()
    
    elif args.test:
        success = launcher.run_tests()
        sys.exit(0 if success else 1)
    
    elif args.demo:
        launcher.interactive_demo()
    
    elif args.sample_data:
        launcher.create_sample_data()
    
    elif args.api:
        launcher.start_api_server(
            host=args.host,
            port=args.port,
            reload=not args.no_reload
        )
    
    elif args.full:
        print("🔄 Running full system setup...")
        
        # Step 1: Run tests
        print("\n1️⃣ Running tests...")
        if not launcher.run_tests():
            print("❌ Tests failed. Aborting full setup.")
            sys.exit(1)
        
        # Step 2: Create sample data
        print("\n2️⃣ Creating sample data...")
        launcher.create_sample_data()
        
        # Step 3: Start API server
        print("\n3️⃣ Starting API server...")
        launcher.start_api_server(
            host=args.host,
            port=args.port,
            reload=not args.no_reload
        )
    
    else:
        # Default: show help and status
        parser.print_help()
        print("\n" + "=" * 60)
        launcher.show_system_status()
        print("\n💡 Use --help to see all available options")
        print("💡 Quick start: python start_enhanced_system.py --full")


if __name__ == "__main__":
    main()
