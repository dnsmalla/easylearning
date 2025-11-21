#!/usr/bin/env python3
# Unit tests for TaskManagementSystem

import unittest
import sys
import os
from datetime import datetime
from unittest.mock import patch, MagicMock

# Add the applications directory to the path so we can import our modules
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'applications'))

from task_management_system import TaskManagementSystem


class TestTaskManagementSystem(unittest.TestCase):
    """Test cases for TaskManagementSystem class."""
    
    def setUp(self):
        """Set up test fixtures before each test method."""
        self.tms = TaskManagementSystem()
    
    def tearDown(self):
        """Clean up after each test method."""
        self.tms = None
    
    def test_initialization(self):
        """Test TaskManagementSystem initialization."""
        self.assertIsInstance(self.tms, TaskManagementSystem)
        self.assertEqual(self.tms.get_application_type(), "management")
        self.assertIsInstance(self.tms.tasks, list)
        self.assertIsInstance(self.tms.projects, list)
        self.assertEqual(len(self.tms.tasks), 0)
        self.assertEqual(len(self.tms.projects), 0)
    
    def test_create_task_valid_data(self):
        """Test creating a task with valid data."""
        task_data = {
            'title': 'Test Task',
            'description': 'This is a test task',
            'priority': 'high'
        }
        
        task_id = self.tms.create_task(task_data)
        
        self.assertIsInstance(task_id, str)
        self.assertTrue(task_id.startswith('task_'))
        self.assertEqual(len(self.tms.tasks), 1)
        
        created_task = self.tms.get_task(task_id)
        self.assertIsNotNone(created_task)
        self.assertEqual(created_task['title'], 'Test Task')
        self.assertEqual(created_task['description'], 'This is a test task')
        self.assertEqual(created_task['priority'], 'high')
        self.assertEqual(created_task['status'], 'todo')  # default status
    
    def test_create_task_missing_required_fields(self):
        """Test creating a task with missing required fields."""
        task_data = {
            'title': 'Test Task'
            # Missing 'description'
        }
        
        with self.assertRaises(ValueError) as context:
            self.tms.create_task(task_data)
        
        self.assertIn("missing required fields", str(context.exception))
        self.assertEqual(len(self.tms.tasks), 0)
    
    def test_update_task_status_valid(self):
        """Test updating task status with valid status."""
        # Create a task first
        task_data = {
            'title': 'Test Task',
            'description': 'This is a test task'
        }
        task_id = self.tms.create_task(task_data)
        
        # Update status
        result = self.tms.update_task_status(task_id, 'in_progress')
        
        self.assertTrue(result)
        updated_task = self.tms.get_task(task_id)
        self.assertEqual(updated_task['status'], 'in_progress')
        self.assertIn('updated_at', updated_task)
    
    def test_update_task_status_invalid_status(self):
        """Test updating task status with invalid status."""
        # Create a task first
        task_data = {
            'title': 'Test Task',
            'description': 'This is a test task'
        }
        task_id = self.tms.create_task(task_data)
        
        # Try to update with invalid status
        result = self.tms.update_task_status(task_id, 'invalid_status')
        
        self.assertFalse(result)
        task = self.tms.get_task(task_id)
        self.assertEqual(task['status'], 'todo')  # Should remain unchanged
    
    def test_update_task_status_nonexistent_task(self):
        """Test updating status of non-existent task."""
        result = self.tms.update_task_status('nonexistent_task', 'completed')
        self.assertFalse(result)
    
    def test_assign_task(self):
        """Test assigning a task to a user."""
        # Create a task first
        task_data = {
            'title': 'Test Task',
            'description': 'This is a test task'
        }
        task_id = self.tms.create_task(task_data)
        
        # Assign task
        result = self.tms.assign_task(task_id, 'john@example.com')
        
        self.assertTrue(result)
        assigned_task = self.tms.get_task(task_id)
        self.assertEqual(assigned_task['assigned_to'], 'john@example.com')
        self.assertIn('updated_at', assigned_task)
    
    def test_create_project(self):
        """Test creating a project."""
        project_data = {
            'name': 'Test Project',
            'description': 'This is a test project'
        }
        
        project_id = self.tms.create_project(project_data)
        
        self.assertIsInstance(project_id, str)
        self.assertTrue(project_id.startswith('proj_'))
        self.assertEqual(len(self.tms.projects), 1)
    
    def test_get_tasks_by_status(self):
        """Test getting tasks by status."""
        # Create tasks with different statuses
        task1_data = {'title': 'Task 1', 'description': 'Description 1'}
        task2_data = {'title': 'Task 2', 'description': 'Description 2'}
        task3_data = {'title': 'Task 3', 'description': 'Description 3'}
        
        task1_id = self.tms.create_task(task1_data)
        task2_id = self.tms.create_task(task2_data)
        task3_id = self.tms.create_task(task3_data)
        
        # Update some statuses
        self.tms.update_task_status(task1_id, 'in_progress')
        self.tms.update_task_status(task2_id, 'completed')
        # task3 remains 'todo'
        
        # Test filtering
        todo_tasks = self.tms.get_tasks_by_status('todo')
        in_progress_tasks = self.tms.get_tasks_by_status('in_progress')
        completed_tasks = self.tms.get_tasks_by_status('completed')
        
        self.assertEqual(len(todo_tasks), 1)
        self.assertEqual(len(in_progress_tasks), 1)
        self.assertEqual(len(completed_tasks), 1)
        self.assertEqual(todo_tasks[0]['id'], task3_id)
        self.assertEqual(in_progress_tasks[0]['id'], task1_id)
        self.assertEqual(completed_tasks[0]['id'], task2_id)
    
    def test_get_tasks_by_assignee(self):
        """Test getting tasks by assignee."""
        # Create tasks
        task1_data = {'title': 'Task 1', 'description': 'Description 1'}
        task2_data = {'title': 'Task 2', 'description': 'Description 2'}
        task3_data = {'title': 'Task 3', 'description': 'Description 3'}
        
        task1_id = self.tms.create_task(task1_data)
        task2_id = self.tms.create_task(task2_data)
        task3_id = self.tms.create_task(task3_data)
        
        # Assign tasks
        self.tms.assign_task(task1_id, 'john@example.com')
        self.tms.assign_task(task2_id, 'john@example.com')
        self.tms.assign_task(task3_id, 'jane@example.com')
        
        # Test filtering
        john_tasks = self.tms.get_tasks_by_assignee('john@example.com')
        jane_tasks = self.tms.get_tasks_by_assignee('jane@example.com')
        
        self.assertEqual(len(john_tasks), 2)
        self.assertEqual(len(jane_tasks), 1)
        self.assertEqual(jane_tasks[0]['id'], task3_id)
    
    def test_get_project_tasks(self):
        """Test getting tasks for a specific project."""
        # Create a project
        project_data = {'name': 'Test Project'}
        project_id = self.tms.create_project(project_data)
        
        # Create tasks with and without project assignment
        task1_data = {
            'title': 'Task 1',
            'description': 'Description 1',
            'project_id': project_id
        }
        task2_data = {
            'title': 'Task 2',
            'description': 'Description 2',
            'project_id': project_id
        }
        task3_data = {
            'title': 'Task 3',
            'description': 'Description 3'
            # No project_id
        }
        
        self.tms.create_task(task1_data)
        self.tms.create_task(task2_data)
        self.tms.create_task(task3_data)
        
        # Get project tasks
        project_tasks = self.tms.get_project_tasks(project_id)
        
        self.assertEqual(len(project_tasks), 2)
        for task in project_tasks:
            self.assertEqual(task['project_id'], project_id)
    
    def test_get_task_statistics(self):
        """Test getting task statistics."""
        # Initially should have zero tasks
        stats = self.tms.get_task_statistics()
        self.assertEqual(stats['total_tasks'], 0)
        self.assertEqual(stats['todo'], 0)
        self.assertEqual(stats['in_progress'], 0)
        self.assertEqual(stats['completed'], 0)
        self.assertEqual(stats['cancelled'], 0)
        
        # Create tasks with different statuses
        task1_data = {'title': 'Task 1', 'description': 'Description 1'}
        task2_data = {'title': 'Task 2', 'description': 'Description 2'}
        task3_data = {'title': 'Task 3', 'description': 'Description 3'}
        
        task1_id = self.tms.create_task(task1_data)
        task2_id = self.tms.create_task(task2_data)
        task3_id = self.tms.create_task(task3_data)
        
        # Update statuses
        self.tms.update_task_status(task1_id, 'in_progress')
        self.tms.update_task_status(task2_id, 'completed')
        # task3 remains 'todo'
        
        # Check statistics
        stats = self.tms.get_task_statistics()
        self.assertEqual(stats['total_tasks'], 3)
        self.assertEqual(stats['todo'], 1)
        self.assertEqual(stats['in_progress'], 1)
        self.assertEqual(stats['completed'], 1)
        self.assertEqual(stats['cancelled'], 0)
    
    def test_validate_input(self):
        """Test input validation."""
        # Test with None data
        self.assertFalse(self.tms.validate_input(None))
        
        # Test with valid data and no schema
        self.assertTrue(self.tms.validate_input({'key': 'value'}))
        
        # Test with valid data and schema
        data = {'name': 'Test', 'description': 'Test description'}
        schema = {'required': ['name', 'description']}
        self.assertTrue(self.tms.validate_input(data, schema))
        
        # Test with invalid data (missing required field)
        data = {'name': 'Test'}
        schema = {'required': ['name', 'description']}
        self.assertFalse(self.tms.validate_input(data, schema))
    
    @patch('task_management_system.datetime')
    def test_task_creation_timestamp(self, mock_datetime):
        """Test that tasks are created with proper timestamps."""
        # Mock datetime to return a specific time
        mock_now = MagicMock()
        mock_now.isoformat.return_value = '2023-01-01T12:00:00'
        mock_datetime.now.return_value = mock_now
        
        task_data = {
            'title': 'Test Task',
            'description': 'This is a test task'
        }
        
        task_id = self.tms.create_task(task_data)
        task = self.tms.get_task(task_id)
        
        self.assertEqual(task['created_at'], '2023-01-01T12:00:00')
        mock_datetime.now.assert_called()


class TestTaskManagementSystemIntegration(unittest.TestCase):
    """Integration tests for TaskManagementSystem."""
    
    def test_complete_workflow(self):
        """Test a complete task management workflow."""
        tms = TaskManagementSystem()
        
        # Create a project
        project_id = tms.create_project({
            'name': 'Website Redesign',
            'description': 'Complete redesign of company website'
        })
        
        # Create tasks for the project
        task1_id = tms.create_task({
            'title': 'Design Mockups',
            'description': 'Create design mockups for all pages',
            'priority': 'high',
            'project_id': project_id
        })
        
        task2_id = tms.create_task({
            'title': 'Frontend Development',
            'description': 'Implement the frontend based on mockups',
            'priority': 'high',
            'project_id': project_id
        })
        
        task3_id = tms.create_task({
            'title': 'Content Migration',
            'description': 'Migrate existing content to new site',
            'priority': 'medium',
            'project_id': project_id
        })
        
        # Assign tasks
        tms.assign_task(task1_id, 'designer@company.com')
        tms.assign_task(task2_id, 'developer@company.com')
        tms.assign_task(task3_id, 'content@company.com')
        
        # Update task statuses to simulate workflow
        tms.update_task_status(task1_id, 'completed')
        tms.update_task_status(task2_id, 'in_progress')
        
        # Verify the workflow state
        project_tasks = tms.get_project_tasks(project_id)
        self.assertEqual(len(project_tasks), 3)
        
        completed_tasks = tms.get_tasks_by_status('completed')
        self.assertEqual(len(completed_tasks), 1)
        self.assertEqual(completed_tasks[0]['id'], task1_id)
        
        in_progress_tasks = tms.get_tasks_by_status('in_progress')
        self.assertEqual(len(in_progress_tasks), 1)
        self.assertEqual(in_progress_tasks[0]['id'], task2_id)
        
        developer_tasks = tms.get_tasks_by_assignee('developer@company.com')
        self.assertEqual(len(developer_tasks), 1)
        self.assertEqual(developer_tasks[0]['status'], 'in_progress')
        
        # Check statistics
        stats = tms.get_task_statistics()
        self.assertEqual(stats['total_tasks'], 3)
        self.assertEqual(stats['completed'], 1)
        self.assertEqual(stats['in_progress'], 1)
        self.assertEqual(stats['todo'], 1)
        self.assertEqual(stats['total_projects'], 1)


if __name__ == '__main__':
    # Set up logging to reduce noise during tests
    import logging
    logging.basicConfig(level=logging.CRITICAL)
    
    # Run the tests
    unittest.main(verbosity=2)
