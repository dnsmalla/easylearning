# auto_cursor - 2025-08-30
# Intelligent implementation for: Task Management System (Type: management)

from __future__ import annotations
import logging
from datetime import datetime
from typing import Optional, Dict, List, Any, Union
from base_application import ManagementApplication


class TaskManagementSystem(ManagementApplication):
    """
    TaskManagementSystem - Intelligently generated based on requirements analysis.
    
    This class implements functionality for: Task Management System
    Detected type: management
    Generated on: 2025-08-30
    """
    
    def __init__(self, config: Optional[Dict] = None, **kwargs):
        """Initialize TaskManagementSystem with flexible configuration."""
        super().__init__(config, **kwargs)
        # Task-specific attributes
        self.tasks: List[Dict] = []
        self.projects: List[Dict] = []
        self.task_categories = ['todo', 'in_progress', 'completed', 'cancelled']
    
    def _setup(self):
        """Internal setup method for initialization."""
        super()._setup()
        self.logger.debug("Running task management setup...")
        # Initialize default categories if they exist in parent
        if hasattr(self, 'categories'):
            self.categories.extend(self.task_categories)
    
    # Task Management Specific Methods
    
    def create_task(self, task_data: Dict) -> str:
        """Create a new task."""
        required_fields = ['title', 'description']
        if not self.validate_input(task_data, {'required': required_fields}):
            raise ValueError("Task data missing required fields")
        
        task_id = f"task_{len(self.tasks) + 1:04d}"
        task = {
            'id': task_id,
            'title': task_data['title'],
            'description': task_data['description'],
            'status': task_data.get('status', 'todo'),
            'priority': task_data.get('priority', 'medium'),
            'assigned_to': task_data.get('assigned_to'),
            'due_date': task_data.get('due_date'),
            'project_id': task_data.get('project_id'),
            'created_at': datetime.now().isoformat()
        }
        self.tasks.append(task)
        self.logger.info(f"Created task: {task_id}")
        return task_id
    
    def update_task_status(self, task_id: str, status: str) -> bool:
        """Update task status."""
        if status not in self.task_categories:
            self.logger.warning(f"Invalid status: {status}")
            return False
        
        task = self.get_task(task_id)
        if task:
            task['status'] = status
            task['updated_at'] = datetime.now().isoformat()
            self.logger.info(f"Updated task {task_id} status to {status}")
            return True
        return False
    
    def assign_task(self, task_id: str, assignee: str) -> bool:
        """Assign task to a user."""
        task = self.get_task(task_id)
        if task:
            task['assigned_to'] = assignee
            task['updated_at'] = datetime.now().isoformat()
            self.logger.info(f"Assigned task {task_id} to {assignee}")
            return True
        return False
    
    def get_task(self, task_id: str) -> Optional[Dict]:
        """Get task by ID."""
        for task in self.tasks:
            if task['id'] == task_id:
                return task
        return None
    
    def get_tasks_by_status(self, status: str) -> List[Dict]:
        """Get all tasks with specific status."""
        return [task for task in self.tasks if task['status'] == status]
    
    def get_tasks_by_assignee(self, assignee: str) -> List[Dict]:
        """Get all tasks assigned to specific user."""
        return [task for task in self.tasks if task.get('assigned_to') == assignee]
    
    def create_project(self, project_data: Dict) -> str:
        """Create a new project."""
        required_fields = ['name']
        if not self.validate_input(project_data, {'required': required_fields}):
            raise ValueError("Project data missing required fields")
        
        project_id = f"proj_{len(self.projects) + 1:04d}"
        project = {
            'id': project_id,
            'name': project_data['name'],
            'description': project_data.get('description', ''),
            'status': project_data.get('status', 'active'),
            'created_at': datetime.now().isoformat()
        }
        self.projects.append(project)
        self.logger.info(f"Created project: {project_id}")
        return project_id
    
    def get_project_tasks(self, project_id: str) -> List[Dict]:
        """Get all tasks for a specific project."""
        return [task for task in self.tasks if task.get('project_id') == project_id]
    
    def get_task_statistics(self) -> Dict:
        """Get task statistics."""
        stats = {status: 0 for status in self.task_categories}
        for task in self.tasks:
            status = task.get('status', 'todo')
            if status in stats:
                stats[status] += 1
        
        stats['total_tasks'] = len(self.tasks)
        stats['total_projects'] = len(self.projects)
        return stats
    
    def __str__(self) -> str:
        return f"TaskManagementSystem(type=management, created_at={self.created_at})"
    
    def __repr__(self) -> str:
        return f"TaskManagementSystem(config={self.config})"


if __name__ == '__main__':
    # Example usage
    instance = TaskManagementSystem()
    
    # Create a project
    project_id = instance.create_project({
        'name': 'Sample Project',
        'description': 'A sample project for demonstration'
    })
    
    # Create some tasks
    task1_id = instance.create_task({
        'title': 'Setup Development Environment',
        'description': 'Install required tools and dependencies',
        'priority': 'high',
        'project_id': project_id
    })
    
    task2_id = instance.create_task({
        'title': 'Write Unit Tests',
        'description': 'Create comprehensive test suite',
        'priority': 'medium',
        'project_id': project_id
    })
    
    # Update task status
    instance.update_task_status(task1_id, 'in_progress')
    instance.assign_task(task1_id, 'developer@example.com')
    
    print(f"Created: {instance}")
    print(f"Info: {instance.get_info()}")
    print(f"Statistics: {instance.get_task_statistics()}")
    print("TaskManagementSystem is ready for implementation!")
