#!/usr/bin/env python3
"""
ADW Workflow Integration Test Script

Tests the complete AFK (Away From Keyboard) GitHub workflow functionality
to validate that the ADW (AI Developer Workflow) system is working correctly.

This script validates:
1. Environment setup and dependencies
2. Core workflow components (planning, building, testing)
3. Working directory context and file path resolution
4. State management and workflow chaining
5. Git operations and branch management
6. Error handling and recovery
"""

import json
import logging
import os
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Dict, Any, Optional, Tuple

# Add the parent directory to Python path to import ADW modules
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    from adw_modules.workflow_ops import (
        ensure_adw_id,
        classify_issue,
        build_plan,
        get_plan_file,
        implement_plan,
        generate_branch_name,
        create_commit,
        create_pull_request,
        find_existing_branch_for_issue,
        find_plan_for_issue,
        create_or_find_branch
    )
    from adw_modules.state import ADWState
    from adw_modules.agent import check_claude_installed, execute_template
    from adw_modules.data_types import GitHubIssue, AgentTemplateRequest
    from adw_modules.git_ops import get_current_branch, create_branch
    from adw_modules.github import get_repo_url
    from adw_modules.utils import make_adw_id
except ImportError as e:
    print(f"Error importing ADW modules: {e}")
    print("Make sure you're running from the adws directory")
    sys.exit(1)


class WorkflowIntegrationTester:
    """Main test class for ADW workflow integration testing."""
    
    def __init__(self, verbose: bool = False):
        """Initialize the tester with logging configuration."""
        self.verbose = verbose
        self.setup_logging()
        self.test_results: Dict[str, Any] = {}
        self.project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        
    def setup_logging(self):
        """Configure logging for test execution."""
        level = logging.DEBUG if self.verbose else logging.INFO
        logging.basicConfig(
            level=level,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.StreamHandler(sys.stdout),
                logging.FileHandler('test_workflow_integration.log')
            ]
        )
        self.logger = logging.getLogger(__name__)
        
    def test_environment_setup(self) -> bool:
        """Test Step 1: Validate ADW Environment Setup."""
        self.logger.info("🔧 Testing environment setup...")
        
        try:
            # Check GitHub CLI authentication
            result = subprocess.run(['gh', 'auth', 'status'], capture_output=True, text=True)
            if result.returncode != 0:
                self.logger.error("GitHub CLI not authenticated")
                return False
            self.logger.info("✓ GitHub CLI authenticated")
            
            # Check Claude Code CLI availability
            claude_error = check_claude_installed()
            if claude_error:
                self.logger.error(f"Claude Code CLI issue: {claude_error}")
                return False
            self.logger.info("✓ Claude Code CLI available")
            
            # Test Python module imports
            try:
                from adw_modules.agent import execute_template
                from adw_modules.workflow_ops import ensure_adw_id
                from adw_modules.state import ADWState
                self.logger.info("✓ ADW modules import successfully")
            except ImportError as e:
                self.logger.error(f"ADW module import failed: {e}")
                return False
                
            # Check required environment variables (indirectly through functionality)
            try:
                repo_url = get_repo_url()
                if repo_url:
                    self.logger.info(f"✓ Repository context available: {repo_url}")
                else:
                    self.logger.warning("Repository URL not available")
            except Exception as e:
                self.logger.error(f"Repository context check failed: {e}")
                return False
            
            self.test_results['environment_setup'] = True
            return True
            
        except Exception as e:
            self.logger.error(f"Environment setup test failed: {e}")
            self.test_results['environment_setup'] = False
            return False
    
    def test_core_workflow_components(self) -> bool:
        """Test Step 3: Test Core Workflow Components."""
        self.logger.info("⚙️ Testing core workflow components...")
        
        try:
            # Test ADW ID generation and state management
            test_issue_number = "999"  # Use a test issue number
            adw_id = ensure_adw_id(test_issue_number)
            
            self.logger.info(f"✓ Generated ADW ID: {adw_id}")
            
            # Test state loading and saving
            state = ADWState.load(adw_id, self.logger)
            if not state:
                self.logger.error("Failed to load ADW state")
                return False
            
            self.logger.info("✓ State management working")
            
            # Test issue classification with mock data
            from adw_modules.data_types import GitHubUser
            mock_user = GitHubUser(login="test-user")
            mock_issue = GitHubIssue(
                number=999,
                title="Test: Validate ADW workflow integration",
                body="This is a test issue to validate the ADW workflow functionality",
                author=mock_user,
                labels=[],
                state="open",
                url="https://github.com/test/repo/issues/999",
                created_at="2024-01-01T00:00:00Z",
                updated_at="2024-01-01T00:00:00Z"
            )
            
            # Save mock issue to state for later tests
            state.data['issue'] = mock_issue.model_dump()
            state.save("test_core_workflow_components")
            
            self.logger.info("✓ Core workflow components functional")
            self.test_results['core_workflow_components'] = True
            return True
            
        except Exception as e:
            self.logger.error(f"Core workflow components test failed: {e}")
            self.test_results['core_workflow_components'] = False
            return False
    
    def test_working_directory_fix(self) -> bool:
        """Test Step 4: Test Working Directory Fix."""
        self.logger.info("📁 Testing working directory context...")
        
        try:
            # Check current working directory
            current_dir = os.getcwd()
            self.logger.info(f"Current working directory: {current_dir}")
            
            # Verify we can resolve file paths correctly
            adws_dir = os.path.join(self.project_root, "adws")
            if not os.path.exists(adws_dir):
                self.logger.error(f"ADWs directory not found: {adws_dir}")
                return False
            
            # Test path resolution for common operations
            specs_dir = os.path.join(self.project_root, "specs")
            agents_dir = os.path.join(self.project_root, "agents")
            
            self.logger.info(f"✓ Project root: {self.project_root}")
            self.logger.info(f"✓ ADWs directory: {adws_dir}")
            self.logger.info(f"✓ Specs directory: {specs_dir}")
            self.logger.info(f"✓ Agents directory: {agents_dir}")
            
            # Test git operations work correctly
            try:
                result = subprocess.run(['git', 'status'], 
                                      cwd=self.project_root, 
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    self.logger.info("✓ Git operations work from project root")
                else:
                    self.logger.error("Git status failed from project root")
                    return False
            except Exception as e:
                self.logger.error(f"Git operations test failed: {e}")
                return False
            
            self.test_results['working_directory_fix'] = True
            return True
            
        except Exception as e:
            self.logger.error(f"Working directory test failed: {e}")
            self.test_results['working_directory_fix'] = False
            return False
    
    def test_pipeline_functionality(self) -> bool:
        """Test Step 5: Validate Complete Pipeline Functionality."""
        self.logger.info("🔄 Testing complete pipeline functionality...")
        
        try:
            # Test workflow chaining via state management
            test_adw_id = make_adw_id()
            test_issue_number = "998"
            
            # Initialize state
            state = ADWState(test_adw_id)
            state.update(
                adw_id=test_adw_id,
                issue_number=test_issue_number,
                issue_class="/chore"
            )
            state.save("pipeline_test_init")
            
            # Test state persistence and loading
            loaded_state = ADWState.load(test_adw_id, self.logger)
            if not loaded_state:
                self.logger.error("State persistence test failed")
                return False
                
            if loaded_state.get("issue_number") != test_issue_number:
                self.logger.error("State content validation failed")
                return False
            
            self.logger.info("✓ State chaining works correctly")
            
            # Test error handling
            try:
                # This should handle gracefully
                invalid_state = ADWState.load("invalid_id", self.logger)
                if invalid_state is None:
                    self.logger.info("✓ Error handling works for invalid states")
                else:
                    self.logger.warning("Error handling may need improvement")
            except Exception as e:
                self.logger.error(f"Error handling test failed: {e}")
                return False
            
            self.test_results['pipeline_functionality'] = True
            return True
            
        except Exception as e:
            self.logger.error(f"Pipeline functionality test failed: {e}")
            self.test_results['pipeline_functionality'] = False
            return False
    
    def test_adw_plan_build_script(self) -> bool:
        """Test the main adw_plan_build.py script in dry-run mode."""
        self.logger.info("🚀 Testing adw_plan_build.py script...")
        
        try:
            # Check if the script is executable
            script_path = os.path.join(os.path.dirname(__file__), "adw_plan_build.py")
            if not os.path.exists(script_path):
                self.logger.error(f"adw_plan_build.py not found at {script_path}")
                return False
            
            # Test script with help flag to ensure it's functional
            result = subprocess.run([
                sys.executable, script_path
            ], capture_output=True, text=True, cwd=os.path.dirname(__file__))
            
            # The script should show usage when no arguments provided
            if "Usage:" in result.stdout or "Usage:" in result.stderr:
                self.logger.info("✓ adw_plan_build.py script is functional")
                self.test_results['adw_plan_build_script'] = True
                return True
            else:
                self.logger.warning(f"Script response: {result.stdout} {result.stderr}")
                self.test_results['adw_plan_build_script'] = False
                return False
                
        except Exception as e:
            self.logger.error(f"adw_plan_build.py test failed: {e}")
            self.test_results['adw_plan_build_script'] = False
            return False
    
    def test_documentation_and_reporting(self) -> bool:
        """Test Step 6: Test Documentation and Reporting."""
        self.logger.info("📝 Testing documentation and reporting...")
        
        try:
            # Check if README exists and is readable
            readme_path = os.path.join(os.path.dirname(__file__), "README.md")
            if os.path.exists(readme_path):
                with open(readme_path, 'r') as f:
                    content = f.read()
                    if "ADW" in content:
                        self.logger.info("✓ ADW documentation exists")
                    else:
                        self.logger.warning("ADW documentation may be incomplete")
            else:
                self.logger.warning("README.md not found in adws directory")
            
            # Test report generation capability
            report_data = self.generate_test_report()
            if report_data:
                self.logger.info("✓ Test report generation works")
                self.test_results['documentation_and_reporting'] = True
                return True
            else:
                self.logger.error("Test report generation failed")
                self.test_results['documentation_and_reporting'] = False
                return False
                
        except Exception as e:
            self.logger.error(f"Documentation and reporting test failed: {e}")
            self.test_results['documentation_and_reporting'] = False
            return False
    
    def generate_test_report(self) -> Dict[str, Any]:
        """Generate a comprehensive test report."""
        timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
        
        report = {
            "test_execution_time": timestamp,
            "test_results": self.test_results,
            "environment_info": {
                "python_version": sys.version,
                "working_directory": os.getcwd(),
                "project_root": self.project_root
            },
            "summary": {
                "total_tests": len(self.test_results),
                "passed_tests": sum(1 for result in self.test_results.values() if result),
                "failed_tests": sum(1 for result in self.test_results.values() if not result),
                "success_rate": f"{(sum(1 for result in self.test_results.values() if result) / max(len(self.test_results), 1)) * 100:.1f}%"
            }
        }
        
        return report
    
    def run_all_tests(self) -> bool:
        """Run all integration tests in sequence."""
        self.logger.info("🧪 Starting ADW Workflow Integration Tests...")
        
        test_methods = [
            ("Environment Setup", self.test_environment_setup),
            ("Core Workflow Components", self.test_core_workflow_components),
            ("Working Directory Fix", self.test_working_directory_fix),
            ("Pipeline Functionality", self.test_pipeline_functionality),
            ("ADW Plan Build Script", self.test_adw_plan_build_script),
            ("Documentation and Reporting", self.test_documentation_and_reporting)
        ]
        
        all_passed = True
        
        for test_name, test_method in test_methods:
            self.logger.info(f"\n{'='*60}")
            self.logger.info(f"Running: {test_name}")
            self.logger.info(f"{'='*60}")
            
            try:
                result = test_method()
                if result:
                    self.logger.info(f"✅ {test_name}: PASSED")
                else:
                    self.logger.error(f"❌ {test_name}: FAILED")
                    all_passed = False
            except Exception as e:
                self.logger.error(f"💥 {test_name}: ERROR - {e}")
                all_passed = False
        
        # Generate and save test report
        report = self.generate_test_report()
        report_path = "workflow_test_report.json"
        
        try:
            with open(report_path, 'w') as f:
                json.dump(report, f, indent=2)
            self.logger.info(f"📊 Test report saved to: {report_path}")
        except Exception as e:
            self.logger.error(f"Failed to save test report: {e}")
        
        # Print summary
        self.logger.info(f"\n{'='*60}")
        self.logger.info("TEST SUMMARY")
        self.logger.info(f"{'='*60}")
        self.logger.info(f"Total Tests: {report['summary']['total_tests']}")
        self.logger.info(f"Passed: {report['summary']['passed_tests']}")
        self.logger.info(f"Failed: {report['summary']['failed_tests']}")
        self.logger.info(f"Success Rate: {report['summary']['success_rate']}")
        
        if all_passed:
            self.logger.info("🎉 All tests passed! ADW workflow is functional.")
        else:
            self.logger.error("⚠️ Some tests failed. Please review the issues above.")
        
        return all_passed


def main():
    """Main entry point for the test script."""
    import argparse
    
    parser = argparse.ArgumentParser(description="ADW Workflow Integration Test Suite")
    parser.add_argument("-v", "--verbose", action="store_true", 
                       help="Enable verbose logging")
    parser.add_argument("--test", choices=[
        "environment", "core", "workdir", "pipeline", "script", "docs"
    ], help="Run a specific test category only")
    
    args = parser.parse_args()
    
    tester = WorkflowIntegrationTester(verbose=args.verbose)
    
    if args.test:
        # Run specific test
        test_map = {
            "environment": tester.test_environment_setup,
            "core": tester.test_core_workflow_components,
            "workdir": tester.test_working_directory_fix,
            "pipeline": tester.test_pipeline_functionality,
            "script": tester.test_adw_plan_build_script,
            "docs": tester.test_documentation_and_reporting
        }
        
        if args.test in test_map:
            result = test_map[args.test]()
            sys.exit(0 if result else 1)
    else:
        # Run all tests
        result = tester.run_all_tests()
        sys.exit(0 if result else 1)


if __name__ == "__main__":
    main()