# First install the required library if not already installed
%pip install semantic-link

# Import required libraries
import sempy
import sempy.fabric as fabric
import pandas as pd
from typing import Optional, Dict, Any
import json
import os

def validate_file_extension(file_path: str) -> bool:
    """
    Validates that the file has a proper extension for TMSL content.
    
    Parameters:
    - file_path: Path to the TMSL file
    
    Returns:
    - bool: True if valid extension, False otherwise
    """
    valid_extensions = ['.json', '.tmsl']
    file_extension = os.path.splitext(file_path)[1].lower()
    
    if file_extension not in valid_extensions:
        print(f"Warning: File extension should be one of {valid_extensions}")
        print("Current extension:", file_extension)
        return False
    return True

def load_tmsl_from_file(file_path: str) -> dict:
    """
    Loads TMSL from a file and validates its JSON structure.
    
    Parameters:
    - file_path: Path to the TMSL file (.json or .tmsl)
    
    Returns:
    - dict: Parsed TMSL content
    """
    try:
        # Validate file extension
        if not validate_file_extension(file_path):
            return None
            
        # Read the file content using regular Python file operations
        with open(file_path, 'r', encoding='utf-8') as file:
            file_content = file.read()
        
        # Parse and validate JSON
        tmsl_content = json.loads(file_content)
        
        # Basic validation of TMSL structure
        if not isinstance(tmsl_content, dict) or not any(key in tmsl_content for key in ['create', 'createOrReplace']):
            print("Warning: TMSL file might not have the correct structure.")
            print("Expected 'create' or 'createOrReplace' at root level.")
            return None
            
        print(f"Successfully loaded TMSL from: {file_path}")
        return tmsl_content
        
    except json.JSONDecodeError as e:
        print(f"Error parsing TMSL JSON: {str(e)}")
        return None
    except Exception as e:
        print(f"Error loading TMSL file: {str(e)}")
        return None

def deploy_semantic_model_from_tmsl(workspace_name: str, 
                                  tmsl_file_path: str,
                                  parameters: Optional[Dict[str, str]] = None) -> bool:
    """
    Deploys a semantic model using TMSL from a file.
    
    Parameters:
    - workspace_name: Name of the workspace
    - tmsl_file_path: Path to the TMSL file (.json or .tmsl)
    - parameters: Optional dictionary of parameters to replace in the TMSL
    
    Returns:
    - bool: True if successful, False otherwise
    """
    try:
        # Load TMSL from file
        tmsl_content = load_tmsl_from_file(tmsl_file_path)
        if not tmsl_content:
            return False
            
        # Replace parameters if provided
        if parameters:
            tmsl_str = json.dumps(tmsl_content)
            for key, value in parameters.items():
                tmsl_str = tmsl_str.replace(f"${key}", str(value))
            tmsl_content = json.loads(tmsl_str)
            
        # Execute TMSL
        result = fabric.execute_tmsl(
            script=json.dumps(tmsl_content),
            workspace=workspace_name
        )
        
        print(f"\nSemantic model deployed successfully to workspace '{workspace_name}'")
        return True
        
    except Exception as e:
        print(f"Error deploying semantic model: {str(e)}")
        return False

def verify_deployment(model_name: str, workspace_name: str) -> bool:
    """
    Verifies that a semantic model was deployed successfully.
    
    Parameters:
    - model_name: Name of the semantic model
    - workspace_name: Name of the workspace
    
    Returns:
    - bool: True if model exists and is accessible
    """
    try:
        datasets = fabric.list_datasets(workspace=workspace_name)
        if model_name in datasets['Dataset Name'].values:
            print(f"Verified: Semantic model '{model_name}' exists and is accessible.")
            
            # Get and display model properties
            model_info = datasets[datasets['Dataset Name'] == model_name]
            print("\nModel Properties:")
            display(model_info)
            
            return True
        else:
            print(f"Semantic model '{model_name}' not found in workspace.")
            return False
            
    except Exception as e:
        print(f"Error verifying deployment: {str(e)}")
        return False

# Example usage:

# 1. Basic deployment from TMSL file
"""
workspace_name = "Your Workspace Name"
tmsl_file_path = "path/to/your/model.tmsl"

deploy_semantic_model_from_tmsl(
    workspace_name=workspace_name,
    tmsl_file_path=tmsl_file_path
)
"""

# 2. Deployment with parameter substitution
"""
workspace_name = "Your Workspace Name"
tmsl_file_path = "path/to/your/model.json"

# Parameters to replace in the TMSL
parameters = {
    "ModelName": "Sales Analysis",
    "LakehousePath": "Tables/sales",
    "CompatibilityLevel": "1566"
}

deploy_semantic_model_from_tmsl(
    workspace_name=workspace_name,
    tmsl_file_path=tmsl_file_path,
    parameters=parameters
)

# Verify the deployment
verify_deployment("Sales Analysis", workspace_name)
"""
