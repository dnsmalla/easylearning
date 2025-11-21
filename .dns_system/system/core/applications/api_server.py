# auto_cursor - Enhanced API Server
# FastAPI REST API for all enhanced applications

from __future__ import annotations
import logging
from datetime import datetime, timezone
from typing import Optional, Dict, List, Any, Union
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Depends, status, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, validator
import uvicorn

# Import our enhanced applications
from enhanced_inventory_management_system import InventoryManagementSystem, TransactionType
from complete_e_commerce_platform import CompleteECommercePlatform
from task_management_system import TaskManagementSystem
from base_application import OperationResult


# Pydantic Models for API
class InventoryItemCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    sku: str = Field(..., min_length=3, max_length=50)
    category: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=1000)
    quantity: int = Field(0, ge=0)
    unit_cost: float = Field(0.0, ge=0)
    selling_price: float = Field(0.0, ge=0)
    reorder_point: Optional[int] = Field(10, ge=0)
    reorder_quantity: Optional[int] = Field(50, ge=1)
    supplier_id: Optional[str] = None
    location_id: Optional[str] = None


class StockUpdate(BaseModel):
    quantity_change: int
    transaction_type: str = Field(..., regex="^(stock_in|stock_out|adjustment|transfer|return)$")
    notes: Optional[str] = Field("", max_length=500)


class ProductCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    price: float = Field(..., gt=0)
    category: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = Field("", max_length=1000)
    stock: int = Field(0, ge=0)


class TaskCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: str = Field(..., min_length=1, max_length=1000)
    priority: Optional[str] = Field("medium", regex="^(low|medium|high|urgent)$")
    assigned_to: Optional[str] = None
    due_date: Optional[str] = None
    project_id: Optional[str] = None


class APIResponse(BaseModel):
    success: bool
    data: Optional[Any] = None
    error: Optional[str] = None
    error_code: Optional[str] = None
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


# Global application instances
inventory_system: Optional[InventoryManagementSystem] = None
ecommerce_system: Optional[CompleteECommercePlatform] = None
task_system: Optional[TaskManagementSystem] = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan management."""
    global inventory_system, ecommerce_system, task_system
    
    # Startup
    logging.info("Starting up Enhanced DNS API Server...")
    
    # Initialize systems with enhanced configuration
    config = {
        'data_dir': 'api_data',
        'low_stock_threshold': 5,
        'auto_reorder': True
    }
    
    inventory_system = InventoryManagementSystem(config=config)
    ecommerce_system = CompleteECommercePlatform(config=config)
    task_system = TaskManagementSystem(config=config)
    
    logging.info("All systems initialized successfully")
    
    yield
    
    # Shutdown
    logging.info("Shutting down Enhanced DNS API Server...")
    if inventory_system:
        inventory_system.shutdown()
    if ecommerce_system:
        ecommerce_system.shutdown()
    if task_system:
        task_system.shutdown()


# Create FastAPI app with enhanced configuration
app = FastAPI(
    title="Enhanced DNS Code Generation System API",
    description="REST API for enhanced auto-generated applications with security, validation, and persistence",
    version="2.0.0",
    lifespan=lifespan
)

# Add security middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080"],  # Add your frontend URLs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["localhost", "127.0.0.1", "*.localhost"]
)


# Exception handlers
@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content=APIResponse(
            success=False,
            error=exc.detail,
            error_code=f"HTTP_{exc.status_code}"
        ).dict()
    )


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    logging.error(f"Unhandled exception: {exc}")
    return JSONResponse(
        status_code=500,
        content=APIResponse(
            success=False,
            error="Internal server error",
            error_code="INTERNAL_ERROR"
        ).dict()
    )


# Helper function to convert OperationResult to APIResponse
def operation_to_api_response(result: OperationResult) -> APIResponse:
    return APIResponse(
        success=result.success,
        data=result.data,
        error=result.error,
        error_code=result.error_code,
        timestamp=result.timestamp
    )


# Health check endpoint
@app.get("/health", response_model=APIResponse)
async def health_check():
    """Health check endpoint."""
    health_data = {
        "status": "healthy",
        "systems": {
            "inventory": inventory_system.get_health_status() if inventory_system else None,
            "ecommerce": ecommerce_system.get_health_status() if ecommerce_system else None,
            "tasks": task_system.get_health_status() if task_system else None
        }
    }
    
    return APIResponse(success=True, data=health_data)


# Inventory Management API Endpoints
@app.post("/api/inventory/items", response_model=APIResponse)
async def create_inventory_item(item: InventoryItemCreate):
    """Create a new inventory item."""
    if not inventory_system:
        raise HTTPException(status_code=503, detail="Inventory system not available")
    
    result = inventory_system.add_inventory_item(item.dict())
    if not result.success:
        raise HTTPException(status_code=400, detail=result.error)
    
    return operation_to_api_response(result)


@app.get("/api/inventory/items/{item_id}", response_model=APIResponse)
async def get_inventory_item(item_id: str):
    """Get inventory item by ID."""
    if not inventory_system:
        raise HTTPException(status_code=503, detail="Inventory system not available")
    
    # Try to get by ID first, then by SKU
    result = inventory_system._item_index.get(item_id)
    if not result:
        result = inventory_system.get_item_by_sku(item_id)
        if not result.success:
            raise HTTPException(status_code=404, detail="Item not found")
        return operation_to_api_response(result)
    
    return APIResponse(success=True, data=result)


@app.put("/api/inventory/items/{item_id}/stock", response_model=APIResponse)
async def update_item_stock(item_id: str, stock_update: StockUpdate):
    """Update item stock levels."""
    if not inventory_system:
        raise HTTPException(status_code=503, detail="Inventory system not available")
    
    try:
        transaction_type = TransactionType(stock_update.transaction_type)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid transaction type")
    
    result = inventory_system.update_stock(
        item_id,
        stock_update.quantity_change,
        transaction_type,
        stock_update.notes
    )
    
    if not result.success:
        status_code = 404 if result.error_code == "ITEM_NOT_FOUND" else 400
        raise HTTPException(status_code=status_code, detail=result.error)
    
    return operation_to_api_response(result)


@app.get("/api/inventory/low-stock", response_model=APIResponse)
async def get_low_stock_items():
    """Get all low stock items."""
    if not inventory_system:
        raise HTTPException(status_code=503, detail="Inventory system not available")
    
    result = inventory_system.get_low_stock_items()
    return operation_to_api_response(result)


@app.get("/api/inventory/report", response_model=APIResponse)
async def get_inventory_report():
    """Generate inventory report."""
    if not inventory_system:
        raise HTTPException(status_code=503, detail="Inventory system not available")
    
    result = inventory_system.get_inventory_report()
    return operation_to_api_response(result)


@app.get("/api/inventory/search", response_model=APIResponse)
async def search_inventory(q: str, category: Optional[str] = None, status: Optional[str] = None):
    """Search inventory items."""
    if not inventory_system:
        raise HTTPException(status_code=503, detail="Inventory system not available")
    
    filters = {}
    if category:
        filters['category'] = category
    if status:
        filters['status'] = status
    
    result = inventory_system.search_inventory(q, filters)
    if not result.success:
        raise HTTPException(status_code=400, detail=result.error)
    
    return operation_to_api_response(result)


# E-commerce API Endpoints
@app.post("/api/ecommerce/products", response_model=APIResponse)
async def create_product(product: ProductCreate):
    """Create a new product."""
    if not ecommerce_system:
        raise HTTPException(status_code=503, detail="E-commerce system not available")
    
    result = ecommerce_system.add_product(product.dict())
    if not result.success:
        raise HTTPException(status_code=400, detail=result.error)
    
    return operation_to_api_response(result)


@app.get("/api/ecommerce/products/{product_id}", response_model=APIResponse)
async def get_product(product_id: str):
    """Get product by ID."""
    if not ecommerce_system:
        raise HTTPException(status_code=503, detail="E-commerce system not available")
    
    result = ecommerce_system.get_product(product_id)
    if not result.success:
        raise HTTPException(status_code=404, detail=result.error)
    
    return operation_to_api_response(result)


@app.get("/api/ecommerce/products/search", response_model=APIResponse)
async def search_products(q: str, category: Optional[str] = None):
    """Search products."""
    if not ecommerce_system:
        raise HTTPException(status_code=503, detail="E-commerce system not available")
    
    filters = {'category': category} if category else None
    result = ecommerce_system.search_products(q, filters)
    
    if not result.success:
        raise HTTPException(status_code=400, detail=result.error)
    
    return operation_to_api_response(result)


# Task Management API Endpoints
@app.post("/api/tasks", response_model=APIResponse)
async def create_task(task: TaskCreate):
    """Create a new task."""
    if not task_system:
        raise HTTPException(status_code=503, detail="Task system not available")
    
    result = task_system.create_task(task.dict())
    if isinstance(result, str):  # Old API compatibility
        return APIResponse(success=True, data={"task_id": result})
    
    return operation_to_api_response(result)


@app.get("/api/tasks/{task_id}", response_model=APIResponse)
async def get_task(task_id: str):
    """Get task by ID."""
    if not task_system:
        raise HTTPException(status_code=503, detail="Task system not available")
    
    task = task_system.get_task(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    return APIResponse(success=True, data=task)


@app.put("/api/tasks/{task_id}/status", response_model=APIResponse)
async def update_task_status(task_id: str, status: str):
    """Update task status."""
    if not task_system:
        raise HTTPException(status_code=503, detail="Task system not available")
    
    success = task_system.update_task_status(task_id, status)
    if not success:
        raise HTTPException(status_code=400, detail="Failed to update task status")
    
    return APIResponse(success=True, data={"task_id": task_id, "status": status})


@app.get("/api/tasks/status/{status}", response_model=APIResponse)
async def get_tasks_by_status(status: str):
    """Get tasks by status."""
    if not task_system:
        raise HTTPException(status_code=503, detail="Task system not available")
    
    tasks = task_system.get_tasks_by_status(status)
    return APIResponse(success=True, data={"tasks": tasks, "count": len(tasks)})


@app.get("/api/tasks/stats", response_model=APIResponse)
async def get_task_statistics():
    """Get task statistics."""
    if not task_system:
        raise HTTPException(status_code=503, detail="Task system not available")
    
    stats = task_system.get_task_statistics()
    return APIResponse(success=True, data=stats)


# System Information Endpoints
@app.get("/api/system/info", response_model=APIResponse)
async def get_system_info():
    """Get system information."""
    system_info = {
        "inventory_system": inventory_system.get_info() if inventory_system else None,
        "ecommerce_system": ecommerce_system.get_info() if ecommerce_system else None,
        "task_system": task_system.get_info() if task_system else None,
        "api_version": "2.0.0",
        "timestamp": datetime.now(timezone.utc).isoformat()
    }
    
    return APIResponse(success=True, data=system_info)


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    
    # Run the server
    uvicorn.run(
        "src.python.api_server:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
