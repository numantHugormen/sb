import requests
from requests_negotiate_sspi import HttpNegotiateAuth
import json

# Configuration
tenant_id = ""
client_id = ""
client_secret = ""
power_bi_dataset_url = "https://api.powerbi.com/v1.0/myorg/datasets"
xmla_endpoint = ""
#test xmla_endpoint = ""

# Step 1: Authenticate and get access token
def get_access_token():
    url = f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token"
    data = {
        "grant_type": "client_credentials",
        "client_id": client_id,
        "client_secret": client_secret,
        "scope": "https://analysis.windows.net/powerbi/api/.default"
    }
    response = requests.post(url, data=data)
    return response.json()["access_token"]

access_token = get_access_token()
print(f"Access token: {access_token[:50]}...")  # Print first 50 characters for verification

# Step 2: Establish XMLA connection
def create_xmla_connection():
    auth = HttpNegotiateAuth()
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    return requests.Session(), headers, auth

session, headers, auth = create_xmla_connection()
print(session, headers, auth)

# Step 3: Publish a new semantic model
def publish_semantic_model(model_name, model_definition):
    url = f"{xmla_endpoint}/databases/{model_name}"
    
    # old url = f"{xmla_endpoint}/databases/{model_name}"
    response = session.post(url, headers=headers, auth=auth, json=model_definition)
    if response.status_code == 200:
        print(f"Semantic model '{model_name}' published successfully.")
    else:
        print(f"Failed to publish semantic model. Status code: {response.status_code}")
        print(response.text)

# # Example usage:
model_definition = {
    "name": "NewModel",
    "tables": [
        {
            "name": "Table1",
            "columns": [
                {"name": "Column1", "dataType": "string"},
                {"name": "Column2", "dataType": "int64"}
            ]
        }
    ]
}
publish_semantic_model("NewModel", model_definition)

# Step 4: Push data to existing dataset
def push_data_to_dataset(dataset_id, table_name, rows):
    url = f"{power_bi_dataset_url}/{dataset_id}/tables/{table_name}/rows"
    data = json.dumps({"rows": rows})
    response = requests.post(url, headers=headers, data=data)
    if response.status_code == 200:
        print(f"Data pushed to dataset '{dataset_id}' table '{table_name}' successfully.")
    else:
        print(f"Failed to push data. Status code: {response.status_code}")
        print(response.text)

dataset_id = "your_dataset_id"
table_name = "YourTableName"
rows = [
    {"Column1": "Value1", "Column2": 42},
    {"Column1": "Value2", "Column2": 73}
]

# push_data_to_dataset(dataset_id, table_name, rows)
# publish_semantic_model("NewModel", model_definition)

#         xmla_script = """
#         <Batch xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
#             <Alter AllowCreate="true" ObjectExpansion="ExpandFull">
#                 <Object>
#                     <DatabaseID>your_dataset_name</DatabaseID>
#                 </Object>
#                 <ObjectDefinition>
#                     <Database xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
#                         <ID>your_dataset_name</ID>
#                         <Name>your_dataset_name</Name>
#                         <DataSource>
#                             <ID>DataSource</ID>
#                             <Name>DataSource</Name>
#                             <ConnectionString>Provider=MSOLAP;Data Source=your_server;Initial Catalog=your_catalog;</ConnectionString>
#                         </DataSource>
#                         <!-- Add more XMLA elements as needed -->
#                     </Database>
#                 </ObjectDefinition>
#             </Alter>
#         </Batch>



# <!-- Batch Insert with Multiple Tables -->
#   <Batch xmlns="http://schemas.microsoft.com/analysisservices/2003/engine"
#          Transaction="true">
#     <Insert>
#       <Object>
#         <DatabaseID>YourDatabase</DatabaseID>
#         <TableID>Products</TableID>
#       </Object>
#       <Rows>
#         <Row>
#           <ProductID>PROD-003</ProductID>
#           <ProductName>New Product</ProductName>
#           <Category>Electronics</Category>
#         </Row>
#       </Rows>
#     </Insert>
#     <Insert>
#       <Object>
#         <DatabaseID>YourDatabase</DatabaseID>
#         <TableID>SalesData</TableID>
#       </Object>
#       <Rows>
#         <Row>
#           <OrderDate>2024-01-03T00:00:00</OrderDate>
#           <ProductID>PROD-003</ProductID>
#           <Quantity>2</Quantity>
#           <Revenue>200.00</Revenue>
#         </Row>
#       </Rows>
#     </Insert>
#   </Batch>

#   <!-- Merge Command for Updating/Inserting -->
#   <Merge xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
#     <Source>
#       <Object>
#         <DatabaseID>YourDatabase</DatabaseID>
#         <TableID>StagingTable</TableID>
#       </Object>
#     </Source>
#     <Target>
#       <Object>
#         <DatabaseID>YourDatabase</DatabaseID>
#         <TableID>SalesData</TableID>
#       </Object>
#       <Keys>
#         <Key>
#           <Column>OrderID</Column>
#         </Key>
#       </Keys>
#     </Target>
#   </Merge>

#   <!-- Delete Data Before Insert -->
#   <Delete xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
#     <Object>
#       <DatabaseID>YourDatabase</DatabaseID>
#       <TableID>SalesData</TableID>
#     </Object>
#     <Condition>OrderDate &gt;= '2024-01-01' AND OrderDate &lt; '2024-02-01'</Condition>
#   </Delete>
# </Batch>
