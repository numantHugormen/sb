def deploy_semantic_model_from_tmsl(workspace_name: str, 
                                  tmsl_file_path: str,
                                  parameters: Optional[Dict[str, str]] = None) -> bool:
    """
    Deploys a semantic model using TMSL from a file.
    
    Parameters:
    - workspace_name: Name of the workspace
    - tmsl_file_path: Path to the TMSL file
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
                tmsl_str = tmsl_str.replace(f"${key}", value)
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
tmsl_file_path = "path/to/your/model.tmsl"

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

# Example TMSL file structure (model.tmsl):
"""
{
    "createOrReplace": {
        "object": {
            "database": "$ModelName"
        },
        "database": {
            "name": "$ModelName",
            "compatibilityLevel": $CompatibilityLevel,
            "model": {
                "culture": "en-US",
                "defaultPowerBIDataSourceVersion": "powerBI_V3",
                "tables": [
                    {
                        "name": "Sales",
                        "mode": "directLake",
                        "source": {
                            "type": "entity",
                            "expression": "Lakehouse.'$LakehousePath'"
                        }
                    }
                ]
            }
        }
    }
}
